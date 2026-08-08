local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_spec(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then return spec end
  end
  error("Missing spec: " .. name)
end

local function record(calls, name, ...) table.insert(calls, { name = name, arguments = { n = select("#", ...), ... } }) end

local function expected_call(name, ...) return { name = name, arguments = { n = select("#", ...), ... } } end

local function clear(values)
  for index = #values, 1, -1 do
    table.remove(values, index)
  end
end

local function with_snacks(options, callback)
  options = options or {}
  local calls = {}
  local snacks = { picker = {}, toggle = {}, words = {} }
  for _, method in ipairs {
    "resume",
    "marks",
    "lines",
    "files",
    "buffers",
    "grep_word",
    "commands",
    "git_files",
    "help",
    "keymaps",
    "man",
    "notifications",
    "recent",
    "projects",
    "registers",
    "smart",
    "colorschemes",
    "grep",
    "undo",
    "diagnostics",
    "lsp_symbols",
    "git_branches",
    "git_log",
    "git_status",
    "git_stash",
  } do
    snacks.picker[method] = function(...) record(calls, "picker." .. method, ...) end
  end
  snacks.dashboard = function(...) record(calls, "dashboard", ...) end
  snacks.gitbrowse = function(...) record(calls, "gitbrowse", ...) end
  snacks.words.jump = function(...) record(calls, "words.jump", ...) end
  for _, name in ipairs { "indent", "words", "zen" } do
    snacks.toggle[name] = function()
      return { toggle = function() record(calls, "toggle." .. name) end }
    end
  end

  local buffer_vars = options.buffer_vars or { [7] = {} }
  local tools = options.tools or { git = 1, rg = 1 }
  return unit_helpers.with_module("astronvim.plugins.snacks", {
    replace_vim = { b = true, bo = true, fn = true, g = true, uv = true, v = true },
    loaded = {
      astroui = { get_icon = function(name) return "icon:" .. name end },
      astrocore = {
        plugin_opts = function() return options.snack_opts or {} end,
      },
      ["astrocore.buffer"] = {
        close = function(...) record(calls, "buffer.close", ...) end,
        is_valid = function(bufnr) return options.valid_buffers == nil or options.valid_buffers[bufnr] ~= false end,
        is_large = function(bufnr) return options.large_buffers and options.large_buffers[bufnr] or false end,
      },
      snacks = snacks,
      ["snacks.notifier"] = { hide = function(...) record(calls, "notifier.hide", ...) end },
      aerial = options.aerial,
    },
    preload = options.aerial == nil and {
      aerial = function() error "Aerial unavailable" end,
    } or nil,
    vim = {
      b = buffer_vars,
      bo = { filetype = options.filetype or "" },
      fn = {
        executable = function(name) return tools[name] or 0 end,
        stdpath = function(name)
          assert.equals("config", name)
          return "/config"
        end,
      },
      g = options.globals or {},
      uv = {
        fs_stat = function(path)
          assert.equals(".git", path)
          return options.git_directory and { type = "directory" } or { type = "file" }
        end,
      },
      v = { count1 = options.count or 1 },
    },
  }, function(specs) callback(specs, calls, buffer_vars) end)
end

local function snack_options(specs, options)
  options = options or {}
  specs.opts(nil, options)
  return options
end

local function snack_maps(specs)
  local maps = { n = {}, x = {} }
  local core = find_spec(specs.specs, "AstroNvim/astrocore")
  core.opts(nil, { mappings = maps, _map_sections = { f = { desc = "Find" }, g = { desc = "Git" } } })
  return maps
end

local function invoke(maps, mode, key)
  assert.equals("function", type(maps[mode][key][1]), key)
  maps[mode][key][1]()
end

T["SNACKS-02 filters indent scope and words by buffer and feature state"] = function()
  local cases = {
    { name = "valid", valid = true, large = false, globals = {}, buffer = {}, expected = true },
    { name = "invalid", valid = false, large = false, globals = {}, buffer = {}, expected = false },
    { name = "large", valid = true, large = true, globals = {}, buffer = {}, expected = false },
    {
      name = "global indent",
      valid = true,
      large = false,
      globals = { snacks_indent = false },
      buffer = {},
      expected = false,
      feature = "indent",
    },
    {
      name = "global scope",
      valid = true,
      large = false,
      globals = { snacks_scope = false },
      buffer = {},
      expected = false,
      feature = "scope",
    },
    {
      name = "global words",
      valid = true,
      large = false,
      globals = { snacks_words = false },
      buffer = {},
      expected = false,
      feature = "words",
    },
    {
      name = "buffer indent",
      valid = true,
      large = false,
      globals = {},
      buffer = { snacks_indent = false },
      expected = false,
      feature = "indent",
    },
    {
      name = "buffer scope",
      valid = true,
      large = false,
      globals = {},
      buffer = { snacks_scope = false },
      expected = false,
      feature = "scope",
    },
    {
      name = "buffer words",
      valid = true,
      large = false,
      globals = {},
      buffer = { snacks_words = false },
      expected = false,
      feature = "words",
    },
  }

  for _, case in ipairs(cases) do
    with_snacks({
      valid_buffers = { [7] = case.valid },
      large_buffers = { [7] = case.large },
      globals = case.globals,
      buffer_vars = { [7] = case.buffer },
    }, function(specs)
      local options = snack_options(specs)
      for _, feature in ipairs(case.feature and { case.feature } or { "indent", "scope", "words" }) do
        assert.equals(case.expected, options[feature].filter(7), case.name .. ": " .. feature)
      end
    end)
  end
end

T["SNACKS-03 restores nil true and false indent state after Zen mode"] = function()
  for _, case in ipairs { { name = "nil" }, { name = "true", prior = true }, { name = "false", prior = false } } do
    local buffer = { snacks_indent = case.prior }
    with_snacks({ buffer_vars = { [7] = buffer } }, function(specs)
      local zen = snack_options(specs).zen
      zen.on_open { buf = 7 }
      assert.is_false(buffer.snacks_indent)
      zen.on_close { buf = 7 }
      assert.equals(case.prior, buffer.snacks_indent, case.name)
    end)
  end
end

T["SNACKS-04 dispatches every global picker mapping through public picker methods"] = function()
  with_snacks({ git_directory = true }, function(specs, calls)
    local maps = snack_maps(specs)
    local mappings = {
      { "<Leader>f<CR>", "picker.resume" },
      { "<Leader>f'", "picker.marks" },
      { "<Leader>fl", "picker.lines" },
      { "<Leader>fa", "picker.files", { dirs = { "/config" }, desc = "Config Files" } },
      { "<Leader>fb", "picker.buffers" },
      { "<Leader>fc", "picker.grep_word" },
      { "<Leader>fC", "picker.commands" },
      { "<Leader>ff", "picker.files", { hidden = true } },
      { "<Leader>fF", "picker.files", { hidden = true, ignored = true } },
      { "<Leader>fg", "picker.git_files" },
      { "<Leader>fh", "picker.help" },
      { "<Leader>fk", "picker.keymaps" },
      { "<Leader>fm", "picker.man" },
      { "<Leader>fn", "picker.notifications" },
      { "<Leader>fo", "picker.recent" },
      { "<Leader>fO", "picker.recent", { filter = { cwd = true } } },
      { "<Leader>fp", "picker.projects" },
      { "<Leader>fr", "picker.registers" },
      { "<Leader>fs", "picker.smart" },
      { "<Leader>ft", "picker.colorschemes" },
      { "<Leader>fw", "picker.grep" },
      { "<Leader>fW", "picker.grep", { hidden = true, ignored = true } },
      { "<Leader>fu", "picker.undo" },
      { "<Leader>lD", "picker.diagnostics" },
      { "<Leader>gb", "picker.git_branches" },
      { "<Leader>gc", "picker.git_log" },
      { "<Leader>gC", "picker.git_log", { current_file = true, follow = true } },
      { "<Leader>gt", "picker.git_status" },
      { "<Leader>gT", "picker.git_stash" },
    }

    for _, mapping in ipairs(mappings) do
      clear(calls)
      invoke(maps, "n", mapping[1])
      local expected = mapping[3] and expected_call(mapping[2], mapping[3]) or expected_call(mapping[2])
      assert.same(expected, calls[1], mapping[1])
    end
    assert.same({ desc = "Find" }, maps.n["<Leader>f"])
    assert.same({ desc = "Git" }, maps.n["<Leader>g"])
  end)

  with_snacks({ git_directory = false }, function(specs, calls)
    local maps = snack_maps(specs)
    invoke(maps, "n", "<Leader>ff")
    assert.same(expected_call("picker.files", { hidden = false }), calls[1])
  end)
end

T["SNACKS-04 dispatches every Neo-tree picker command from file and directory nodes"] = function()
  with_snacks(nil, function(specs, calls)
    local neo_tree = find_spec(specs.specs, "nvim-neo-tree/neo-tree.nvim")
    local commands = neo_tree.opts.commands
    local mappings = neo_tree.opts.filesystem.window.mappings
    assert.same({ "show_help", nowait = false, config = { title = "Find Files", prefix_key = "f" } }, mappings.f)
    assert.equals("filter_on_submit", mappings["f/"])
    assert.equals("find_files_in_dir", mappings.ff)
    assert.equals("find_all_files_in_dir", mappings.fF)
    assert.equals("find_words_in_dir", mappings.fw)
    assert.equals("find_all_words_in_dir", mappings.fW)

    for _, node_case in ipairs {
      { type = "file", parent = "/parent", id = "/file" },
      { type = "directory", parent = "/unused", id = "/directory" },
    } do
      local node = {
        type = node_case.type,
        get_parent_id = function() return node_case.parent end,
        get_id = function() return node_case.id end,
      }
      local state = { tree = { get_node = function() return node end } }
      local path = node_case.type == "file" and node_case.parent or node_case.id
      for _, command in ipairs {
        { "find_files_in_dir", "picker.files", { cwd = path } },
        { "find_all_files_in_dir", "picker.files", { cwd = path, hidden = true, ignored = true } },
        { "find_words_in_dir", "picker.grep", { cwd = path } },
        { "find_all_words_in_dir", "picker.grep", { cwd = path, hidden = true, ignored = true } },
      } do
        clear(calls)
        commands[command[1]](state)
        assert.same(expected_call(command[2], command[3]), calls[1], node_case.type .. ": " .. command[1])
      end
    end
  end)
end

T["SNACKS-04 preserves picker-related mapping gates"] = function()
  with_snacks(nil, function(specs, calls)
    local maps = snack_maps(specs)
    invoke(maps, "n", "<Leader>go")
    assert.same(expected_call "gitbrowse", calls[1])
    clear(calls)
    invoke(maps, "x", "<Leader>go")
    assert.same(expected_call "gitbrowse", calls[1])
  end)

  local picker_keys = {
    "<Leader>f",
    "<Leader>f<CR>",
    "<Leader>f'",
    "<Leader>fl",
    "<Leader>fa",
    "<Leader>fb",
    "<Leader>fc",
    "<Leader>fC",
    "<Leader>ff",
    "<Leader>fF",
    "<Leader>fg",
    "<Leader>fh",
    "<Leader>fk",
    "<Leader>fm",
    "<Leader>fn",
    "<Leader>fo",
    "<Leader>fO",
    "<Leader>fp",
    "<Leader>fr",
    "<Leader>fs",
    "<Leader>ft",
    "<Leader>fw",
    "<Leader>fW",
    "<Leader>fu",
    "<Leader>lD",
    "<Leader>ls",
    "<Leader>gb",
    "<Leader>gc",
    "<Leader>gC",
    "<Leader>gt",
    "<Leader>gT",
  }
  with_snacks({ snack_opts = { picker = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    for _, key in ipairs(picker_keys) do
      assert.is_nil(maps.n[key], key)
    end
    assert.is_true(maps.n["<Leader>uD"] ~= nil)
    assert.is_true(maps.n["<Leader>ur"] ~= nil)
    assert.is_true(maps.n["]r"] ~= nil)
    assert.is_true(maps.n["[r"] ~= nil)
    assert.is_true(maps.n["<Leader>uZ"] ~= nil)
    assert.is_true(maps.n["<Leader>go"] ~= nil)
    assert.is_true(maps.x["<Leader>go"] ~= nil)
  end)

  with_snacks({ snack_opts = { notifier = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>uD"])
    assert.is_true(maps.n["<Leader>fn"] ~= nil)
  end)

  with_snacks({ snack_opts = { gitbrowse = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>go"])
    assert.is_nil(maps.x["<Leader>go"])
    assert.is_true(maps.n["<Leader>gb"] ~= nil)
  end)

  with_snacks({ snack_opts = { words = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>ur"])
    assert.is_nil(maps.n["]r"])
    assert.is_nil(maps.n["[r"])
    assert.is_true(maps.n["<Leader>uD"] ~= nil)
    assert.is_true(maps.n["<Leader>uZ"] ~= nil)
  end)

  with_snacks({ snack_opts = { zen = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>uZ"])
    assert.is_true(maps.n["<Leader>ur"] ~= nil)
  end)

  with_snacks({ tools = { git = 0, rg = 1 } }, function(specs)
    local maps = snack_maps(specs)
    for _, key in ipairs {
      "<Leader>g",
      "<Leader>gb",
      "<Leader>gc",
      "<Leader>gC",
      "<Leader>gt",
      "<Leader>gT",
      "<Leader>go",
    } do
      assert.is_nil(maps.n[key], key)
    end
    assert.is_nil(maps.x["<Leader>go"])
    assert.is_true(maps.n["<Leader>fg"] ~= nil)
    assert.is_true(maps.n["<Leader>fw"] ~= nil)
    assert.is_true(maps.n["<Leader>fW"] ~= nil)
  end)

  with_snacks({ tools = { git = 1, rg = 0 } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>fw"])
    assert.is_nil(maps.n["<Leader>fW"])
    assert.is_true(maps.n["<Leader>gb"] ~= nil)
    assert.is_true(maps.n["<Leader>go"] ~= nil)
    assert.is_true(maps.x["<Leader>go"] ~= nil)
    local neo_tree = find_spec(specs.specs, "nvim-neo-tree/neo-tree.nvim")
    assert.is_nil(neo_tree.opts.filesystem.window.mappings.fw)
    assert.is_nil(neo_tree.opts.filesystem.window.mappings.fW)
  end)
end

T["SNACKS-05 prefers Aerial's Snacks picker and falls back to Snacks symbols"] = function()
  local aerial_calls = {}
  with_snacks({ aerial = { snacks_picker = function() table.insert(aerial_calls, true) end } }, function(specs, calls)
    invoke(snack_maps(specs), "n", "<Leader>ls")
    assert.same({ true }, aerial_calls)
    assert.equals(0, #calls)
  end)

  with_snacks(nil, function(specs, calls)
    invoke(snack_maps(specs), "n", "<Leader>ls")
    assert.same(expected_call "picker.lsp_symbols", calls[1])
  end)
end

T["SNACKS-06 dispatches notification and reference navigation mappings"] = function()
  with_snacks({ count = 3 }, function(specs, calls)
    local maps = snack_maps(specs)
    invoke(maps, "n", "<Leader>uD")
    assert.same(expected_call "notifier.hide", calls[#calls])
    invoke(maps, "n", "<Leader>ur")
    assert.same(expected_call "toggle.words", calls[#calls])
    invoke(maps, "n", "]r")
    assert.same(expected_call("words.jump", 3), calls[#calls])
    invoke(maps, "n", "[r")
    assert.same(expected_call("words.jump", -3), calls[#calls])
  end)
end

T["SNACKS-07 keeps selected dashboard notifier picker image input and Zen declarations"] = function()
  with_snacks(nil, function(specs)
    local options = snack_options(specs)
    assert.equals(false, options.image.doc.enabled)
    assert.same({}, options.input)
    assert.is_true(options.picker.ui_select)
    assert.equals("icon:DiagnosticError", options.notifier.icons.error)
    assert.equals("icon:DiagnosticWarn", options.notifier.icons.warn)
    assert.equals(false, options.zen.toggles.dim)
    assert.equals(false, options.zen.toggles.diagnostics)
    assert.equals(false, options.zen.toggles.inlay_hints)
    assert.equals(false, options.zen.win.wo.number)
    assert.equals("", options.zen.win.wo.winbar)
    assert.equals(3, #options.dashboard.sections)
    assert.equals("<Leader>n", options.dashboard.preset.keys[1].action)
    assert.equals("<Leader>ff", options.dashboard.preset.keys[2].action)
    assert.equals("<Leader>Sl", options.dashboard.preset.keys[6].action)
  end)
end

T["SNACKS-08 preserves Zen state and keeps owned mapping dispatch and gates isolated"] = function()
  for _, case in ipairs { { name = "nil" }, { name = "true", prior = true }, { name = "false", prior = false } } do
    local buffer = { snacks_indent = case.prior }
    with_snacks({ buffer_vars = { [7] = buffer } }, function(specs)
      local zen = snack_options(specs).zen
      for _ = 1, 2 do
        zen.on_open { buf = 7 }
        assert.is_false(buffer.snacks_indent, case.name .. ": open")
        zen.on_close { buf = 7 }
        assert.equals(case.prior, buffer.snacks_indent, case.name .. ": repeated close")
      end
    end)
  end

  with_snacks({ filetype = "" }, function(specs, calls)
    local maps = snack_maps(specs)
    local before = #calls
    invoke(maps, "n", "<Leader>h")
    assert.equals(before + 1, #calls)
    assert.same(expected_call "dashboard", calls[#calls])

    before = #calls
    invoke(maps, "n", "<Leader>u|")
    assert.equals(before + 1, #calls)
    assert.same(expected_call "toggle.indent", calls[#calls])

    before = #calls
    invoke(maps, "n", "<Leader>uZ")
    assert.equals(before + 1, #calls)
    assert.same(expected_call "toggle.zen", calls[#calls])
  end)

  with_snacks({ filetype = "snacks_dashboard" }, function(specs, calls)
    local maps = snack_maps(specs)
    local before = #calls
    invoke(maps, "n", "<Leader>h")
    assert.equals(before + 1, #calls)
    assert.same(expected_call "buffer.close", calls[#calls])
  end)

  with_snacks({ snack_opts = { picker = { enabled = false } } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>ff"])
    assert.equals("function", type(maps.n["<Leader>go"][1]))
  end)

  with_snacks({ tools = { git = 0, rg = 1 } }, function(specs)
    local maps = snack_maps(specs)
    assert.is_nil(maps.n["<Leader>go"])
    assert.is_nil(maps.x["<Leader>go"])
    assert.is_nil(maps.n["<Leader>gb"])
    assert.equals("function", type(maps.n["<Leader>ff"][1]))
  end)
end

return T
