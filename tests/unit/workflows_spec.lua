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

local function invoke(maps, mode, key)
  assert.equals("function", type(maps[mode][key][1]), key)
  maps[mode][key][1]()
end

local function with_gitsigns(options, callback)
  options = options or {}
  local calls = { gitsigns = {}, mappings = {} }
  local gitsigns = {}
  for _, name in ipairs {
    "blame_line",
    "preview_hunk_inline",
    "reset_hunk",
    "reset_buffer",
    "stage_hunk",
    "stage_buffer",
    "diffthis",
    "nav_hunk",
  } do
    gitsigns[name] = function(...) record(calls.gitsigns, name, ...) end
  end

  return unit_helpers.with_module("astronvim.plugins.gitsigns", {
    loaded = {
      astrocore = {
        config = { git_worktrees = options.worktrees or {} },
        empty_map_table = function() return { n = {}, v = {}, o = {}, x = {} } end,
        extend_tbl = function(base, extension) return vim.tbl_deep_extend("force", base, extension) end,
        set_mappings = function(maps, mapping_options)
          table.insert(calls.mappings, { maps = maps, options = mapping_options })
        end,
      },
      astroui = { get_icon = function(name) return "icon:" .. name end },
      gitsigns = gitsigns,
    },
    vim = {
      fn = {
        executable = function(name) return name == "git" and (options.git_available == false and 0 or 1) or 0 end,
        line = function(mark) return ({ ["."] = 8, v = 3 })[mark] end,
      },
    },
  }, function(spec) return callback(spec, calls) end)
end

local function with_toggleterm(options, callback)
  options = options or {}
  local calls = { terminals = {} }
  local terminal = {
    new = function(_, terminal_options)
      table.insert(calls.terminals, terminal_options)
      return { toggle = function() calls.toggled = (calls.toggled or 0) + 1 end }
    end,
  }
  local astrocore = {
    file_worktree = function() return options.worktree end,
    toggle_term_cmd = function(value) record(calls, "toggle_term_cmd", value) end,
  }

  return unit_helpers.with_module("astronvim.plugins.toggleterm", {
    loaded = {
      astrocore = astrocore,
      ["toggleterm.terminal"] = { Terminal = terminal },
    },
    vim = {
      fn = {
        executable = function(name) return (options.tools or {})[name] or 0 end,
        has = function(feature) return (options.features or {})[feature] or 0 end,
        shellescape = function(value) return "<" .. value .. ">" end,
      },
    },
  }, function(spec) return callback(spec, calls) end)
end

local function core_mappings(spec)
  local opts =
    { mappings = { n = {}, t = {}, i = {} }, _map_sections = { g = { desc = "Git" }, t = { desc = "Terminal" } } }
  find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, opts)
  return opts.mappings
end

local function with_resession(options, callback)
  options = options or {}
  local calls = { session = {}, valid_session = 0, restorable = {} }
  local resession = {}
  for _, name in ipairs { "load", "save", "save_tab", "delete" } do
    resession[name] = function(...) record(calls.session, name, ...) end
  end

  return unit_helpers.with_module("astronvim.plugins.resession", {
    replace_vim = { t = true, uv = true },
    loaded = {
      astrocore = {
        config = { sessions = { autosave = options.autosave } },
      },
      ["astrocore.buffer"] = {
        is_valid_session = function()
          calls.valid_session = calls.valid_session + 1
          return options.valid_session ~= false
        end,
        is_restorable = function(bufnr)
          table.insert(calls.restorable, bufnr)
          return options.restorable ~= false
        end,
      },
      resession = resession,
    },
    vim = {
      t = options.tab_buffers or {},
      uv = { cwd = function() return "/workspace" end },
    },
  }, function(spec) return callback(spec, calls) end)
end

local function with_smart_splits(options, callback)
  options = options or {}
  local calls = {}
  local smart_splits = {}
  for _, name in ipairs {
    "move_cursor_left",
    "move_cursor_down",
    "move_cursor_up",
    "move_cursor_right",
    "resize_up",
    "resize_down",
    "resize_left",
    "resize_right",
  } do
    smart_splits[name] = function() table.insert(calls, name) end
  end

  return unit_helpers.with_module("astronvim.plugins.smart-splits", {
    replace_vim = { env = true },
    loaded = { ["smart-splits"] = smart_splits },
    vim = { env = options.environment or {} },
  }, function(spec) return callback(spec, calls) end)
