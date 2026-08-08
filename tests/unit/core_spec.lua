local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_plugin(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then return spec end
  end
  error("Missing plugin spec: " .. name)
end

local function find_import(specs, name)
  for _, spec in ipairs(specs) do
    if spec.import == name then return spec end
  end
  error("Missing import spec: " .. name)
end

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then return true end
  end
  return false
end

local function with_core(options, callback)
  options = options or {}
  local calls = { buffer = {}, notifications = {}, schedules = 0 }
  local astrocore = {
    extend_tbl = function(base, extension)
      calls.extension = extension
      return vim.tbl_deep_extend("force", base, extension)
    end,
    notify = function(message, level) table.insert(calls.notifications, { message = message, level = level }) end,
  }

  if options.astrocore_unavailable then astrocore = unit_helpers.remove end

  return unit_helpers.with_module("astronvim.plugins._astrocore", {
    loaded = {
      astronvim = {
        config = options.config or {},
        init = function() calls.initialized = (calls.initialized or 0) + 1 end,
      },
      astroui = { get_icon = function(name) return "icon:" .. name end },
      astrocore = astrocore,
      ["astrocore.buffer"] = {
        is_valid = function(bufnr)
          table.insert(calls.buffer, { method = "is_valid", bufnr = bufnr })
          return options.valid_buffer ~= false
        end,
        is_large = function(bufnr)
          table.insert(calls.buffer, { method = "is_large", bufnr = bufnr })
          return options.large_buffer == true
        end,
      },
    },
    vim = {
      fn = { has = function(feature) return (options.has or {})[feature] or 0 end },
      log = { levels = { WARN = "warn" } },
      diagnostic = {
        severity = { ERROR = "error", HINT = "hint", WARN = "warn", INFO = "info" },
        open_float = function(opts) calls.float = opts end,
      },
    },
  }, function(specs, context) return callback(specs, calls, context) end)
end

local function core_options(specs, opts) return find_plugin(specs, "AstroNvim/astrocore").opts(nil, opts or {}) end

T["CORE-01 keeps AstroNvim feature invariants and wires large-buffer callbacks"] = function()
  with_core({ valid_buffer = false }, function(specs, calls)
    local opts = core_options(specs)
    local large_buf = opts.features.large_buf

    assert.equals(1, calls.initialized)
    assert.equals(true, opts.features.autopairs)
    assert.equals(true, opts.features.cmp)
    assert.equals(true, opts.features.diagnostics)
    assert.equals(true, opts.features.highlighturl)
    assert.equals(true, opts.features.notifications)
    assert.equals(true, large_buf.notify)
    assert.equals(1.5 * 1024 * 1024, large_buf.size)
    assert.equals(100000, large_buf.lines)
    assert.equals(1000, large_buf.line_length)
    assert.is_false(large_buf.enabled(17))
    assert.same({ { method = "is_valid", bufnr = 17 } }, calls.buffer)
  end)

  with_core({ valid_buffer = true }, function(specs, calls)
    assert.is_true(core_options(specs).features.large_buf.enabled(23))
    assert.same({ { method = "is_valid", bufnr = 23 } }, calls.buffer)
  end)
end

T["CORE-02 keeps diagnostic signs, float semantics, and jump compatibility wiring"] = function()
  with_core({ has = { ["nvim-0.12"] = 0 } }, function(specs, calls)
    local diagnostics = core_options(specs).diagnostics
    assert.equals("icon:DiagnosticError", diagnostics.signs.text.error)
    assert.equals("icon:DiagnosticHint", diagnostics.signs.text.hint)
    assert.equals("icon:DiagnosticWarn", diagnostics.signs.text.warn)
    assert.equals("icon:DiagnosticInfo", diagnostics.signs.text.info)
    assert.equals("if_many", diagnostics.float.source)
    assert.equals("", diagnostics.float.header)
    assert.equals("", diagnostics.float.prefix)
    assert.equals(true, diagnostics.jump.float)

    diagnostics.jump.on_jump(nil, 18)
    assert.same({ bufnr = 18, scope = "cursor", focus = false }, calls.float)
  end)

  with_core(
    { has = { ["nvim-0.12"] = 1 } },
    function(specs) assert.is_nil(core_options(specs).diagnostics.jump.float) end
  )
end

T["CORE-03 keeps rooter ordering and scoped nonintrusive defaults"] = function()
  with_core(nil, function(specs)
    local rooter = core_options(specs).rooter
    assert.same("lsp", rooter.detector[1])
    assert.same({ ".git", "_darcs", ".hg", ".bzr", ".svn" }, rooter.detector[2])
    assert.same({ "lua", "Makefile", "package.json" }, rooter.detector[3])
    assert.same({}, rooter.ignore.servers)
    assert.same({}, rooter.ignore.dirs)
    assert.equals("global", rooter.scope)
    assert.equals(false, rooter.autochdir)
    assert.equals(false, rooter.notify)
  end)
end

T["CORE-04 keeps session autosave and ignored buffer contracts"] = function()
  with_core(nil, function(specs)
    local sessions = core_options(specs).sessions
    assert.same({ last = true, cwd = true }, sessions.autosave)
    assert.same({ "gitcommit", "gitrebase" }, sessions.ignore.filetypes)
    assert.same({ "nofile" }, sessions.ignore.buftypes)
    assert.same({}, sessions.ignore.dirs)
  end)
end

T["CORE-05 exposes AstroNvim parser declarations and buffer predicates"] = function()
  with_core({ large_buffer = true }, function(specs, calls)
    local treesitter = core_options(specs).treesitter
    local expected_parsers = { "bash", "c", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }
    for _, parser in ipairs(expected_parsers) do
      assert.is_true(contains(treesitter.ensure_installed, parser))
    end
    assert.equals(true, treesitter.highlight)
    assert.equals(true, treesitter.indent)
    assert.is_false(treesitter.enabled(nil, 19))
    assert.same({ { method = "is_large", bufnr = 19 } }, calls.buffer)
    assert.same(
      { query = "@function.outer", desc = "around function" },
      treesitter.textobjects.select.select_textobject.af
    )
    assert.same(
      { query = "@parameter.inner", desc = "Next argument start" },
      treesitter.textobjects.move.goto_next_start["]a"]
    )
  end)

  with_core({ large_buffer = false }, function(specs, calls)
    assert.is_true(core_options(specs).treesitter.enabled(nil, 29))
    assert.same({ { method = "is_large", bufnr = 29 } }, calls.buffer)
  end)
end

T["CORE-06 warns only for available pinned-plugin updates"] = function()
  with_core({ config = { pin_plugins = true } }, function(specs, calls, context)
    find_plugin(specs, "AstroNvim/AstroNvim").build()
    assert.equals(1, context.scheduled_count())
    context.drain_scheduled()
    assert.equals(1, #calls.notifications)
    assert.equals("warn", calls.notifications[1].level)
    assert.is_true(calls.notifications[1].message:find("Pinned versions", 1, true) ~= nil)
  end)

  for _, config in ipairs {
    { pin_plugins = false },
    { pin_plugins = true, update_notification = false },
  } do
    with_core({ config = config }, function(specs, _, context)
      find_plugin(specs, "AstroNvim/AstroNvim").build()
      assert.equals(0, context.scheduled_count())
    end)
  end

  with_core({ config = { pin_plugins = true }, astrocore_unavailable = true }, function(specs, _, context)
    find_plugin(specs, "AstroNvim/AstroNvim").build()
    assert.equals(0, context.scheduled_count())
  end)
end

T["CORE-06 imports the pinned lazy snapshot conditionally"] = function()
  with_core(
    { config = { pin_plugins = true } },
    function(specs) assert.equals(true, find_import(specs, "astronvim.lazy_snapshot").cond) end
  )

  with_core(
    { config = { pin_plugins = false } },
    function(specs) assert.equals(false, find_import(specs, "astronvim.lazy_snapshot").cond) end
  )
end

T["CORE-07 preserves unrelated incoming options through the AstroCore merge boundary"] = function()
  with_core(nil, function(specs)
    local incoming = {
      custom = { keep = true },
      features = { user_feature = { enabled = false } },
      diagnostics = { float = { user_border = "single" } },
    }
    local opts = core_options(specs, incoming)

    assert.equals(true, opts.custom.keep)
    assert.equals(false, opts.features.user_feature.enabled)
    assert.equals("single", opts.diagnostics.float.user_border)
    assert.equals(true, opts.features.notifications)
    assert.equals("if_many", opts.diagnostics.float.source)
  end)
end

local function with_options(options, callback)
  options = options or {}
  return unit_helpers.with_module("astronvim.plugins._astrocore_options", {
    loaded = { astroui = { get_icon = function(name) return "icon:" .. name end } },
    replace_vim = { t = true },
    vim = {
      fn = { has = function(feature) return (options.has or {})[feature] or 0 end },
      api = { nvim_list_bufs = function() return options.buffers or { 3, 5 } end },
      t = options.tab or {},
    },
  }, callback)
end

local function option_values(options_spec, opts)
  opts = opts or {}
  options_spec.opts(nil, opts)
  return opts.options
end

T["OPTIONS-01 preserves list-valued defaults while applying selected option invariants"] = function()
  local backspace = vim.deepcopy(vim.opt.backspace:get())
  local diffopt = vim.deepcopy(vim.opt.diffopt:get())
  local shortmess = vim.deepcopy(vim.opt.shortmess:get())

  with_options({ has = { ["nvim-0.13"] = 0 } }, function(options_spec)
    local options = option_values(options_spec).opt
    assert.equals("unnamedplus", options.clipboard)
    assert.equals(true, options.confirm)
    assert.equals(true, options.number)
    assert.equals(true, options.relativenumber)
    assert.equals(false, options.wrap)
    assert.is_true(contains(options.backspace, "nostop"))
    assert.is_true(contains(options.backspace, backspace[1]))
    assert.is_true(contains(options.diffopt, "algorithm:histogram"))
    assert.is_true(contains(options.diffopt, "linematch:60"))
    assert.is_true(contains(options.diffopt, diffopt[1]))
    assert.equals(true, options.shortmess.s)
    assert.equals(true, options.shortmess.I)
    assert.equals(true, options.shortmess.c)
    assert.equals(true, options.shortmess.C)
    for key, value in pairs(shortmess) do
      assert.equals(value, options.shortmess[key])
    end
  end)
end

T["OPTIONS-02 selects version-specific diff and foldinner declarations"] = function()
  with_options({ has = { ["nvim-0.13"] = 1, ["nvim-0.12"] = 1 } }, function(options_spec)
    local options = option_values(options_spec).opt
    assert.equals("histogram", options.diffopt.algorithm)
    assert.equals(60, options.diffopt.linematch)
    assert.equals("icon:FoldSeparator", options.fillchars.foldinner)
  end)

  with_options(
    { has = { ["nvim-0.13"] = 0, ["nvim-0.12"] = 0 } },
    function(options_spec) assert.is_nil(option_values(options_spec).opt.fillchars.foldinner) end
  )
end

T["OPTIONS-03 sets markdown style and retains or initializes tab buffer lists"] = function()
  with_options({ tab = { bufs = { 11, 13 } } }, function(options_spec)
    local options = option_values(options_spec)
    assert.equals(0, options.g.markdown_recommended_style)
    assert.same({ 11, 13 }, options.t.bufs)
  end)

  with_options(
    { tab = {}, buffers = { 3, 5 } },
    function(options_spec) assert.same({ 3, 5 }, option_values(options_spec).t.bufs) end
  )
end

local function with_mappings(callback)
  local calls = {}
  return unit_helpers.with_module("astronvim.plugins._astrocore_mappings", {
    loaded = {
      astrocore = {
        empty_map_table = function() return { n = {}, x = {}, v = {}, t = {} } end,
        rename_file = function() table.insert(calls, { target = "rename" }) end,
        update_packages = function() table.insert(calls, { target = "update_packages" }) end,
      },
      astroui = { get_icon = function(name) return "icon:" .. name end },
      lazy = {
        install = function() table.insert(calls, { target = "install" }) end,
        home = function() table.insert(calls, { target = "home" }) end,
        sync = function() table.insert(calls, { target = "sync" }) end,
        check = function() table.insert(calls, { target = "check" }) end,
        update = function() table.insert(calls, { target = "update" }) end,
      },
      ["astrocore.toggles"] = setmetatable({}, {
        __index = function(_, name)
          return function() table.insert(calls, { target = "toggle", name = name }) end
        end,
      }),
    },
    vim = {
      api = {
        nvim_win_get_config = function() return { zindex = 1 } end,
        nvim_replace_termcodes = function(keys) return "term:" .. keys end,
        nvim_feedkeys = function(keys, mode, escape)
          table.insert(calls, { target = "feedkeys", keys = keys, mode = mode, escape = escape })
        end,
      },
      cmd = { wincmd = function(direction) table.insert(calls, { target = "wincmd", direction = direction }) end },
    },
  }, function(spec)
    local opts = {}
    spec.opts(nil, opts)
    return callback(opts.mappings, calls)
  end)
end

T["MAP-01 keeps movement expression metadata without snapshotting mappings"] = function()
  with_mappings(function(maps)
    for _, mode in ipairs { "n", "x" } do
      assert.equals("v:count == 0 ? 'gj' : 'j'", maps[mode].j[1])
      assert.equals("v:count == 0 ? 'gk' : 'k'", maps[mode].k[1])
      assert.equals(true, maps[mode].j.expr)
      assert.equals(true, maps[mode].k.silent)
    end
  end)
end

T["MAP-02 records rename forwarding and stable write and quit declarations"] = function()
  with_mappings(function(maps, calls)
    assert.same({ "<Cmd>w<CR>", desc = "Save" }, maps.n["<Leader>w"])
    assert.same({ "<Cmd>silent! update! | redraw<CR>", desc = "Force write" }, maps.n["<C-S>"])
    assert.same({ "<Cmd>confirm q<CR>", desc = "Quit Window" }, maps.n["<Leader>q"])
    assert.same({ "<Cmd>q!<CR>", desc = "Force quit" }, maps.n["<C-Q>"])
    assert.same({ "gcc", remap = true, desc = "Toggle comment line" }, maps.n["<Leader>/"])
    assert.same({ "gc", remap = true, desc = "Toggle comment" }, maps.x["<Leader>/"])
    maps.n["<Leader>R"][1]()
    assert.same({ { target = "rename" } }, calls)
  end)
end

T["MAP-03 forwards package-management mappings through public APIs"] = function()
  with_mappings(function(maps, calls)
    for _, lhs in ipairs { "<Leader>pi", "<Leader>ps", "<Leader>pS", "<Leader>pu", "<Leader>pU", "<Leader>pa" } do
      maps.n[lhs][1]()
    end
    assert.same({
      { target = "install" },
      { target = "home" },
      { target = "sync" },
      { target = "check" },
      { target = "update" },
      { target = "update_packages" },
    }, calls)
  end)
end

T["MAP-08 forwards terminal navigation for floating and ordinary windows"] = function()
  with_mappings(function(maps, calls)
    maps.t["<C-H>"][1]()
    assert.same({ target = "feedkeys", keys = "term:<C-h>", mode = "n", escape = false }, calls[1])
  end)

  local calls = {}
  unit_helpers.with_module("astronvim.plugins._astrocore_mappings", {
    loaded = {
      astrocore = { empty_map_table = function() return { n = {}, x = {}, v = {}, t = {} } end },
      astroui = { get_icon = function(name) return name end },
    },
    vim = {
      api = { nvim_win_get_config = function() return {} end },
      cmd = { wincmd = function(direction) table.insert(calls, direction) end },
    },
  }, function(spec)
    local opts = {}
    spec.opts(nil, opts)
    opts.mappings.t["<C-L>"][1]()
    assert.same({ "l" }, calls)
  end)
end

T["MAP-09 dispatches every toggle mapping to the named AstroCore toggle"] = function()
  local expected = {
    ["<Leader>uA"] = { "autochdir", "Toggle rooter autochdir" },
    ["<Leader>ub"] = { "background", "Toggle background" },
    ["<Leader>ud"] = { "diagnostics", "Toggle diagnostics" },
    ["<Leader>ug"] = { "signcolumn", "Toggle signcolumn" },
    ["<Leader>u>"] = { "foldcolumn", "Toggle foldcolumn" },
    ["<Leader>ui"] = { "indent", "Change indent setting" },
    ["<Leader>ul"] = { "statusline", "Toggle statusline" },
    ["<Leader>un"] = { "number", "Change line numbering" },
    ["<Leader>uN"] = { "notifications", "Toggle Notifications" },
    ["<Leader>up"] = { "paste", "Toggle paste mode" },
    ["<Leader>us"] = { "spell", "Toggle spellcheck" },
    ["<Leader>uS"] = { "conceal", "Toggle conceal" },
    ["<Leader>ut"] = { "tabline", "Toggle tabline" },
    ["<Leader>uu"] = { "url_match", "Toggle URL highlight" },
    ["<Leader>uv"] = { "virtual_text", "Toggle virtual text" },
    ["<Leader>uV"] = { "virtual_lines", "Toggle virtual lines" },
    ["<Leader>uw"] = { "wrap", "Toggle wrap" },
    ["<Leader>uy"] = { "buffer_syntax", "Toggle syntax highlight (buffer)" },
  }

  with_mappings(function(maps, calls)
    for lhs, expected_mapping in pairs(expected) do
      assert.equals(expected_mapping[2], maps.n[lhs].desc)
      maps.n[lhs][1]()
    end
    local dispatched = {}
    for _, call in ipairs(calls) do
      assert.equals("toggle", call.target)
      dispatched[call.name] = true
    end
    for _, expected_mapping in pairs(expected) do
      assert.equals(true, dispatched[expected_mapping[1]])
    end
    assert.equals(18, #calls)
  end)
end

T["MAP-10 forwards buffer counts, diagnostic counts, tab commands, and nonfloating terminal navigation"] = function()
  local calls = { buffer = {}, jumps = {}, commands = {} }
  unit_helpers.with_module("astronvim.plugins._astrocore_mappings", {
    loaded = {
      astrocore = { empty_map_table = function() return { n = {}, x = {}, v = {}, t = {} } end },
      ["astrocore.buffer"] = setmetatable({}, {
        __index = function(_, name)
          return function(...) table.insert(calls.buffer, { method = name, arguments = { ... } }) end
        end,
      }),
      astroui = { get_icon = function(name) return name end },
    },
    replace_vim = { cmd = true, diagnostic = true, v = true },
    vim = {
      v = { count1 = 3 },
      api = { nvim_win_get_config = function() return {} end },
      cmd = {
        checkhealth = function(subject) table.insert(calls.commands, { "checkhealth", subject }) end,
        tabnext = function() table.insert(calls.commands, { "tabnext" }) end,
        tabprevious = function() table.insert(calls.commands, { "tabprevious" }) end,
        wincmd = function(direction) table.insert(calls.commands, { "wincmd", direction }) end,
      },
      diagnostic = {
        severity = { ERROR = "error", WARN = "warn" },
        jump = function(options) table.insert(calls.jumps, vim.deepcopy(options)) end,
        open_float = function() table.insert(calls.commands, { "open_float" }) end,
      },
    },
  }, function(spec)
    local opts = {}
    spec.opts(nil, opts)
    local maps = opts.mappings

    maps.n["]b"][1]()
    maps.n["[b"][1]()
    maps.n[">b"][1]()
    maps.n["<b"][1]()
    maps.n["]e"][1]()
    maps.n["[w"][1]()
    maps.n["<Leader>li"][1]()
    maps.n["gl"][1]()
    maps.n["]t"][1]()
    maps.n["[t"][1]()
    maps.t["<C-J>"][1]()

    assert.same({
      { method = "nav", arguments = { 3 } },
      { method = "nav", arguments = { -3 } },
      { method = "move", arguments = { 3 } },
      { method = "move", arguments = { -3 } },
    }, calls.buffer)
    assert.same({ { count = 3, severity = "error" }, { count = -3, severity = "warn" } }, calls.jumps)
    assert.same({
      { "checkhealth", "vim.lsp" },
      { "open_float" },
      { "tabnext" },
      { "tabprevious" },
      { "wincmd", "j" },
    }, calls.commands)
  end)
end

local function with_autocmds(options, callback)
  options = options or {}
  local calls = { events = {}, commands = {}, exec = {}, deleted = {} }
  local autocmd_call = 0
  local function is_valid(bufnr)
    if type(options.valid_buffer) == "function" then return options.valid_buffer(bufnr) end
    return options.valid_buffer ~= false
  end
  return unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    loaded = {
      astronvim = { version = function() return options.version end },
      astrocore = {
        notify = function(message) table.insert(calls.commands, { target = "notify", message = message }) end,
        reload = function() table.insert(calls.commands, { target = "reload" }) end,
        update_packages = function() table.insert(calls.commands, { target = "update" }) end,
        rename_file = function(args) table.insert(calls.commands, { target = "rename", args = args }) end,
        event = function(name)
          table.insert(calls.events, name)
          if options.on_event then options.on_event(name) end
        end,
        cmd = function(args)
          calls.git = args
          return options.git_result
        end,
        file_worktree = function() return options.worktree == true end,
      },
      ["astrocore.buffer"] = { is_valid = is_valid },
      editorconfig = options.editorconfig == false and unit_helpers.remove
        or { config = function(bufnr) table.insert(calls.commands, { target = "editorconfig", bufnr = bufnr }) end },
    },
    preload = options.editorconfig == false and { editorconfig = function() error "editorconfig unavailable" end }
      or nil,
    vim = {
      api = {
        nvim_buf_is_valid = is_valid,
        nvim_buf_get_name = function() return options.file or "/project/file.lua" end,
        nvim_get_autocmds = function()
          autocmd_call = autocmd_call + 1
          return (options.autocmd_sequences and options.autocmd_sequences[autocmd_call]) or options.autocmds or {}
        end,
        nvim_exec_autocmds = function(event, args) table.insert(calls.exec, { event = event, args = args }) end,
        nvim_del_augroup_by_name = function(name) table.insert(calls.deleted, name) end,
        nvim_buf_get_mark = function() return options.mark or { 0, 0 } end,
        nvim_buf_line_count = function() return options.line_count or 10 end,
        nvim_win_set_cursor = function(_, mark)
          if options.cursor_error then error "cursor failed" end
          calls.cursor = mark
        end,
        nvim_get_mode = function() return { mode = options.mode or "n" } end,
      },
      bo = { buftype = options.buftype or "", filetype = options.filetype or "" },
      b = { astrofile_checked = false, last_loc_restored = false, editorconfig = options.buffer_editorconfig },
      g = { vscode = options.vscode == true, editorconfig = options.global_editorconfig },
      fn = {
        executable = function() return options.git_available == false and 0 or 1 end,
        has = function(feature) return feature == "win32" and options.win32 and 1 or 0 end,
        mkdir = function(path, flags) table.insert(calls.commands, { target = "mkdir", path = path, flags = flags }) end,
        keytrans = function(char) return char end,
        getcmdline = function() return options.command or "" end,
      },
      fs = {
        dirname = function() return "/project" end,
        abspath = function(path) return path end,
      },
      uv = { fs_realpath = function(_) return options.realpath and "/real/file.lua" or nil end },
      cmd = function(command) table.insert(calls.commands, { target = "cmd", command = command }) end,
      hl = { on_yank = function() calls.yanked = (calls.yanked or 0) + 1 end },
      o = { incsearch = options.incsearch ~= false, hlsearch = options.hlsearch or false },
    },
  }, function(spec, context) return callback(spec, calls, context) end)
end

local function autocmd_callback(spec, group, index) return spec.opts.autocmds[group][index or 1].callback end

T["AUTOCMD-01 records command metadata and public forwarding"] = function()
  with_autocmds({ version = "v1.2.3" }, function(spec, calls)
    local commands = spec.opts.commands
    assert.equals("Check AstroNvim Version", commands.AstroVersion.desc)
    assert.equals(true, commands.AstroRename.bang)
    assert.equals("?", commands.AstroRename.nargs)
    commands.AstroReload[1]()
    commands.AstroUpdate[1]()
    commands.AstroRename[1] { fargs = { "renamed.lua" }, bang = true }
    commands.AstroVersion[1]()
    assert.same({
      { target = "reload" },
      { target = "update" },
      { target = "rename", args = { to = "renamed.lua", force = true } },
      { target = "notify", message = "Version: *v1.2.3*" },
    }, calls.commands)
  end)

  with_autocmds({}, function(spec, calls)
    spec.opts.commands.AstroVersion[1]()
    assert.equals(0, #calls.commands)
  end)
end

T["AUTOCMD-02 handles duplicate sidebar types, invalid windows, and single ordinary windows"] = function()
  local function run_case(options)
    local calls = {}
    unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
      replace_vim = { bo = true },
      vim = {
        bo = options.buffer_options,
        api = {
          nvim_tabpage_list_wins = function() return options.windows end,
          nvim_win_is_valid = function(winid) return options.invalid_window ~= winid end,
          nvim_win_get_buf = function(winid) return winid end,
          nvim_list_tabpages = function() return options.tabs or { 1 } end,
        },
        cmd = {
          tabclose = function() table.insert(calls, "tabclose") end,
          qall = function() table.insert(calls, "qall") end,
        },
      },
    }, function(spec) autocmd_callback(spec, "auto_quit")() end)
    return calls
  end

  assert.same(
    {},
    run_case {
      windows = { 1, 2 },
      buffer_options = { [1] = { filetype = "aerial" }, [2] = { filetype = "aerial" } },
    }
  )
  assert.same(
    {},
    run_case {
      windows = { 1 },
      buffer_options = { [1] = { filetype = "text" } },
    }
  )
  assert.same(
    { "tabclose" },
    run_case {
      windows = { 1, 2, 3 },
      invalid_window = 1,
      tabs = { 1, 2 },
      buffer_options = {
        [1] = { filetype = "text" },
        [2] = { filetype = "aerial" },
        [3] = { filetype = "neo-tree" },
      },
    }
  )
