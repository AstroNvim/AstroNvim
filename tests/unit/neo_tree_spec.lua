local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_spec(spec, name)
  for _, nested_spec in ipairs(spec.specs) do
    if nested_spec[1] == name then return nested_spec end
  end
  error("Missing nested spec: " .. name)
end

local function neo_tree_options(spec, options) return spec.opts(nil, options or {}) end

local function core_options(spec)
  local options = { mappings = { n = {} }, autocmds = {} }
  find_spec(spec, "AstroNvim/astrocore").opts(nil, options)
  return options
end

local function source_names(sources)
  local names = {}
  for _, source in ipairs(sources) do
    table.insert(names, type(source) == "table" and source.source or source)
  end
  return names
end

local function with_neo_tree(options, callback)
  options = options or {}
  local calls = {
    autocmds = {},
    modifiers = {},
    notifications = {},
    opens = {},
    registers = {},
    selections = {},
    uri_paths = {},
  }
  local loaded = {
    astrocore = {
      extend_tbl = function(base, extension) return vim.tbl_deep_extend("force", base, extension) end,
      notify = function(message, level) table.insert(calls.notifications, { message = message, level = level }) end,
    },
    astroui = { get_icon = function(name) return "icon:" .. name end },
    ["neo-tree"] = options.neo_tree_loaded or unit_helpers.remove,
  }
  for name, module in pairs(options.loaded or {}) do
    loaded[name] = module
  end

  return unit_helpers.with_module("astronvim.plugins.neo-tree", {
    loaded = loaded,
    preload = options.preload,
    vim = {
      api = {
        nvim_buf_get_name = function(bufnr) return (options.buffer_names or {})[bufnr] or "" end,
        nvim_exec_autocmds = function(...) table.insert(calls.autocmds, { ... }) end,
      },
      fn = {
        executable = function() return options.git_available == false and 0 or 1 end,
        has = function(feature) return feature == "win32" and (options.win32 and 1 or 0) or 0 end,
        fnamemodify = function(value, modifier)
          table.insert(calls.modifiers, { value, modifier })
          if options.fnamemodify then return options.fnamemodify(value, modifier) end
          return ({ [":r"] = "file", [":e"] = "txt", [":."] = "relative/file.txt", [":~"] = "~/file.txt" })[modifier]
            or value
        end,
        setreg = function(register, value) table.insert(calls.registers, { register, value }) end,
      },
      log = { levels = { WARN = "warn" } },
      ui = {
        open = function(path) table.insert(calls.opens, path) end,
        select = function(items, select_options, callback_fn)
          table.insert(calls.selections, { items = items, options = select_options, callback = callback_fn })
        end,
      },
      uri_from_fname = function(path)
        table.insert(calls.uri_paths, path)
        return options.uri_from_fname and options.uri_from_fname(path) or "file://" .. path
      end,
      uv = { fs_stat = options.fs_stat or function() return nil end },
    },
  }, function(spec) return callback(spec, calls) end)
end