end

T["GIT-01 gates Gitsigns and preserves AstroNvim-owned configuration"] = function()
  with_gitsigns({ git_available = true, worktrees = { "/workspace" } }, function(spec)
    assert.is_true(spec.enabled)
    assert.equals("User AstroGitFile", spec.event)

    local options = spec.opts(nil, {
      signs = { custom = { text = "custom" } },
      signs_staged = { custom = { text = "staged" } },
    })
    for _, sign in ipairs { "add", "change", "delete", "topdelete", "changedelete", "untracked" } do
      assert.equals("icon:GitSign", options.signs[sign].text, sign)
      assert.equals("icon:GitSign", options.signs_staged[sign].text, "staged " .. sign)
    end
    assert.equals("custom", options.signs.custom.text)
    assert.equals("staged", options.signs_staged.custom.text)
    assert.same({ "/workspace" }, options.worktrees)
  end)

  with_gitsigns({ git_available = false }, function(spec) assert.is_false(spec.enabled) end)
end

T["GIT-02 dispatches Gitsigns normal visual and operator mappings"] = function()
  with_gitsigns(nil, function(spec, calls)
    local options = spec.opts(nil, {})
    options.on_attach(41)
    assert.equals(1, #calls.mappings)
    local maps = calls.mappings[1].maps
    assert.same({ buffer = 41 }, calls.mappings[1].options)

    local normal_cases = {
      { key = "<Leader>gl", call = expected_call "blame_line" },
      { key = "<Leader>gL", call = expected_call("blame_line", { full = true }) },
      { key = "<Leader>gp", call = expected_call "preview_hunk_inline" },
      { key = "<Leader>gr", call = expected_call "reset_hunk" },
      { key = "<Leader>gR", call = expected_call "reset_buffer" },
      { key = "<Leader>gs", call = expected_call "stage_hunk" },
      { key = "<Leader>gS", call = expected_call "stage_buffer" },
      { key = "<Leader>gd", call = expected_call "diffthis" },
      { key = "[G", call = expected_call("nav_hunk", "first") },
      { key = "]G", call = expected_call("nav_hunk", "last") },
      { key = "]g", call = expected_call("nav_hunk", "next") },
      { key = "[g", call = expected_call("nav_hunk", "prev") },
    }
    for _, case in ipairs(normal_cases) do
      local call_count = #calls.gitsigns
      invoke(maps, "n", case.key)
      assert.equals(call_count + 1, #calls.gitsigns, case.key)
      assert.same(case.call, calls.gitsigns[#calls.gitsigns], case.key)
    end

    local call_count = #calls.gitsigns
    invoke(maps, "v", "<Leader>gr")
    assert.equals(call_count + 1, #calls.gitsigns)
    assert.same(expected_call("reset_hunk", { 8, 3 }), calls.gitsigns[#calls.gitsigns])
    call_count = #calls.gitsigns
    invoke(maps, "v", "<Leader>gs")
    assert.equals(call_count + 1, #calls.gitsigns)
    assert.same(expected_call("stage_hunk", { 8, 3 }), calls.gitsigns[#calls.gitsigns])
    assert.equals(":<C-U>Gitsigns select_hunk<CR>", maps.o.ig[1])
    assert.equals(":<C-U>Gitsigns select_hunk<CR>", maps.x.ig[1])
  end)
end

T["GIT-03 owns Gitsigns mapping metadata and buffer scope"] = function()
  with_gitsigns({ worktrees = { "/workspace/one", "/workspace/two" } }, function(spec, calls)
    assert.equals("lewis6991/gitsigns.nvim", spec[1])
    assert.is_true(spec.enabled)
    assert.equals("User AstroGitFile", spec.event)

    local options = spec.opts(nil, {})
    assert.same({ "/workspace/one", "/workspace/two" }, options.worktrees)
    options.on_attach(73)
    assert.equals(1, #calls.mappings)
    assert.same({ buffer = 73 }, calls.mappings[1].options)

    local maps = calls.mappings[1].maps
    for _, mode in ipairs { "n", "v" } do
      assert.equals("icon:GitGit", maps[mode]["<Leader>g"].desc, mode)
    end
    local descriptions = {
      ["<Leader>gl"] = "View Git blame",
      ["<Leader>gL"] = "View full Git blame",
      ["<Leader>gp"] = "Preview Git hunk",
      ["<Leader>gr"] = "Reset Git hunk",
      ["<Leader>gR"] = "Reset Git buffer",
      ["<Leader>gs"] = "Stage/Unstage Git hunk",
      ["<Leader>gS"] = "Stage Git buffer",
      ["<Leader>gd"] = "View Git diff",
      ["[G"] = "First Git hunk",
      ["]G"] = "Last Git hunk",
      ["]g"] = "Next Git hunk",
      ["[g"] = "Previous Git hunk",
    }
    for key, description in pairs(descriptions) do
      assert.equals(description, maps.n[key].desc, key)
    end
    assert.equals("Reset Git hunk", maps.v["<Leader>gr"].desc)
    assert.equals("Stage Git hunk", maps.v["<Leader>gs"].desc)
    for _, mode in ipairs { "o", "x" } do
      assert.equals("inside Git hunk", maps[mode].ig.desc, mode)
    end
  end)
end

T["TERM-01 installs terminal mappings only for available executables"] = function()
  local cases = {
    {
      name = "all tools available",
      tools = { git = 1, lazygit = 1, node = 1, gdu = 1, btm = 1, python = 1, python3 = 1 },
      expected = { "<Leader>g", "<Leader>gg", "<Leader>tl", "<Leader>tn", "<Leader>tu", "<Leader>tt", "<Leader>tp" },
      dispatch = {
        { key = "<Leader>tn", call = expected_call("toggle_term_cmd", "node") },
        { key = "<Leader>tu", call = expected_call("toggle_term_cmd", { cmd = "gdu", direction = "float" }) },
        { key = "<Leader>tt", call = expected_call("toggle_term_cmd", { cmd = "btm", direction = "float" }) },
        { key = "<Leader>tp", call = expected_call("toggle_term_cmd", "python") },
      },
    },
    {
      name = "no optional tools",
      tools = {},
      expected = {},
    },
    {
      name = "Windows gdu fallback",
      tools = { ["gdu_windows_amd64.exe"] = 1 },
      features = { win32 = 1 },
      expected = { "<Leader>tu" },
      dispatch = {
        {
          key = "<Leader>tu",
          call = expected_call("toggle_term_cmd", { cmd = "gdu_windows_amd64.exe", direction = "float" }),
        },
      },
    },
    {
      name = "macOS gdu fallback",
      tools = { ["gdu-go"] = 1 },
      features = { mac = 1 },
      expected = { "<Leader>tu" },
      dispatch = {
        { key = "<Leader>tu", call = expected_call("toggle_term_cmd", { cmd = "gdu-go", direction = "float" }) },
      },
    },
    {
      name = "Python3 fallback",
      tools = { python3 = 1 },
      expected = { "<Leader>tp" },
      dispatch = { { key = "<Leader>tp", call = expected_call("toggle_term_cmd", "python3") } },
    },
    { name = "Git without LazyGit", tools = { git = 1 }, expected = {} },
    { name = "LazyGit without Git", tools = { lazygit = 1 }, expected = {} },
  }

  for _, case in ipairs(cases) do
    with_toggleterm({ tools = case.tools, features = case.features }, function(spec, calls)
      local maps = core_mappings(spec)
      for _, key in ipairs {
        "<Leader>g",
        "<Leader>gg",
        "<Leader>tl",
        "<Leader>tn",
        "<Leader>tu",
        "<Leader>tt",
        "<Leader>tp",
      } do
        local expected = vim.tbl_contains(case.expected, key)
        assert.equals(expected, maps.n[key] ~= nil, case.name .. ": " .. key)
      end
      for _, dispatch in ipairs(case.dispatch or {}) do
        local call_count = #calls
        invoke(maps, "n", dispatch.key)
        assert.equals(call_count + 1, #calls, case.name .. ": " .. dispatch.key)
        assert.same(dispatch.call, calls[#calls], case.name .. ": " .. dispatch.key)
      end
      assert.equals("<Cmd>ToggleTerm direction=float<CR>", maps.n["<Leader>tf"][1])
      assert.equals("<Cmd>ToggleTerm size=10 direction=horizontal<CR>", maps.n["<Leader>th"][1])
      assert.equals("<Cmd>ToggleTerm size=80 direction=vertical<CR>", maps.n["<Leader>tv"][1])
    end)
  end
end

T["TERM-02 forwards LazyGit worktrees and count-aware terminal commands"] = function()
  with_toggleterm(
    { tools = { git = 1, lazygit = 1 }, worktree = { toplevel = "/work tree", gitdir = "/git dir" } },
    function(spec, calls)
      local maps = core_mappings(spec)
      local call_count = #calls
      invoke(maps, "n", "<Leader>gg")
      assert.equals(call_count + 1, #calls)
      assert.same(
        expected_call(
          "toggle_term_cmd",
          { cmd = "lazygit  --work-tree=</work tree> --git-dir=</git dir>", direction = "float" }
        ),
        calls[1]
      )
      assert.equals('<Cmd>execute v:count . "ToggleTerm"<CR>', maps.n["<F7>"][1])
      assert.equals('<Cmd>execute v:count . "ToggleTerm"<CR>', maps.n["<C-'>"][1])
      assert.equals("<Cmd>ToggleTerm<CR>", maps.t["<F7>"][1])
      assert.equals("<Cmd>ToggleTerm<CR>", maps.t["<C-'>"][1])
      assert.equals("<Esc><Cmd>ToggleTerm<CR>", maps.i["<F7>"][1])
      assert.equals("<Esc><Cmd>ToggleTerm<CR>", maps.i["<C-'>"][1])
    end
  )

  with_toggleterm({ tools = { git = 1, lazygit = 1 } }, function(spec, calls)
    local call_count = #calls
    invoke(core_mappings(spec), "n", "<Leader>tl")
    assert.equals(call_count + 1, #calls)
    assert.same(expected_call("toggle_term_cmd", { cmd = "lazygit ", direction = "float" }), calls[#calls])
  end)
end

T["TERM-03 forwards Neo-tree file directories and terminal directions"] = function()
  with_toggleterm(nil, function(spec, calls)
    local options = { commands = {}, window = { mappings = {} } }
    find_spec(spec.specs, "nvim-neo-tree/neo-tree.nvim").opts(nil, options)
    assert.same(
      { "show_help", nowait = false, config = { title = "New Terminal", prefix_key = "T" } },
      options.window.mappings.T
    )

    for suffix, direction in pairs { f = "float", h = "horizontal", v = "vertical" } do
      local command = "toggleterm_" .. direction
      assert.equals(command, options.window.mappings["T" .. suffix])
      local terminal_count = #calls.terminals
      local toggle_count = calls.toggled or 0
      options.commands[command] {
        tree = {
          get_node = function()
            return {
              type = "file",
              get_id = function() return "/workspace/file.lua" end,
              get_parent_id = function() return "/workspace" end,
            }
          end,
        },
      }
      assert.equals(terminal_count + 1, #calls.terminals)
      assert.equals(toggle_count + 1, calls.toggled)
      assert.same({ dir = "/workspace", direction = direction }, calls.terminals[#calls.terminals])
    end

    local terminal_count = #calls.terminals
    local toggle_count = calls.toggled or 0
    options.commands.toggleterm_float {
      tree = {
        get_node = function()
          return {
            type = "directory",
            get_id = function() return "/workspace/directory" end,
          }
        end,
      },
    }
    assert.equals(terminal_count + 1, #calls.terminals)
    assert.equals(toggle_count + 1, calls.toggled)
    assert.same({ dir = "/workspace/directory", direction = "float" }, calls.terminals[#calls.terminals])
    assert.equals(4, calls.toggled)
  end)
end

T["SESSION-01 forwards Resession mapping arguments"] = function()
  with_resession(nil, function(spec, calls)
    local options = { mappings = { n = {} }, autocmds = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, options)
    local maps = options.mappings.n
    local cases = {
      { key = "<Leader>Sl", call = expected_call("load", "Last Session") },
      { key = "<Leader>Ss", call = expected_call "save" },
      { key = "<Leader>SS", call = expected_call("save", "/workspace", { dir = "dirsession" }) },
      { key = "<Leader>St", call = expected_call "save_tab" },
      { key = "<Leader>Sd", call = expected_call "delete" },
      { key = "<Leader>SD", call = expected_call("delete", nil, { dir = "dirsession" }) },
      { key = "<Leader>Sf", call = expected_call "load" },
      { key = "<Leader>SF", call = expected_call("load", nil, { dir = "dirsession" }) },
      { key = "<Leader>S.", call = expected_call("load", "/workspace", { dir = "dirsession" }) },
    }
    for _, case in ipairs(cases) do
      local call_count = #calls.session
      maps[case.key][1]()
      assert.equals(call_count + 1, #calls.session, case.key)
      assert.same(case.call, calls.session[#calls.session], case.key)
    end
  end)
end

T["SESSION-02 gates autosave and delegates buffer and tab filters"] = function()
  local autosave_cases = {
    { name = "disabled", autosave = false, expected = {} },
    {
      name = "last only",
      autosave = { last = true },
      expected = { expected_call("save", "Last Session", { notify = false }) },
    },
    {
      name = "cwd only",
      autosave = { cwd = true },
      expected = { expected_call("save", "/workspace", { dir = "dirsession", notify = false }) },
    },
    {
      name = "both",
      autosave = { last = true, cwd = true },
      expected = {
        expected_call("save", "Last Session", { notify = false }),
        expected_call("save", "/workspace", { dir = "dirsession", notify = false }),
      },
    },
    { name = "neither", autosave = {}, expected = {} },
  }
  for _, case in ipairs(autosave_cases) do
    with_resession({ autosave = case.autosave }, function(spec, calls)
      local core_options = { mappings = { n = {} }, autocmds = {} }
      find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, core_options)
      core_options.autocmds.resession_auto_save[1].callback()
      assert.same(case.expected, calls.session, case.name)
    end)
  end

  with_resession({
    autosave = { last = true, cwd = true },
    valid_session = false,
    restorable = false,
    tab_buffers = { [9] = { bufs = { 21 } }, [10] = {} },
  }, function(spec, calls)
    local core_options = { mappings = { n = {} }, autocmds = {} }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, core_options)
    core_options.autocmds.resession_auto_save[1].callback()
    assert.same({}, calls.session)
    assert.equals(1, calls.valid_session)
    assert.is_false(spec.opts.buf_filter(13))
    assert.same({ 13 }, calls.restorable)
    assert.is_true(spec.opts.tab_buf_filter(9, 21))
    assert.is_false(spec.opts.tab_buf_filter(9, 22))
    assert.is_false(spec.opts.tab_buf_filter(10, 21))
  end)

  with_resession({ restorable = true }, function(spec, calls)
    assert.is_true(spec.opts.buf_filter(17))
    assert.same({ 17 }, calls.restorable)
  end)
end

T["SESSION-03 owns Resession mappings autosave filters and tab extension metadata"] = function()
  with_resession(
    { autosave = { last = true, cwd = true }, tab_buffers = { [5] = { bufs = { 31 } } } },
    function(spec, calls)
      assert.equals("stevearc/resession.nvim", spec[1])
      assert.is_true(spec.lazy)
      assert.same({ astrocore = { enable_in_tab = true } }, spec.opts.extensions)

      local options = { mappings = { n = {} }, _map_sections = { S = { desc = "Session" } }, autocmds = {} }
      find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, options)
      assert.same({ desc = "Session" }, options.mappings.n["<Leader>S"])
      local descriptions = {
        ["<Leader>Sl"] = "Load last session",
        ["<Leader>Ss"] = "Save this session",
        ["<Leader>SS"] = "Save this dirsession",
        ["<Leader>St"] = "Save this tab's session",
        ["<Leader>Sd"] = "Delete a session",
        ["<Leader>SD"] = "Delete a dirsession",
        ["<Leader>Sf"] = "Load a session",
        ["<Leader>SF"] = "Load a dirsession",
        ["<Leader>S."] = "Load current dirsession",
      }
      for key, description in pairs(descriptions) do
        assert.equals(description, options.mappings.n[key].desc, key)
      end

      local autosave = options.autocmds.resession_auto_save[1]
      assert.equals("VimLeavePre", autosave.event)
      assert.equals("Save session on close", autosave.desc)
      autosave.callback()
      assert.same({
        expected_call("save", "Last Session", { notify = false }),
        expected_call("save", "/workspace", { dir = "dirsession", notify = false }),
      }, calls.session)
      assert.is_true(spec.opts.buf_filter(31))
      assert.same({ 31 }, calls.restorable)
      assert.is_true(spec.opts.tab_buf_filter(5, 31))
      assert.is_false(spec.opts.tab_buf_filter(5, 32))
    end
  )
end

T["SPLITS-01 detects multiplexers and dispatches split movement and resizing"] = function()
  local mux_cases = {
    { name = "no multiplexer", environment = { TERM_PROGRAM = "foot" }, expected = nil },
    { name = "tmux normalized", environment = { TERM_PROGRAM = "  TMUX  " }, expected = "VeryLazy" },
    { name = "WezTerm normalized", environment = { TERM_PROGRAM = "WEZTERM" }, expected = "VeryLazy" },
    { name = "Kitty unset", environment = { TERM_PROGRAM = "foot" }, expected = nil },
    { name = "Kitty empty", environment = { TERM_PROGRAM = "foot", KITTY_LISTEN_ON = "" }, expected = "VeryLazy" },
    {
      name = "Kitty socket",
      environment = { TERM_PROGRAM = "foot", KITTY_LISTEN_ON = "unix:/tmp/kitty" },
      expected = "VeryLazy",
    },
  }
  for _, case in ipairs(mux_cases) do
    with_smart_splits(
      { environment = case.environment },
      function(spec) assert.equals(case.expected, spec.event, case.name) end
    )
  end

  with_smart_splits(nil, function(spec, calls)
    local options = { mappings = { n = {} } }
    find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, options)
    local maps = options.mappings.n
    local expected = {
      ["<C-H>"] = "move_cursor_left",
      ["<C-J>"] = "move_cursor_down",
      ["<C-K>"] = "move_cursor_up",
      ["<C-L>"] = "move_cursor_right",
      ["<C-Up>"] = "resize_up",
      ["<C-Down>"] = "resize_down",
      ["<C-Left>"] = "resize_left",
      ["<C-Right>"] = "resize_right",
    }
    for key, name in pairs(expected) do
      local call_count = #calls
      invoke({ n = maps }, "n", key)
      assert.equals(call_count + 1, #calls, key)
      assert.equals(name, calls[#calls], key)
    end
  end)
end

T["SPLITS-02 owns non-empty Kitty loading contract ignored buffers and local mappings"] = function()
  with_smart_splits(
    { environment = { TERM_PROGRAM = "foot", KITTY_LISTEN_ON = "unix:/tmp/kitty" } },
    function(spec, calls)
      assert.equals("mrjones2014/smart-splits.nvim", spec[1])
      assert.is_true(spec.lazy)
      assert.equals("VeryLazy", spec.event)
      assert.same({ "nofile", "quickfix", "qf", "prompt" }, spec.opts.ignored_filetypes)
      assert.same({ "nofile" }, spec.opts.ignored_buftypes)

      local options = { mappings = { n = {} } }
      find_spec(spec.specs, "AstroNvim/astrocore").opts(nil, options)
      local mappings = {
        ["<C-H>"] = { method = "move_cursor_left", desc = "Move to left split" },
        ["<C-J>"] = { method = "move_cursor_down", desc = "Move to below split" },
        ["<C-K>"] = { method = "move_cursor_up", desc = "Move to above split" },
        ["<C-L>"] = { method = "move_cursor_right", desc = "Move to right split" },
        ["<C-Up>"] = { method = "resize_up", desc = "Resize split up" },
        ["<C-Down>"] = { method = "resize_down", desc = "Resize split down" },
        ["<C-Left>"] = { method = "resize_left", desc = "Resize split left" },
        ["<C-Right>"] = { method = "resize_right", desc = "Resize split right" },
      }
      for key, expected in pairs(mappings) do
        assert.equals(expected.desc, options.mappings.n[key].desc, key)
        local call_count = #calls
        invoke({ n = options.mappings.n }, "n", key)
        assert.equals(call_count + 1, #calls, key)
        assert.equals(expected.method, calls[#calls], key)
      end
    end
  )
end

return T
