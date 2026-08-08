local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_plugin(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then return spec end
  end
  error("Missing plugin spec: " .. name)
end

local function record(calls, name, ...)
  table.insert(calls.actions, { name = name, arguments = { n = select("#", ...), ... } })
end

local function with_astroui(options, callback)
  options = options or {}
  local calls = { buffer = {} }
  local values = { foldexpr = options.local_foldexpr or "local-foldexpr" }
  local local_options = setmetatable({}, {
    __index = values,
    __newindex = function(_, key, value)
      calls.foldexpr_writes = (calls.foldexpr_writes or 0) + 1
      values[key] = value
    end,
  })

  return unit_helpers.with_module("astronvim.plugins._astroui", {
    loaded = {
      ["astrocore.buffer"] = {
        is_valid = function(bufnr)
          table.insert(calls.buffer, bufnr)
          return options.valid_buffer ~= false
        end,
      },
    },
    replace_vim = { go = true, wo = true },
    vim = {
      go = { foldexpr = options.global_foldexpr or "v:lua.require'astroui.folding'.foldexpr()" },
      wo = { [0] = { [0] = local_options } },
    },
  }, function(spec) callback(spec, calls, values) end)
end

local function with_status_options(options, callback)
  options = options or {}
  local calls = { actions = {}, extensions = {}, lualine = {} }
  local highlights = options.highlights or {}
  local astroui = {
    config = {},
    get_hlgroup = function(name, fallback) return highlights[name] or fallback end,
  }

  return unit_helpers.with_module("astronvim.plugins._astroui_status", {
    loaded = {
      astroui = astroui,
      astrocore = {
        extend_tbl = function(defaults, overrides)
          table.insert(calls.extensions, overrides)
          return vim.tbl_deep_extend("force", vim.deepcopy(defaults), overrides)
        end,
      },
      ["astroui.status.hl"] = {
        lualine_mode = function(mode, fallback)
          table.insert(calls.lualine, { mode = mode, fallback = fallback })
          return "resolved:" .. mode .. ":" .. fallback
        end,
      },
      gitsigns = options.gitsigns == false and unit_helpers.remove or {
        preview_hunk = function() record(calls, "gitsigns.preview_hunk") end,
      },
      dap = options.dap == false and unit_helpers.remove or {
        toggle_breakpoint = function() record(calls, "dap.toggle_breakpoint") end,
      },
    },
    preload = {
      gitsigns = options.gitsigns == false and function() error "gitsigns unavailable" end or nil,
      dap = options.dap == false and function() error "dap unavailable" end or nil,
    },
    vim = {
      diagnostic = { open_float = function() record(calls, "diagnostic.open_float") end },
      lsp = { buf = { code_action = function() record(calls, "lsp.code_action") end } },
    },
  }, function(spec, context)
    local opts = {}
    spec.opts(nil, opts)
    astroui.config.status = opts.status
    callback(opts.status, calls, context)
  end)
end

local function with_heirline(options, callback)
  options = options or {}
  local calls = { actions = {}, component_calls = {}, pickers = {} }
  local state = options.state
    or {
      current_buf = 7,
      wins = { 11 },
      win_width = 80,
      win_buffers = { [11] = 9 },
      tabs = { 1 },
      columns = 120,
    }
  local ui_status = options.ui_status
    or {
      setup_colors = function()
        calls.setup_colors = (calls.setup_colors or 0) + 1
        return { generated = true }
      end,
      winbar = { enabled = { kind = "enabled" }, disabled = { kind = "disabled" } },
    }
  local function component(name)
    return function(component_options)
      table.insert(calls.component_calls, { name = name, options = component_options })
      return { kind = name, options = component_options }
    end
  end
  local status = {
    condition = {
      buffer_matches = function(rule, bufnr)
        record(calls, "status.buffer_matches", rule, bufnr)
        return options.buffer_matches and options.buffer_matches(rule, bufnr) or false
      end,
      is_active = function() return calls.is_active == true end,
    },
    component = {},
    heirline = {},
    hl = {},
    provider = {},
  }
  for _, name in ipairs {
    "mode",
    "git_branch",
    "file_info",
    "git_diff",
    "diagnostics",
    "fill",
    "cmd_info",
    "lsp",
    "virtual_env",
    "treesitter",
    "nav",
    "separated_path",
    "breadcrumbs",
    "tabline_file_info",
    "foldcolumn",
    "numbercolumn",
    "signcolumn",
  } do
    status.component[name] = component(name)
  end
  status.heirline.make_buflist = function(item)
    record(calls, "heirline.make_buflist", item)
    return { kind = "buflist", item = item }
  end
  status.heirline.make_tablist = function(item)
    record(calls, "heirline.make_tablist", item)
    return { kind = "tablist", item = item }
  end
  status.heirline.tab_type = function(self, kind)
    record(calls, "heirline.tab_type", self, kind)
    return kind
  end
  status.hl.file_icon = options.file_icon
    or function(scope)
      record(calls, "hl.file_icon", scope)
      return "file-icon"
    end
  status.hl.get_attributes = options.get_attributes
    or function(scope, active)
      record(calls, "hl.get_attributes", scope, active)
      return scope .. ":" .. tostring(active)
    end
  status.provider.tabnr = function()
    record(calls, "provider.tabnr")
    return "tabnr"
  end
  status.provider.close_button = function(close_options)
    record(calls, "provider.close_button", close_options)
    return { kind = "close_button", options = close_options }
  end

  return unit_helpers.with_module("astronvim.plugins.heirline", {
    loaded = {
      astroui = { config = { status = ui_status } },
      ["astroui.status"] = status,
      ["astroui.status.heirline"] = {
        buffer_picker = function(picker_callback) table.insert(calls.pickers, picker_callback) end,
        refresh_colors = function() record(calls, "heirline.refresh_colors") end,
      },
      astrocore = {
        extend_tbl = function(base, extension)
          record(calls, "astrocore.extend_tbl", base, extension)
          return vim.tbl_deep_extend("force", base, extension)
        end,
      },
      ["astrocore.buffer"] = {
        close = function(bufnr) record(calls, "buffer.close", bufnr) end,
        close_tab = function() record(calls, "buffer.close_tab") end,
        is_valid = function(bufnr)
          record(calls, "buffer.is_valid", bufnr)
          return options.valid_buffer == true
        end,
      },
      heirline = options.heirline_loaded and {} or unit_helpers.remove,
    },
    replace_vim = { cmd = true, o = true },
    vim = {
      api = {
        nvim_get_current_buf = function() return state.current_buf end,
        nvim_win_set_buf = function(winid, bufnr) record(calls, "nvim_win_set_buf", winid, bufnr) end,
        nvim_tabpage_list_wins = function() return state.wins end,
        nvim_win_get_width = function() return state.win_width end,
        nvim_win_get_buf = function(winid) return state.win_buffers[winid] end,
        nvim_list_tabpages = function() return state.tabs end,
      },
      cmd = {
        split = function() record(calls, "vim.cmd.split") end,
        vsplit = function() record(calls, "vim.cmd.vsplit") end,
      },
      o = { columns = state.columns },
    },
  }, function(spec) callback(spec, calls, state, status) end)
end

T["UI-01 keeps folding enabled for valid buffers and restores the AstroUI foldexpr safely"] = function()
  with_astroui({ valid_buffer = false }, function(spec, calls)
    assert.is_false(find_plugin({ spec }, "AstroNvim/astroui").opts.folding.enabled(23))
    assert.same({ 23 }, calls.buffer)
  end)

  with_astroui({ valid_buffer = true }, function(spec, calls, values)
    local astroui_spec = find_plugin({ spec }, "AstroNvim/astroui")
    local callback = astroui_spec.specs[1].opts.autocmds.persistent_astroui_foldexpr[1].callback

    assert.is_true(astroui_spec.opts.folding.enabled(29))
    callback()

    assert.equals("v:lua.require'astroui.folding'.foldexpr()", values.foldexpr)
    assert.equals(1, calls.foldexpr_writes)
  end)

  with_astroui({ local_foldexpr = "v:lua.require'astroui.folding'.foldexpr()" }, function(spec, calls, values)
    find_plugin({ spec }, "AstroNvim/astroui").specs[1].opts.autocmds.persistent_astroui_foldexpr[1].callback()
    assert.equals("v:lua.require'astroui.folding'.foldexpr()", values.foldexpr)
    assert.is_nil(calls.foldexpr_writes)
  end)

  with_astroui({ global_foldexpr = "global-foldexpr" }, function(spec, calls, values)
    find_plugin({ spec }, "AstroNvim/astroui").specs[1].opts.autocmds.persistent_astroui_foldexpr[1].callback()
    assert.equals("local-foldexpr", values.foldexpr)
    assert.is_nil(calls.foldexpr_writes)
  end)
end

T["UI-02 dispatches GitSigns and DAP sign clicks and skips unavailable modules"] = function()
  with_status_options(nil, function(status, calls, context)
    for _, name in ipairs {
      "GitSignsTopdelete",
      "GitSignsUntracked",
      "GitSignsAdd",
      "GitSignsChange",
      "GitSignsChangedelete",
      "GitSignsDelete",
      "gitsigns_extmark_signs_",
    } do
      status.sign_handlers[name] {}
    end
    for _, name in ipairs { "DapBreakpoint", "DapBreakpointRejected", "DapBreakpointCondition" } do
      status.sign_handlers[name] {}
    end
    context.drain_scheduled()

    assert.equals(10, #calls.actions)
    for index = 1, 7 do
      assert.equals("gitsigns.preview_hunk", calls.actions[index].name)
    end
    for index = 8, 10 do
      assert.equals("dap.toggle_breakpoint", calls.actions[index].name)
    end
  end)

  with_status_options({ gitsigns = false, dap = false }, function(status, calls, context)
    status.sign_handlers.GitSignsAdd {}
    status.sign_handlers.DapBreakpoint {}
    context.drain_scheduled()
    assert.equals(0, #calls.actions)
  end)
end

T["UI-03 dispatches diagnostic sign handlers to code actions or floats"] = function()
  with_status_options(nil, function(status, calls, context)
    for _, name in ipairs { "DiagnosticSignError", "DiagnosticSignHint", "DiagnosticSignInfo", "DiagnosticSignWarn" } do
      status.sign_handlers[name] { mods = "c" }
    end
    status.sign_handlers.DiagnosticSignError { mods = "" }
    context.drain_scheduled()

    assert.equals(5, #calls.actions)
    for index = 1, 4 do
      assert.equals("lsp.code_action", calls.actions[index].name)
    end
    assert.equals("diagnostic.open_float", calls.actions[5].name)
  end)
end

T["UI-04 resolves status colors, overrides, fallback section colors, and winbar highlights"] = function()
  local user_colors = {
    section_bg = "user-section-bg",
    section_fg = "user-section-fg",
    diagnostics_bg = "user-diagnostics-bg",
  }
  with_status_options({
    highlights = {
      HeirlineNormal = { bg = "normal-background" },
      HeirlineInsert = { bg = "NONE" },
      HeirlineVisual = {},
      WinBar = { fg = "winbar-fg", bg = "winbar-bg" },
      WinBarNC = { fg = "winbarnc-fg", bg = "winbarnc-bg" },
    },
  }, function(status, calls)
    local astroui = require "astroui"
    astroui.config.status.colors = user_colors
    local colors = status.setup_colors()

    assert.same(user_colors, calls.extensions[1])
    assert.equals("normal-background", colors.normal)
    assert.equals("resolved:insert:#98c379", colors.insert)
    assert.equals("resolved:visual:#c678dd", colors.visual)
    assert.equals("resolved:insert:resolved:insert:#98c379", colors.terminal)
    assert.equals("winbar-fg", colors.winbar_fg)
    assert.equals("winbar-bg", colors.winbar_bg)
    assert.equals("winbarnc-fg", colors.winbarnc_fg)
    assert.equals("winbarnc-bg", colors.winbarnc_bg)

    local sections = {
      "git_branch",
      "file_info",
      "git_diff",
      "diagnostics",
      "lsp",
      "macro_recording",
      "mode",
      "cmd_info",
      "treesitter",
      "nav",
      "virtual_env",
    }
    for _, section in ipairs(sections) do
      local expected_bg = section == "diagnostics" and "user-diagnostics-bg" or "user-section-bg"
      assert.equals(expected_bg, colors[section .. "_bg"], section .. " background")
    end
    for _, section in ipairs { "file_info", "git_diff", "diagnostics", "lsp", "macro_recording", "cmd_info", "nav" } do
      assert.equals("user-section-fg", colors[section .. "_fg"], section .. " fallback foreground")
    end
    for _, section in ipairs { "git_branch", "mode", "treesitter", "virtual_env" } do
      assert.is_true(colors[section .. "_fg"] ~= "user-section-fg", section .. " owned foreground")
    end
  end)

  with_status_options(nil, function(status)
    local astroui = require "astroui"
    astroui.config.status.colors = function(colors)
      colors.section_fg = "function-section-fg"
      return colors
    end
    assert.equals("function-section-fg", status.setup_colors().file_info_fg)
  end)
end

T["UI-05 keeps selected status, separator, attribute, icon-highlight, and winbar invariants"] = function()
  with_status_options(nil, function(status)
    assert.same({ "NORMAL", "normal" }, status.modes.n)
    assert.same({ "INSERT", "insert" }, status.modes.i)
    assert.same({ "", "  " }, status.separators.left)
    assert.equals(status.separators.path, status.separators.breadcrumbs)
    assert.equals(true, status.attributes.buffer_active.bold)
    assert.equals(true, status.attributes.buffer_active.italic)
    assert.equals(true, status.attributes.git_branch.bold)
    assert.is_true(status.icon_highlights.file_icon.tabline { is_active = true })
    assert.is_true(status.icon_highlights.file_icon.tabline { is_visible = true })
    assert.is_nil(status.icon_highlights.file_icon.tabline {})
    assert.equals(true, status.icon_highlights.file_icon.statusline)
    assert.same({ "^terminal$", "^nofile$" }, status.winbar.disabled.buftype)
    assert.same({}, status.winbar.enabled.bufname)
  end)
end

T["HEIR-01 dispatches all buffer-picker callbacks through AstroNvim boundaries"] = function()
  with_heirline(nil, function(spec, calls)
    local core_options = { mappings = { n = {} }, autocmds = {} }
    spec.specs[1].opts(nil, core_options)

    for _, key in ipairs { "<Leader>bb", "<Leader>bd", "<Leader>b\\", "<Leader>b|" } do
      core_options.mappings.n[key][1]()
    end
    assert.equals(4, #calls.pickers)

    calls.pickers[1](12)
    calls.pickers[2](13)
    calls.pickers[3](14)
    calls.pickers[4](15)

    assert.same({ name = "nvim_win_set_buf", arguments = { n = 2, 0, 12 } }, calls.actions[1])
    assert.same({ name = "buffer.close", arguments = { n = 1, 13 } }, calls.actions[2])
    assert.same({ name = "vim.cmd.split", arguments = { n = 0 } }, calls.actions[3])
    assert.same({ name = "nvim_win_set_buf", arguments = { n = 2, 0, 14 } }, calls.actions[4])
    assert.same({ name = "vim.cmd.vsplit", arguments = { n = 0 } }, calls.actions[5])
    assert.same({ name = "nvim_win_set_buf", arguments = { n = 2, 0, 15 } }, calls.actions[6])
  end)
end

T["HEIR-02 refreshes colors only when Heirline is loaded"] = function()
  for _, case in ipairs {
    { loaded = true, expected_calls = 1 },
    { loaded = false, expected_calls = 0 },
  } do
    with_heirline({ heirline_loaded = case.loaded }, function(spec, calls)
      local core_options = { mappings = { n = {} }, autocmds = {} }
      spec.specs[1].opts(nil, core_options)
      core_options.autocmds.heirline_colors[1].callback()
      assert.equals(case.expected_calls, #calls.actions)
      if case.loaded then assert.equals("heirline.refresh_colors", calls.actions[1].name) end
    end)
  end
end

T["HEIR-03 keeps winbar predicates and sidebar padding semantic"] = function()
  with_heirline({
    valid_buffer = true,
    buffer_matches = function(rule, bufnr)
      assert.equals(8, bufnr)
      return rule.kind == "enabled"
    end,
  }, function(spec, calls)
    local options = spec.opts(nil, {})
    calls.actions = {}
    assert.is_false(options.opts.disable_winbar_cb { buf = 8 })
    assert.same({ name = "status.buffer_matches", arguments = { n = 2, { kind = "enabled" }, 8 } }, calls.actions[1])
  end)

  with_heirline({
    valid_buffer = true,
    buffer_matches = function(rule, bufnr)
      assert.equals(8, bufnr)
      return rule.kind == "disabled"
    end,
  }, function(spec, calls)
    local options = spec.opts(nil, {})
    calls.actions = {}
    assert.is_true(options.opts.disable_winbar_cb { buf = 8 })
    assert.same({ name = "status.buffer_matches", arguments = { n = 2, { kind = "enabled" }, 8 } }, calls.actions[1])
    assert.same({ name = "buffer.is_valid", arguments = { n = 1, 8 } }, calls.actions[2])
    assert.same({ name = "status.buffer_matches", arguments = { n = 2, { kind = "disabled" }, 8 } }, calls.actions[3])
  end)

  with_heirline({
    valid_buffer = false,
    buffer_matches = function() return false end,
  }, function(spec, calls, state)
    local options = spec.opts(nil, {})
    calls.actions = {}
    assert.is_true(options.opts.disable_winbar_cb { buf = 8 })
    assert.same({ name = "status.buffer_matches", arguments = { n = 2, { kind = "enabled" }, 8 } }, calls.actions[1])
    assert.same({ name = "buffer.is_valid", arguments = { n = 1, 8 } }, calls.actions[2])

    local inactive = options.winbar[1].condition
    calls.is_active = true
    assert.is_false(inactive())
    calls.is_active = false
    assert.is_true(inactive())

    local sidebar = options.tabline[1]
    local instance = {}
    calls.actions = {}
    assert.is_true(sidebar.condition(instance))
    assert.same({ name = "buffer.is_valid", arguments = { n = 1, 9 } }, calls.actions[1])
    assert.equals(11, instance.winid)
    assert.equals(80, instance.winwidth)
    assert.equals(string.rep(" ", 81), sidebar.provider(instance))

    state.win_width = state.columns
    assert.is_false(sidebar.condition {})
    state.win_width = 80
  end)

  with_heirline({ valid_buffer = true }, function(spec, calls)
    local sidebar = spec.opts(nil, {}).tabline[1]
    calls.actions = {}
    assert.is_false(sidebar.condition {})
    assert.same({ name = "buffer.is_valid", arguments = { n = 1, 9 } }, calls.actions[1])
  end)
end

T["HEIR-04 closes the current tab through the tabline callback"] = function()
  with_heirline(nil, function(spec, calls)
    local options = spec.opts(nil, {})
    options.tabline[4][2].on_click.callback()
    assert.same({ name = "buffer.close_tab", arguments = { n = 0 } }, calls.actions[#calls.actions])
  end)
end

T["HEIR-05 builds selected statusline, winbar, tabline, and statuscolumn components in order"] = function()
  with_heirline(nil, function(spec, calls)
    local options = spec.opts(nil, {})
    local expected_statusline = {
      "mode",
      "git_branch",
      "file_info",
      "git_diff",
      "diagnostics",
      "fill",
      "cmd_info",
      "fill",
      "lsp",
      "virtual_env",
      "treesitter",
      "nav",
      "mode",
    }
    for index, name in ipairs(expected_statusline) do
      assert.equals(name, options.statusline[index].kind, "statusline component " .. index)
    end
    assert.equals("separated_path", options.winbar[1][1].kind)
    assert.equals("file_info", options.winbar[1][2].kind)
    assert.equals("breadcrumbs", options.winbar[2].kind)
    assert.equals("tabline_file_info", options.tabline[2].item.kind)
    assert.equals("fill", options.tabline[3].kind)
    assert.equals("tablist", options.tabline[4][1].kind)
    assert.equals("foldcolumn", options.statuscolumn[1].kind)
    assert.equals("numbercolumn", options.statuscolumn[2].kind)
    assert.equals("signcolumn", options.statuscolumn[3].kind)
    assert.equals(1, calls.setup_colors)
    local builder_names = {
      ["heirline.make_buflist"] = true,
      ["provider.tabnr"] = true,
      ["heirline.make_tablist"] = true,
      ["provider.close_button"] = true,
    }
    local builder_counts = {}
    for _, action in ipairs(calls.actions) do
      if builder_names[action.name] then builder_counts[action.name] = (builder_counts[action.name] or 0) + 1 end
    end
    assert.same({
      ["heirline.make_buflist"] = 1,
      ["provider.tabnr"] = 1,
      ["heirline.make_tablist"] = 1,
      ["provider.close_button"] = 1,
    }, builder_counts)
  end)
end

T["HEIR-06 caches builder values once and evaluates cached functions per component"] = function()
  local file_icon_calls = 0
  local attributes_calls = 0
  with_heirline({
    file_icon = function(scope)
      file_icon_calls = file_icon_calls + 1
      assert.equals("winbar", scope)
      return "cached-file-icon"
    end,
    get_attributes = function(scope, active)
      attributes_calls = attributes_calls + 1
      return function(self) return scope .. ":" .. tostring(active) .. ":" .. self.name end
    end,
  }, function(spec)
    local options = spec.opts(nil, {})
    local inactive_file_info = options.winbar[1][2].options
    local file_icon = inactive_file_info.file_icon.hl
    local inactive_attributes = inactive_file_info.hl

    assert.equals("cached-file-icon", file_icon {})
    assert.equals("cached-file-icon", file_icon {})
    assert.equals(1, file_icon_calls)
    assert.equals("winbarnc:true:first", inactive_attributes { name = "first" })
    assert.equals("winbarnc:true:second", inactive_attributes { name = "second" })
    assert.equals(1, attributes_calls)
  end)
end

T["UI-06 installs the AstroUI foldexpr only for an eligible buffer state"] = function()
  local astroui_foldexpr = "v:lua.require'astroui.folding'.foldexpr()"
  for _, case in ipairs {
    {
      name = "invalid buffer",
      valid_buffer = false,
      global_foldexpr = astroui_foldexpr,
      local_foldexpr = "user-foldexpr",
      expected_foldexpr = "user-foldexpr",
    },
    {
      name = "different global foldexpr",
      valid_buffer = true,
      global_foldexpr = "user-global-foldexpr",
      local_foldexpr = "user-foldexpr",
      expected_foldexpr = "user-foldexpr",
    },
    {
      name = "already installed local foldexpr",
      valid_buffer = true,
      global_foldexpr = astroui_foldexpr,
      local_foldexpr = astroui_foldexpr,
      expected_foldexpr = astroui_foldexpr,
    },
    {
      name = "AstroUI global foldexpr with a stale local value",
      valid_buffer = true,
      global_foldexpr = astroui_foldexpr,
      local_foldexpr = "stale-local-foldexpr",
      expected_foldexpr = astroui_foldexpr,
      expected_writes = 1,
    },
  } do
    with_astroui(case, function(spec, calls, values)
      find_plugin({ spec }, "AstroNvim/astroui").specs[1].opts.autocmds.persistent_astroui_foldexpr[1].callback()
      assert.equals(case.expected_foldexpr, values.foldexpr, case.name)
      assert.equals(case.expected_writes, calls.foldexpr_writes, case.name)
    end)
  end
end

return T