T["NEO-02 starts Neo-tree only for an unloaded directory buffer"] = function()
  local cases = {
    {
      name = "already loaded",
      neo_tree_loaded = {},
      fs_stat = function() error "fs_stat must not run" end,
      expected = true,
      lazy_load = false,
      deferred_enter = false,
    },
    {
      name = "directory",
      fs_stat = function(path)
        assert.equals("/workspace", path)
        return { type = "directory" }
      end,
      expected = true,
      lazy_load = true,
      deferred_enter = true,
    },
    {
      name = "non-directory",
      fs_stat = function() return { type = "file" } end,
      expected = nil,
      lazy_load = false,
      deferred_enter = false,
    },
  }

  for _, case in ipairs(cases) do
    with_neo_tree({
      neo_tree_loaded = case.neo_tree_loaded,
      buffer_names = { [7] = "/workspace" },
      fs_stat = case.fs_stat,
      loaded = {
        lazy = {
          load = function(request) case.lazy_request = request end,
        },
      },
    }, function(spec, calls)
      local callback = core_options(spec).autocmds.neotree_start[1].callback
      assert.equals(case.expected, callback { buf = 7 }, case.name)
      assert.equals(case.lazy_load, case.lazy_request ~= nil, case.name)
      if case.lazy_load then assert.same({ plugins = { "neo-tree.nvim" } }, case.lazy_request) end
      assert.equals(case.deferred_enter, calls.autocmds ~= nil and #calls.autocmds == 1, case.name)
      if case.deferred_enter then
        assert.same({ "BufEnter", { group = "NeoTree_NetrwDeferred", buffer = 7 } }, calls.autocmds[1])
      end
    end)
  end
end

T["NEO-03 refreshes only loaded Neo-tree sources after LazyGit closes"] = function()
  local refreshed = {}
  with_neo_tree({
    loaded = {
      ["neo-tree.sources.manager"] = { refresh = function(name) table.insert(refreshed, name) end },
      ["neo-tree.sources.filesystem"] = { name = "filesystem" },
      ["neo-tree.sources.document_symbols"] = { name = "document_symbols" },
      ["neo-tree.sources.git_status"] = unit_helpers.remove,
    },
  }, function(spec) core_options(spec).autocmds.neotree_refresh[1].callback() end)
  table.sort(refreshed)
  assert.same({ "document_symbols", "filesystem" }, refreshed)

  with_neo_tree({
    loaded = { ["neo-tree.sources.manager"] = unit_helpers.remove },
    preload = { ["neo-tree.sources.manager"] = unit_helpers.remove },
  }, function(spec) core_options(spec).autocmds.neotree_refresh[1].callback() end)
end

T["NEO-04 navigates parent and child nodes through public commands"] = function()
  local calls = {}
  local states = {}
  with_neo_tree({
    loaded = {
      ["neo-tree.ui.renderer"] = {
        focus_node = function(state, node_id) table.insert(calls, { name = "focus", state = state, node_id = node_id }) end,
      },
    },
  }, function(spec)
    local commands = neo_tree_options(spec).commands
    local function state(label, node)
      local result
      result = {
        label = label,
        tree = { get_node = function() return node end },
        commands = {
          toggle_node = function(received)
            table.insert(calls, { name = "toggle", state = received.label, exact = received == result })
          end,
          open = function(received)
            table.insert(calls, { name = "open", state = received.label, exact = received == result })
          end,
        },
      }
      states[label] = result
      return result
    end

    commands.parent_or_close(state("parent-expanded", {
      has_children = function() return true end,
      is_expanded = function() return true end,
    }))
    commands.parent_or_close(state("parent-collapsed", {
      has_children = function() return true end,
      is_expanded = function() return false end,
      get_parent_id = function() return "parent" end,
    }))
    commands.parent_or_close(state("parent-leaf", {
      has_children = function() return false end,
      get_parent_id = function() return "leaf-parent" end,
    }))
    commands.child_or_open(state("child-collapsed", {
      has_children = function() return true end,
      is_expanded = function() return false end,
    }))
    commands.child_or_open(state("child-file", {
      has_children = function() return true end,
      is_expanded = function() return true end,
      type = "file",
    }))
    commands.child_or_open(state("child-directory", {
      has_children = function() return true end,
      is_expanded = function() return true end,
      type = "directory",
      get_child_ids = function() return { "child" } end,
    }))
    commands.child_or_open(state("child-leaf", { has_children = function() return false end }))
  end)

  local projected = {}
  for _, call in ipairs(calls) do
    table.insert(projected, {
      name = call.name,
      state = type(call.state) == "table" and call.state.label or call.state,
      node_id = call.node_id,
      exact = call.exact,
    })
  end
  assert.same({
    { name = "toggle", state = "parent-expanded", exact = true },
    { name = "focus", state = "parent-collapsed", node_id = "parent" },
    { name = "focus", state = "parent-leaf", node_id = "leaf-parent" },
    { name = "toggle", state = "child-collapsed", exact = true },
    { name = "open", state = "child-file", exact = true },
    { name = "focus", state = "child-directory", node_id = "child" },
    { name = "open", state = "child-leaf", exact = true },
  }, projected)
  assert.is_true(calls[2].state == states["parent-collapsed"])
  assert.is_true(calls[3].state == states["parent-leaf"])
  assert.is_true(calls[6].state == states["child-directory"])
end

T["NEO-05 copies selected values and handles cancellation or no values"] = function()
  local filepath = "/workspace/file.txt"
  local filename = "file.txt"
  local values = {
    BASENAME = "file",
    EXTENSION = "txt",
    FILENAME = filename,
    PATH = filepath,
    ["PATH (CWD)"] = "relative/file.txt",
    ["PATH (HOME)"] = "~/file.txt",
    URI = "file:///workspace/file.txt",
  }
  for _, choice in ipairs { "BASENAME", "EXTENSION", "FILENAME", "PATH", "PATH (CWD)", "PATH (HOME)", "URI" } do
    with_neo_tree({}, function(spec, calls)
      local node = { name = filename, get_id = function() return filepath end }
      neo_tree_options(spec).commands.copy_selector { tree = { get_node = function() return node end } }

      local selection = calls.selections[1]
      assert.same({ "BASENAME", "EXTENSION", "FILENAME", "PATH", "PATH (CWD)", "PATH (HOME)", "URI" }, selection.items)
      assert.equals("Choose to copy to clipboard:", selection.options.prompt)
      assert.equals(choice .. ": " .. values[choice], selection.options.format_item(choice))
      assert.same({
        { filename, ":r" },
        { filename, ":e" },
        { filepath, ":." },
        { filepath, ":~" },
      }, calls.modifiers)
      assert.same({ filepath }, calls.uri_paths)

      selection.callback(choice)
      assert.same({ { "+", values[choice] } }, calls.registers)
      assert.same({ { message = "Copied: `" .. values[choice] .. "`", level = nil } }, calls.notifications)
    end)
  end

  with_neo_tree({}, function(spec, calls)
    local node = { name = filename, get_id = function() return filepath end }
    neo_tree_options(spec).commands.copy_selector { tree = { get_node = function() return node end } }
    calls.selections[1].callback(nil)
    assert.same({}, calls.registers)
    assert.same({}, calls.notifications)
  end)

  with_neo_tree({
    uri_from_fname = function() return "" end,
    fnamemodify = function() return "" end,
  }, function(spec, calls)
    local node = { name = "", get_id = function() return "" end }
    neo_tree_options(spec).commands.copy_selector { tree = { get_node = function() return node end } }
    assert.equals(0, #calls.selections)
    assert.same({}, calls.registers)
    assert.same({ { message = "No values to copy", level = "warn" } }, calls.notifications)
  end)
end

T["NEO-06 gates Git sources and hidden Git items on Git availability"] = function()
  for _, case in ipairs {
    { name = "Git available", git_available = true, expected_sources = { "filesystem", "buffers", "git_status" } },
    { name = "Git unavailable", git_available = false, expected_sources = { "filesystem", "buffers" } },
  } do
    with_neo_tree({ git_available = case.git_available }, function(spec)
      local options = neo_tree_options(spec)
      assert.equals(case.git_available, options.enable_git_status, case.name)
      assert.equals(case.git_available, options.filesystem.filtered_items.hide_gitignored, case.name)
      assert.same(case.expected_sources, source_names(options.sources), case.name)
    end)
  end
end

T["NEO-07 keeps selected selector open watcher and window invariants"] = function()
  for _, case in ipairs {
    { name = "non-Windows", win32 = false, watcher_enabled = true },
    { name = "Windows", win32 = true, watcher_enabled = false },
  } do
    with_neo_tree({ win32 = case.win32 }, function(spec, calls)
      local options = neo_tree_options(spec)
      assert.is_true(options.source_selector.winbar, case.name)
      assert.equals("center", options.source_selector.content_layout, case.name)
      assert.same(
        { "filesystem", "buffers", "git_status", "diagnostics" },
        source_names(options.source_selector.sources),
        case.name
      )
      assert.equals(30, options.window.width, case.name)
      assert.same("system_open", options.window.mappings["<S-CR>"], case.name)
      assert.same("system_open", options.window.mappings.O, case.name)
      assert.same("copy_selector", options.window.mappings.Y, case.name)
      assert.same("parent_or_close", options.window.mappings.h, case.name)
      assert.same("child_or_open", options.window.mappings.l, case.name)
      assert.is_false(options.window.mappings["<Space>"], case.name)
      assert.equals(case.watcher_enabled, options.filesystem.use_libuv_file_watcher, case.name)

      options.commands.system_open {
        tree = {
          get_node = function()
            return { get_id = function() return "/workspace/file.txt" end }
          end,
        },
      }
      assert.same({ "/workspace/file.txt" }, calls.opens, case.name)
    end)
  end
end

T["NEO-08 safely delegates navigation with missing targets"] = function()
  local focus_calls = {}
  with_neo_tree({
    loaded = {
      ["neo-tree.ui.renderer"] = {
        focus_node = function(state, id) table.insert(focus_calls, { state = state, id = id }) end,
      },
    },
  }, function(spec)
    local commands = neo_tree_options(spec).commands
    local parent_available = pcall(commands.parent_or_close, {
      tree = {
        get_node = function()
          return {
            has_children = function() return false end,
            get_parent_id = function() return nil end,
          }
        end,
      },
    })
    assert.is_true(parent_available)

    local child_available = pcall(commands.child_or_open, {
      tree = {
        get_node = function()
          return {
            has_children = function() return true end,
            is_expanded = function() return true end,
            type = "directory",
            get_child_ids = function() return {} end,
          }
        end,
      },
    })
    assert.is_true(child_available)
    assert.equals(2, #focus_calls)
    assert.is_nil(focus_calls[1].id)
    assert.is_nil(focus_calls[2].id)
  end)
end

T["NEO-08 keeps repeated AstroNvim-owned handlers idempotent"] = function()
  with_neo_tree(nil, function(spec)
    local unrelated_handler = { id = "foreign_buffer_enter", event = "neo_tree_buffer_enter", handler = function() end }
    local options = { event_handlers = { unrelated_handler } }
    options = neo_tree_options(spec, options)
    options = neo_tree_options(spec, options)

    local owned_handlers = 0
    local unrelated_preserved = false
    for _, handler in ipairs(options.event_handlers) do
      if handler == unrelated_handler then unrelated_preserved = true end
      if handler.id == "astronvim_neo_tree_buffer_enter" and handler.event == "neo_tree_buffer_enter" then
        owned_handlers = owned_handlers + 1
      end
    end
    assert.is_true(unrelated_preserved)
    assert.equals(1, owned_handlers)
    assert.equals(2, #options.event_handlers)
  end)
end

return T