end

T["AUTOCMD-04 dispatches checktime only for real file buffers"] = function()
  with_autocmds({ buftype = "" }, function(spec, calls)
    autocmd_callback(spec, "checktime")()
    assert.same({ { target = "cmd", command = "checktime" } }, calls.commands)
  end)

  with_autocmds({ buftype = "nofile" }, function(spec, calls)
    autocmd_callback(spec, "checktime")()
    assert.equals(0, #calls.commands)
  end)
end

T["AUTOCMD-05 creates real file directories and skips invalid or URI-like buffers"] = function()
  with_autocmds({ realpath = true }, function(spec, calls)
    autocmd_callback(spec, "create_dir") { buf = 1, match = "/project/file.lua" }
    assert.same({ { target = "mkdir", path = "/project", flags = "p" } }, calls.commands)
  end)

  with_autocmds({}, function(spec, calls)
    autocmd_callback(spec, "create_dir") { buf = 1, match = "/project/file.lua" }
    assert.same({ { target = "mkdir", path = "/project", flags = "p" } }, calls.commands)
  end)

  with_autocmds({ valid_buffer = false }, function(spec, calls)
    autocmd_callback(spec, "create_dir") { buf = 1, match = "/project/file.lua" }
    assert.equals(0, #calls.commands)
  end)

  with_autocmds({}, function(spec, calls)
    autocmd_callback(spec, "create_dir") { buf = 1, match = "https://example.test/file.lua" }
    assert.equals(0, #calls.commands)
  end)
end

T["AUTOCMD-06 applies EditorConfig only when buffer or global state enables it"] = function()
  with_autocmds({ buffer_editorconfig = true }, function(spec, calls)
    autocmd_callback(spec, "editorconfig_filetype") { buf = 21 }
    assert.same({ { target = "editorconfig", bufnr = 21 } }, calls.commands)
  end)

  with_autocmds({ global_editorconfig = true }, function(spec, calls)
    autocmd_callback(spec, "editorconfig_filetype") { buf = 21 }
    assert.same({ { target = "editorconfig", bufnr = 21 } }, calls.commands)
  end)

  with_autocmds({ buffer_editorconfig = false, global_editorconfig = true }, function(spec, calls)
    autocmd_callback(spec, "editorconfig_filetype") { buf = 21 }
    assert.equals(0, #calls.commands)
  end)

  with_autocmds({}, function(spec, calls)
    autocmd_callback(spec, "editorconfig_filetype") { buf = 21 }
    assert.equals(0, #calls.commands)
  end)

  with_autocmds({ buffer_editorconfig = true, editorconfig = false }, function(spec, calls)
    autocmd_callback(spec, "editorconfig_filetype") { buf = 21 }
    assert.equals(0, #calls.commands)
  end)
end

T["AUTOCMD-07 emits file events once, honors worktrees, and replays filetypedetect"] = function()
  with_autocmds({
    worktree = true,
    win32 = true,
    autocmds = {
      { group_name = "filetypedetect" },
      { group_name = "filetypedetect" },
      { group_name = "other" },
      { group_name = "other" },
    },
  }, function(spec, calls, context)
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost", data = { source = "test" } }
    context.drain_scheduled()
    assert.same({ "File", "GitFile" }, calls.events)
    assert.same({ "git", "-C", '"/project"', "rev-parse" }, calls.git)
    assert.equals(1, #calls.deleted)
    assert.equals(1, #calls.exec)
    assert.same("filetypedetect", calls.exec[1].args.group)
    assert.equals(0, calls.exec[1].args.buffer)

    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
    context.drain_scheduled()
    assert.same({ "File", "GitFile" }, calls.events)
  end)
end

T["AUTOCMD-07 skips invalid and non-file buffers and cleans up when Git is unavailable"] = function()
  with_autocmds({ valid_buffer = false }, function(spec, calls, context)
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
    context.drain_scheduled()
    assert.equals(0, #calls.events)
  end)

  for _, options in ipairs {
    { file = "", buftype = "" },
    { file = "/project/scratch.txt", buftype = "nofile" },
  } do
    with_autocmds(options, function(spec, calls, context)
      autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
      context.drain_scheduled()
      assert.equals(0, #calls.events)
    end)
  end

  with_autocmds({ git_result = true }, function(spec, calls, context)
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
    context.drain_scheduled()
    assert.same({ "File", "GitFile" }, calls.events)
    assert.same({ "file_user_events" }, calls.deleted)
  end)

  with_autocmds({ git_result = false }, function(spec, calls, context)
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
    context.drain_scheduled()
    assert.same({ "File" }, calls.events)
    assert.same({}, calls.deleted)
  end)

  with_autocmds({ git_available = false }, function(spec, calls, context)
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufReadPost" }
    context.drain_scheduled()
    assert.same({ "File" }, calls.events)
    assert.same({ "file_user_events" }, calls.deleted)
  end)
end

T["AUTOCMD-08 dispatches yank highlighting through the public handler"] = function()
  with_autocmds(nil, function(spec, calls)
    autocmd_callback(spec, "highlightyank")()
    assert.equals(1, calls.yanked)
  end)
end

T["AUTOCMD-09 scopes large-buffer settings and unlists quickfix buffers"] = function()
  local buffer_vars = { [9] = {} }
  local local_options = { list = true, buflisted = true }

  unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    replace_vim = { b = true, opt_local = true },
    vim = {
      b = buffer_vars,
      opt_local = local_options,
    },
  }, function(spec)
    autocmd_callback(spec, "large_buf_settings") { buf = 9 }
    assert.equals(false, local_options.list)
    assert.equals(false, buffer_vars[9].autoformat)
    assert.equals(false, buffer_vars[9].completion)

    autocmd_callback(spec, "unlist_quickfix")()
    assert.equals(false, local_options.buflisted)
  end)
end

T["AUTOCMD-10 preserves existing q mappings and caches mapped transient buffers"] = function()
  local function run_case(options, callback)
    local keymap_calls = {}
    local globals = {}
    local buffer_options = { [9] = { buftype = options.buftype or "nofile" } }
    unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
      replace_vim = { bo = true },
      vim = {
        g = globals,
        bo = buffer_options,
        api = {
          nvim_buf_get_keymap = function() return options.existing_mapping and { { lhs = "q" } } or {} end,
        },
        keymap = {
          set = function(mode, lhs, rhs, map_options)
            table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, options = map_options })
          end,
        },
      },
    }, function(spec) callback(spec, globals, keymap_calls) end)
  end

  run_case({ existing_mapping = true }, function(spec, globals, keymap_calls)
    local callback = autocmd_callback(spec, "q_close_windows", 1)
    callback { buf = 9 }
    callback { buf = 9 }
    assert.equals(true, globals.q_close_windows[9])
    assert.equals(0, #keymap_calls)
  end)

  run_case({}, function(spec, globals, keymap_calls)
    autocmd_callback(spec, "q_close_windows", 1) { buf = 9 }
    assert.equals(true, globals.q_close_windows[9])
    assert.equals(1, #keymap_calls)
    assert.same({ mode = "n", lhs = "q", rhs = "<Cmd>close<CR>" }, {
      mode = keymap_calls[1].mode,
      lhs = keymap_calls[1].lhs,
      rhs = keymap_calls[1].rhs,
    })
    assert.equals(9, keymap_calls[1].options.buffer)
    assert.equals("Close window", keymap_calls[1].options.desc)

    autocmd_callback(spec, "q_close_windows", 2) { buf = 9 }
    assert.is_nil(globals.q_close_windows[9])
  end)

  run_case({ buftype = "" }, function(spec, globals, keymap_calls)
    autocmd_callback(spec, "q_close_windows", 1) { buf = 9 }
    assert.equals(true, globals.q_close_windows[9])
    assert.equals(0, #keymap_calls)
  end)
end

T["AUTOCMD-11 restores valid marks once and swallows cursor failures"] = function()
  with_autocmds({ mark = { 4, 2 }, line_count = 8 }, function(spec, calls)
    local callback = autocmd_callback(spec, "restore_cursor")
    callback { buf = 0 }
    callback { buf = 0 }
    assert.same({ 4, 2 }, calls.cursor)
  end)

  with_autocmds({ mark = { 12, 0 }, line_count = 8 }, function(spec, calls)
    autocmd_callback(spec, "restore_cursor") { buf = 0 }
    assert.is_nil(calls.cursor)
  end)

  with_autocmds({ filetype = "gitcommit", mark = { 4, 2 } }, function(spec, calls)
    autocmd_callback(spec, "restore_cursor") { buf = 0 }
    assert.is_nil(calls.cursor)
  end)

  with_autocmds(
    { mark = { 4, 2 }, cursor_error = true },
    function(spec) assert.is_true(pcall(autocmd_callback(spec, "restore_cursor"), { buf = 0 })) end
  )
end

T["AUTOCMD-12 updates hlsearch only for supported search transitions"] = function()
  with_autocmds({ mode = "n", hlsearch = true }, function(spec, _, context)
    local callback = spec.opts.on_keys.auto_hlsearch[1]
    callback "n"
    callback "z"
    assert.equals(true, vim.o.hlsearch)
    context.drain_scheduled()
    callback "z"
    assert.equals(false, vim.o.hlsearch)
  end)

  with_autocmds({ mode = "r" }, function(spec)
    spec.opts.on_keys.auto_hlsearch[1] "x"
    assert.equals(true, vim.o.hlsearch)
  end)

  with_autocmds({ mode = "c", command = "%s/old/new/", incsearch = true }, function(spec)
    local callback = spec.opts.on_keys.auto_hlsearch[1]
    callback "<CR>"
    assert.equals(true, vim.o.hlsearch)
  end)

  with_autocmds({ mode = "c", command = "echo 'not a substitute'", incsearch = true }, function(spec)
    local callback = spec.opts.on_keys.auto_hlsearch[1]
    callback "<CR>"
    assert.equals(false, vim.o.hlsearch)
  end)

  with_autocmds({ mode = "c", command = "s/old/new/", incsearch = false }, function(spec)
    spec.opts.on_keys.auto_hlsearch[1] "<CR>"
    assert.equals(false, vim.o.hlsearch)
  end)
end

T["AUTOCMD-13A closes a complete sidebar layout and leaves duplicate sidebars open"] = function()
  local commands = {}
  unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    replace_vim = { bo = true, cmd = true },
    vim = {
      bo = { [10] = { filetype = "aerial" }, [11] = { filetype = "neo-tree" }, [12] = { filetype = "aerial" } },
      api = {
        nvim_tabpage_list_wins = function() return { 1, 2 } end,
        nvim_win_is_valid = function() return true end,
        nvim_win_get_buf = function(winid) return winid == 1 and 10 or 11 end,
        nvim_list_tabpages = function() return { 1, 2 } end,
      },
      cmd = {
        tabclose = function() table.insert(commands, "tabclose") end,
        qall = function() table.insert(commands, "qall") end,
      },
    },
  }, function(spec)
    autocmd_callback(spec, "auto_quit")()
    assert.same({ "tabclose" }, commands)
  end)

  unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    replace_vim = { bo = true, cmd = true },
    vim = {
      bo = { [10] = { filetype = "aerial" } },
      api = {
        nvim_tabpage_list_wins = function() return { 1, 2 } end,
        nvim_win_is_valid = function() return true end,
        nvim_win_get_buf = function() return 10 end,
        nvim_list_tabpages = function() return { 1 } end,
      },
      cmd = { qall = function() table.insert(commands, "qall") end },
    },
  }, function(spec)
    autocmd_callback(spec, "auto_quit")()
    assert.same({ "tabclose" }, commands)
  end)
end

T["AUTOCMD-13B tracks buffer additions and removals across tab-local lifecycle state"] = function()
  local calls = { events = 0, redraws = 0 }
  local buffer = { current_buf = 1 }
  local valid = { [1] = true, [2] = true, [3] = false }
  unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    loaded = {
      astrocore = {
        event = function(name)
          if name == "BufsUpdated" then calls.events = calls.events + 1 end
        end,
      },
      ["astrocore.buffer"] = {
        is_valid = function(bufnr) return valid[bufnr] == true end,
        current_buf = buffer.current_buf,
        last_buf = buffer.last_buf,
      },
    },
    replace_vim = { t = true, cmd = true },
    vim = {
      t = { bufs = { 1, 3 }, [1] = { bufs = { 1, 2 } }, [2] = { bufs = { 2, 3 } } },
      api = { nvim_list_tabpages = function() return { 1, 2 } end },
      cmd = { redrawtabline = function() calls.redraws = calls.redraws + 1 end },
    },
  }, function(spec)
    local added = autocmd_callback(spec, "bufferline", 1)
    local removed = autocmd_callback(spec, "bufferline", 2)
    added { buf = 2 }
    valid[2] = false
    removed { buf = 2 }

    assert.same({ 1 }, vim.t.bufs)
    assert.same({ 1 }, vim.t[1].bufs)
    assert.same({ 3 }, vim.t[2].bufs)
    assert.equals(2, calls.events)
    assert.equals(1, calls.redraws)
  end)
end

T["AUTOCMD-13C deduplicates AstroFile and GitFile work while preserving replay data"] = function()
  local valid = true
  with_autocmds({
    valid_buffer = function() return valid end,
    git_result = true,
    autocmds = { { group_name = "filetypedetect" }, { group_name = "after" } },
    on_event = function(name)
      if name == "GitFile" then valid = false end
    end,
  }, function(spec, calls, context)
    local callback = autocmd_callback(spec, "file_user_events")
    local data = { source = "preserve" }
    callback { buf = 0, event = "BufReadPost", data = data }
    callback { buf = 0, event = "BufReadPost", data = data }
    context.drain_scheduled()

    assert.same({ "File", "GitFile" }, calls.events)
    assert.same({ "file_user_events" }, calls.deleted)
    assert.equals(0, #calls.exec)
  end)

  with_autocmds({
    autocmd_sequences = {
      { { group_name = "filetypedetect" } },
      { { group_name = "filetypedetect" }, { group_name = "after" } },
    },
  }, function(spec, calls, context)
    local data = { source = "preserve" }
    autocmd_callback(spec, "file_user_events") { buf = 0, event = "BufWritePost", data = data }
    context.drain_scheduled()
    assert.equals(2, #calls.exec)
    assert.same({ "filetypedetect", "after" }, { calls.exec[1].args.group, calls.exec[2].args.group })
    for _, replay in ipairs(calls.exec) do
      assert.equals("BufWritePost", replay.event)
      assert.equals(0, replay.args.buffer)
      assert.equals(data, replay.args.data)
    end
  end)
end

T["AUTOCMD-13D recreates q-close mappings after cache cleanup for eligible buffer types"] = function()
  local mappings = {}
  local globals = {}
  unit_helpers.with_module("astronvim.plugins._astrocore_autocmds", {
    replace_vim = { bo = true },
    vim = {
      g = globals,
      bo = { [9] = { buftype = "help" } },
      api = { nvim_buf_get_keymap = function() return {} end },
      keymap = { set = function(_, _, _, options) table.insert(mappings, options.buffer) end },
    },
  }, function(spec)
    local opened = autocmd_callback(spec, "q_close_windows", 1)
    local deleted = autocmd_callback(spec, "q_close_windows", 2)
    opened { buf = 9 }
    deleted { buf = 9 }
    opened { buf = 9 }

    assert.same({ 9, 9 }, mappings)
    assert.equals(true, globals.q_close_windows[9])
  end)
end

T["AUTOCMD-13E restores cursor only for inclusive valid line boundaries"] = function()
  for _, case in ipairs {
    { mark = { 0, 0 }, line_count = 8, expected = false },
    { mark = { 8, 4 }, line_count = 8, expected = true },
    { mark = { 9, 0 }, line_count = 8, expected = false },
  } do
    with_autocmds(case, function(spec, calls)
      autocmd_callback(spec, "restore_cursor") { buf = 0 }
      assert.equals(case.expected, calls.cursor ~= nil)
    end)
  end
end

T["AUTOCMD-13F applies the complete automatic hlsearch state matrix"] = function()
  for _, case in ipairs {
    { mode = "n", char = "<CR>", expected = true },
    { mode = "n", char = "/", expected = true },
    { mode = "n", char = "z", hlsearch = true, expected = false },
    { mode = "r", char = "x", expected = true },
    { mode = "c", char = "<CR>", command = "'<,'>s/old/new/", expected = true },
    { mode = "c", char = "<CR>", command = "s/old/new/", incsearch = false, expected = false },
  } do
    with_autocmds(case, function(spec, _, context)
      spec.opts.on_keys.auto_hlsearch[1](case.char)
      assert.equals(case.expected, vim.o.hlsearch)
      context.drain_scheduled()
    end)
  end
end

T["OPTIONS-04 preserves unrelated user option, global, tab, and list values"] = function()
  with_options({ tab = { bufs = { 11, 13 } } }, function(options_spec)
    local options = option_values(options_spec, {
      options = {
        opt = { number = false, wildignore = { ".git", "node_modules" }, custom = { keep = true } },
        g = { user_option = "keep" },
        t = { user_buffers = { 21, 34 } },
      },
    })

    assert.equals(false, options.opt.number)
    assert.same({ ".git", "node_modules" }, options.opt.wildignore)
    assert.equals(true, options.opt.custom.keep)
    assert.equals("keep", options.g.user_option)
    assert.same({ 21, 34 }, options.t.user_buffers)
    assert.same({ 11, 13 }, options.t.bufs)
  end)
end

return T
