local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_spec(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then return spec end
  end
  error("Missing spec: " .. name)
end

local function expected_call(name, ...) return { name = name, arguments = { n = select("#", ...), ... } } end

local function clear(values)
  for index = #values, 1, -1 do
    table.remove(values, index)
  end
end

local function with_mini_icons(options, callback)
  options = options or {}
  local calls = {}
  local mini_icons = {
    mock_nvim_web_devicons = function()
      table.insert(calls, { name = "mock_nvim_web_devicons" })
      package.loaded["nvim-web-devicons"] = { mocked = true }
    end,
    get = function(category, name)
      table.insert(calls, { name = "get", arguments = { n = 2, category, name } })
      if options.get then return options.get(category, name) end
      return "icon:" .. category .. ":" .. name, "MiniIcons" .. category
    end,
  }

  return unit_helpers.with_module("astronvim.plugins.mini-icons", {
    replace_vim = { g = true },
    loaded = {
      ["mini.icons"] = options.mini_icons_available == false and unit_helpers.remove or mini_icons,
      ["nvim-web-devicons"] = unit_helpers.remove,
    },
    preload = options.mini_icons_available == false and {
      ["mini.icons"] = function() error "Mini Icons unavailable" end,
    } or nil,
    vim = { g = { icons_enabled = options.icons_enabled } },
  }, function(spec) callback(spec, calls) end)
end

T["ICONS-01 preloads Mini Icons as the devicons compatibility shim"] = function()
  with_mini_icons(nil, function(spec, calls)
    spec.init()
    assert.equals("function", type(package.preload["nvim-web-devicons"]))
    local devicons = require "nvim-web-devicons"
    assert.same({ mocked = true }, devicons)
    assert.same({ { name = "mock_nvim_web_devicons" } }, calls)
  end)
end

T["ICONS-02 selects ASCII mode and semantic Neo-tree icon providers"] = function()
  with_mini_icons({ icons_enabled = false }, function(spec, calls)
    local options = {}
    spec.opts(nil, options)
    assert.equals("ascii", options.style)

    local neo_tree = find_spec(spec.specs, "nvim-neo-tree/neo-tree.nvim")
    local icon_provider = neo_tree.opts.default_component_configs.icon.provider
    local kind_provider = neo_tree.opts.default_component_configs.kind_icon.provider
    local cases = {
      {
        name = "file",
        node = { type = "file", name = "file.lua" },
        expected = { text = "icon:file:file.lua", highlight = "MiniIconsfile" },
        category = "file",
      },
      {
        name = "directory",
        node = { type = "directory", name = "lua", is_expanded = function() return false end },
        expected = { text = "icon:directory:lua", highlight = "MiniIconsdirectory" },
        category = "directory",
      },
      {
        name = "expanded directory",
        node = { type = "directory", name = "lua", is_expanded = function() return true end },
        expected = { text = "unchanged", highlight = "MiniIconsdirectory" },
        category = "directory",
      },
      {
        name = "unknown node",
        node = { type = "message", name = "ignored" },
        expected = { text = "unchanged", highlight = "Existing" },
      },
    }

    for _, case in ipairs(cases) do
      clear(calls)
      local icon = { text = "unchanged", highlight = "Existing" }
      icon_provider(icon, case.node)
      assert.same(case.expected, icon, case.name)
      if case.category then
        assert.same({ { name = "get", arguments = { n = 2, case.category, case.node.name } } }, calls, case.name)
      else
        assert.same({}, calls, case.name)
      end
    end

    clear(calls)
    local kind_icon = {}
    kind_provider(kind_icon, { extra = { kind = { name = "Function" } } })
    assert.same({ text = "icon:lsp:Function", highlight = "MiniIconslsp" }, kind_icon)
    assert.same({ { name = "get", arguments = { n = 2, "lsp", "Function" } } }, calls)
  end)

  with_mini_icons({ icons_enabled = true }, function(spec)
    local options = {}
    spec.opts(nil, options)
    assert.is_nil(options.style)
  end)
end

local function with_which_key(options, callback)
  options = options or {}
  return unit_helpers.with_module("astronvim.plugins.which-key", {
    replace_vim = { g = true },
    vim = { g = { icons_enabled = options.icons_enabled } },
  }, function(spec) callback(spec) end)
end

T["WHICHKEY-01 merges nil and existing icon tables and preserves ASCII declarations"] = function()
  with_which_key({ icons_enabled = true }, function(spec)
    local options = {}
    spec.opts(nil, options)
    assert.equals("", options.icons.group)
    assert.is_false(options.icons.rules)
    assert.equals("-", options.icons.separator)
  end)

  with_which_key({ icons_enabled = true }, function(spec)
    local icons = { keep = "value" }
    local options = { icons = icons }
    spec.opts(nil, options)
    assert.is_true(options.icons == icons)
    assert.equals("value", options.icons.keep)
    assert.equals("", options.icons.group)
  end)

  with_which_key({ icons_enabled = false }, function(spec)
    local options = {}
    spec.opts(nil, options)
    assert.equals(">", options.icons.breadcrumb)
    assert.equals("+", options.icons.group)
    assert.equals("Enter", options.icons.keys.CR)
    assert.equals("Ctrl+", options.icons.keys.C)
    assert.equals("Space", options.icons.keys.Space)
    assert.equals("F12", options.icons.keys.F12)
  end)
end

local function with_aerial(options, callback)
  options = options or {}
  local calls = {}
  local aerial = {}
  for _, method in ipairs { "toggle", "next", "prev", "next_up", "prev_up" } do
    aerial[method] = function(...) table.insert(calls, expected_call("aerial." .. method, ...)) end
  end

  return unit_helpers.with_module("astronvim.plugins.aerial", {
    replace_vim = { v = true },
    loaded = {
      astrocore = {
        extend_tbl = function(_, extension)
          for key, value in pairs(extension) do
            if type(value) == "table" and type(options.initial_options and options.initial_options[key]) == "table" then
              vim.tbl_extend("force", options.initial_options[key], value)
            else
              options.initial_options = options.initial_options or {}
              options.initial_options[key] = value
            end
          end
          return options.initial_options
        end,
        set_mappings = function(mappings, mapping_options)
          table.insert(calls, { name = "astrocore.set_mappings", mappings = mappings, options = mapping_options })
          if options.mappings_by_buffer then
            local buffer_mappings = options.mappings_by_buffer[mapping_options.buffer] or {}
            options.mappings_by_buffer[mapping_options.buffer] = buffer_mappings
            for mode, mode_mappings in pairs(mappings) do
              buffer_mappings[mode] = buffer_mappings[mode] or {}
              for key, mapping in pairs(mode_mappings) do
                buffer_mappings[mode][key] = mapping
              end
            end
          end
        end,
        config = { features = { large_buf = options.large_buf } },
      },
      aerial = aerial,
    },
    vim = { v = { count1 = options.count or 1 } },
  }, function(spec) callback(spec, calls) end)
end

local function apply_aerial_options(spec) return spec.opts(nil, {}) end

T["AERIAL-01 dispatches its outline mapping and scopes attachment mappings to the attached buffer"] = function()
  with_aerial({ count = 4 }, function(spec, calls)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    maps.n["<Leader>lS"][1]()
    assert.same(expected_call "aerial.toggle", calls[1])

    clear(calls)
    local options = apply_aerial_options(spec)
    options.on_attach(18)
    local mapping_call = calls[1]
    assert.equals("astrocore.set_mappings", mapping_call.name)
    assert.same({ buffer = 18 }, mapping_call.options)
    for key, expected in pairs {
      ["]y"] = "aerial.next",
      ["[y"] = "aerial.prev",
      ["]Y"] = "aerial.next_up",
      ["[Y"] = "aerial.prev_up",
    } do
      mapping_call.mappings.n[key][1]()
      assert.same(expected_call(expected, 4), calls[#calls], key)
    end
  end)
end

T["AERIAL-02 applies absent partial and complete large-buffer limits"] = function()
  local cases = {
    { name = "absent", large_buf = nil, lines = nil, size = nil },
    { name = "lines only", large_buf = { lines = 500 }, lines = 500, size = nil },
    { name = "size only", large_buf = { size = 1000 }, lines = nil, size = 1000 },
    { name = "complete", large_buf = { lines = 500, size = 1000 }, lines = 500, size = 1000 },
  }
  for _, case in ipairs(cases) do
    with_aerial({ large_buf = case.large_buf }, function(spec)
      local options = apply_aerial_options(spec)
      assert.equals(case.lines, options.disable_max_lines, case.name)
      assert.equals(case.size, options.disable_max_size, case.name)
      assert.equals("global", options.attach_mode)
      assert.same({ "lsp", "treesitter", "markdown", "man" }, options.backends)
      assert.equals(28, options.layout.min_width)
      assert.is_true(options.show_guides)
      assert.is_false(options.filter_kind)
      assert.equals(false, options.keymaps["{"])
      assert.equals("actions.next", options.keymaps["]y"])
    end)
  end
end

T["WINDOW-01 declares a smart winbar window picker"] = function()
  unit_helpers.with_module("astronvim.plugins.window-picker", nil, function(spec)
    assert.equals("window-picker", spec.main)
    assert.is_true(spec.lazy)
    assert.equals("smart", spec.opts.picker_config.statusline_winbar_picker.use_winbar)
  end)
end

T["COLOR-01 rejects invalid or large buffers and dispatches its toggle mapping"] = function()
  local function with_highlight_colors(valid, large, callback)
    local calls = {}
    unit_helpers.with_module("astronvim.plugins.highlight-colors", {
      loaded = {
        ["astrocore.buffer"] = {
          is_valid = function() return valid end,
          is_large = function() return large end,
        },
      },
      vim = {
        cmd = { HighlightColors = function(...) table.insert(calls, { ... }) end },
      },
    }, function(spec) callback(spec, calls) end)
  end

  for _, case in ipairs {
    { valid = true, large = false, excluded = false },
    { valid = false, large = false, excluded = true },
    { valid = true, large = true, excluded = true },
  } do
    with_highlight_colors(
      case.valid,
      case.large,
      function(spec) assert.equals(case.excluded, spec.opts.exclude_buffer(8)) end
    )
  end

  with_highlight_colors(true, false, function(spec, calls)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    maps.n["<Leader>uz"][1]()
    assert.same({ "Toggle" }, calls[1])
    assert.equals("Toggle color highlight", maps.n["<Leader>uz"].desc)
  end)
end

local function with_todo(options, callback)
  options = options or {}
  local calls = {}
  local preload = {}
  if not options.todo_loaded then
    preload["todo-comments"] = function()
      return {
        jump_next = function(...) table.insert(calls, expected_call("todo-comments.jump_next", ...)) end,
        jump_prev = function(...) table.insert(calls, expected_call("todo-comments.jump_prev", ...)) end,
      }
    end
  end
  if not options.snacks_available then preload.snacks = function() error "Snacks unavailable" end end
  return unit_helpers.with_module("astronvim.plugins.todo-comments", {
    loaded = {
      astrocore = {
        is_available = function(name) return options.snacks_available and name == "snacks.nvim" end,
        plugin_opts = function() return options.snack_opts or {} end,
      },
      lazy = { load = function(...) table.insert(calls, expected_call("lazy.load", ...)) end },
      snacks = options.snacks_available
          and {
            picker = {
              todo_comments = function(...) table.insert(calls, expected_call("snacks.picker.todo_comments", ...)) end,
            },
          }
        or unit_helpers.remove,
      ["todo-comments"] = options.todo_loaded and {
        jump_next = function(...) table.insert(calls, expected_call("todo-comments.jump_next", ...)) end,
        jump_prev = function(...) table.insert(calls, expected_call("todo-comments.jump_prev", ...)) end,
      } or unit_helpers.remove,
    },
    preload = preload,
  }, function(spec) callback(spec, calls) end)
end

T["TODO-01 lazy-loads Snacks searches and declares backend precedence without a fallback mapping"] = function()
  with_todo({ snacks_available = true }, function(spec, calls)
    assert.equals("User AstroFile", spec.event)
    assert.same({ "TodoTrouble", "TodoLocList", "TodoQuickFix" }, spec.cmd)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    maps.n["<Leader>fT"][1]()
    assert.same(expected_call("lazy.load", { plugins = { "todo-comments.nvim" } }), calls[1])
    assert.same(expected_call "snacks.picker.todo_comments", calls[2])
  end)

  with_todo({ snacks_available = true, todo_loaded = true }, function(spec, calls)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    maps.n["<Leader>fT"][1]()
    assert.same({ expected_call "snacks.picker.todo_comments" }, calls)
    maps.n["]T"][1]()
    maps.n["[T"][1]()
    assert.same(expected_call "todo-comments.jump_next", calls[2])
    assert.same(expected_call "todo-comments.jump_prev", calls[3])
  end)

  local backend_cases = {
    { name = "no backend", expected = nil },
    { name = "Snacks", snacks = true, expected = "function" },
    { name = "Telescope", telescope = true, expected = "<Cmd>TodoTelescope<CR>" },
    { name = "fzf-lua", fzf = true, expected = "<Cmd>TodoFzfLua<CR>" },
    { name = "Telescope over Snacks", snacks = true, telescope = true, expected = "<Cmd>TodoTelescope<CR>" },
    { name = "fzf-lua over Snacks", snacks = true, fzf = true, expected = "<Cmd>TodoFzfLua<CR>" },
    { name = "fzf-lua over Telescope", telescope = true, fzf = true, expected = "<Cmd>TodoFzfLua<CR>" },
    { name = "fzf-lua over all", snacks = true, telescope = true, fzf = true, expected = "<Cmd>TodoFzfLua<CR>" },
  }
  for _, case in ipairs(backend_cases) do
    with_todo({ snacks_available = case.snacks }, function(spec)
      local maps = { n = {} }
      find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
      for _, backend in ipairs {
        { enabled = case.telescope, name = "nvim-telescope/telescope.nvim" },
        { enabled = case.fzf, name = "ibhagwan/fzf-lua" },
      } do
        if backend.enabled then
          local backend_spec = find_spec(spec.specs, backend.name)
          local core_spec = find_spec(backend_spec.specs, "AstroNvim/astrocore")
          maps = vim.tbl_deep_extend("force", maps, core_spec.opts.mappings)
        end
      end

      local mapping = maps.n["<Leader>fT"]
      if case.expected == nil then
        assert.is_nil(mapping, case.name)
      elseif case.expected == "function" then
        assert.equals("function", type(mapping[1]), case.name)
      else
        assert.equals(case.expected, mapping[1], case.name)
      end
    end)
  end

  with_todo({ snacks_available = true, snack_opts = { picker = { enabled = false } } }, function(spec)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    assert.is_nil(maps.n["<Leader>fT"])
  end)
end

T["ICONS-02 propagates Mini Icons provider errors"] = function()
  with_mini_icons({ get = function() error "provider failure" end }, function(spec)
    local icon_provider =
      find_spec(spec.specs, "nvim-neo-tree/neo-tree.nvim").opts.default_component_configs.icon.provider
    local available, message = pcall(icon_provider, {}, { type = "file", name = "file.lua" })
    assert.is_false(available)
    assert.is_true(message:find("provider failure", 1, true) ~= nil)
  end)
end

T["AERIAL-03 keeps attachment mappings buffer-local across repeated attaches"] = function()
  local mappings_by_buffer = {}
  with_aerial({ mappings_by_buffer = mappings_by_buffer }, function(spec)
    local options = apply_aerial_options(spec)
    options.on_attach(18)
    options.on_attach(41)
    options.on_attach(18)

    assert.is_nil(mappings_by_buffer[99])
    for _, buffer in ipairs { 18, 41 } do
      local maps = mappings_by_buffer[buffer]
      assert.equals("function", type(maps.n["]y"][1]))
      assert.equals("function", type(maps.n["[y"][1]))
      assert.equals("function", type(maps.n["]Y"][1]))
      assert.equals("function", type(maps.n["[Y"][1]))
    end
  end)
end

T["COLOR-02 exposes resolved loading triggers and dispatches its owned mapping"] = function()
  local calls = {}
  unit_helpers.with_module("astronvim.plugins.highlight-colors", {
    loaded = {
      ["astrocore.buffer"] = {
        is_valid = function() return true end,
        is_large = function() return false end,
      },
    },
    vim = {
      cmd = { HighlightColors = function(...) table.insert(calls, { ... }) end },
    },
  }, function(spec)
    assert.equals("HighlightColors", spec.cmd)
    assert.is_true(vim.tbl_contains(spec.event, "User AstroFile"))
    assert.is_true(vim.tbl_contains(spec.event, "InsertEnter"))

    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    local before = #calls
    maps.n["<Leader>uz"][1]()
    assert.equals(before + 1, #calls)
    assert.same({ "Toggle" }, calls[#calls])
  end)
end

T["TODO-02 keeps navigation independent from search backends and hands off lazy loading"] = function()
  with_todo({ todo_loaded = true }, function(spec, calls)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    assert.is_nil(maps.n["<Leader>fT"])

    local before = #calls
    maps.n["]T"][1]()
    assert.equals(before + 1, #calls)
    assert.same(expected_call "todo-comments.jump_next", calls[#calls])
    maps.n["[T"][1]()
    assert.equals(before + 2, #calls)
    assert.same(expected_call "todo-comments.jump_prev", calls[#calls])
  end)

  with_todo({ snacks_available = true }, function(spec, calls)
    local maps = { n = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
    local before = #calls
    maps.n["<Leader>fT"][1]()
    assert.equals(before + 2, #calls)
    assert.same(expected_call("lazy.load", { plugins = { "todo-comments.nvim" } }), calls[before + 1])
    assert.same(expected_call "snacks.picker.todo_comments", calls[before + 2])
  end)

  for _, case in ipairs {
    { name = "no backend" },
    { name = "Snacks", snacks = true, expected = "function" },
    { name = "Telescope over Snacks", snacks = true, telescope = true, expected = "<Cmd>TodoTelescope<CR>" },
    { name = "fzf-lua over all", snacks = true, telescope = true, fzf = true, expected = "<Cmd>TodoFzfLua<CR>" },
  } do
    with_todo({ snacks_available = case.snacks }, function(spec)
      local maps = { n = {} }
      find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, { mappings = maps })
      for _, backend in ipairs {
        { enabled = case.telescope, name = "nvim-telescope/telescope.nvim" },
        { enabled = case.fzf, name = "ibhagwan/fzf-lua" },
      } do
        if backend.enabled then
          local backend_spec = find_spec(spec.specs, backend.name)
          maps = vim.tbl_deep_extend("force", maps, find_spec(backend_spec.specs, "AstroNvim/astrocore").opts.mappings)
        end
      end
      local mapping = maps.n["<Leader>fT"]
      if case.expected == nil then
        assert.is_nil(mapping, case.name)
      elseif case.expected == "function" then
        assert.equals("function", type(mapping[1]), case.name)
      else
        assert.equals(case.expected, mapping[1], case.name)
      end
    end)
  end
end

return T
