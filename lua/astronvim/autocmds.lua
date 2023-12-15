local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.api.nvim_create_user_command
local namespace = vim.api.nvim_create_namespace

local utils = require "astronvim.utils"
local is_available = utils.is_available
local astroevent = utils.event

vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, namespace "auto_hlsearch")

autocmd("BufReadPre", {
  desc = "Disable certain functionality on very large files",
  group = augroup("large_buf", { clear = true }),
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    vim.b[args.buf].large_buf = (ok and stats and stats.size > vim.g.max_file.size)
      or vim.api.nvim_buf_line_count(args.buf) > vim.g.max_file.lines
  end,
})

local terminal_settings_group = augroup("terminal_settings", { clear = true })
-- TODO: drop when dropping support for Neovim v0.9
if vim.fn.has "nvim-0.9" == 1 and vim.fn.has "nvim-0.9.4" == 0 then
  -- HACK: Disable custom statuscolumn for terminals because truncation/wrapping bug
  -- https://github.com/neovim/neovim/issues/25472
  autocmd("TermOpen", {
    group = terminal_settings_group,
    desc = "Disable custom statuscolumn for terminals to fix neovim/neovim#25472",
    callback = function() vim.opt_local.statuscolumn = nil end,
  })
end
autocmd("TermOpen", {
  group = terminal_settings_group,
  desc = "Disable foldcolumn and signcolumn for terinals",
  callback = function()
    vim.opt_local.foldcolumn = "0"
    vim.opt_local.signcolumn = "no"
  end,
})

local bufferline_group = augroup("bufferline", { clear = true })
autocmd({ "BufAdd", "BufEnter", "TabNewEntered" }, {
  desc = "Update buffers when adding new buffers",
  group = bufferline_group,
  callback = function(args)
    local buf_utils = require "astronvim.utils.buffer"
    if not vim.t.bufs then vim.t.bufs = {} end
    if not buf_utils.is_valid(args.buf) then return end
    if args.buf ~= buf_utils.current_buf then
      buf_utils.last_buf = buf_utils.is_valid(buf_utils.current_buf) and buf_utils.current_buf or nil
      buf_utils.current_buf = args.buf
    end
    local bufs = vim.t.bufs
    if not vim.tbl_contains(bufs, args.buf) then
      table.insert(bufs, args.buf)
      vim.t.bufs = bufs
    end
    vim.t.bufs = vim.tbl_filter(buf_utils.is_valid, vim.t.bufs)
    astroevent "BufsUpdated"
  end,
})
autocmd({ "BufDelete", "TermClose" }, {
  desc = "Update buffers when deleting buffers",
  group = bufferline_group,
  callback = function(args)
    local removed
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local bufs = vim.t[tab].bufs
      if bufs then
        for i, bufnr in ipairs(bufs) do
          if bufnr == args.buf then
            removed = true
            table.remove(bufs, i)
            vim.t[tab].bufs = bufs
            break
          end
        end
      end
    end
    vim.t.bufs = vim.tbl_filter(require("astronvim.utils.buffer").is_valid, vim.t.bufs)
    if removed then astroevent "BufsUpdated" end
    vim.cmd.redrawtabline()
  end,
})

autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = augroup("highlighturl", { clear = true }),
  callback = function() utils.set_url_match() end,
})

local view_group = augroup("auto_view", { clear = true })
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
  desc = "Save view with mkview for real files",
  group = view_group,
  callback = function(args)
    if vim.b[args.buf].view_activated then vim.cmd.mkview { mods = { emsg_silent = true } } end
  end,
})
autocmd("BufWinEnter", {
  desc = "Try to load file view if available and enable view saving for real files",
  group = view_group,
  callback = function(args)
    if not vim.b[args.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
      local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
      if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[args.buf].view_activated = true
        vim.cmd.loadview { mods = { emsg_silent = true } }
      end
    end
  end,
})

autocmd("BufWinEnter", {
  desc = "Make q close help, man, quickfix, dap floats",
  group = augroup("q_close_windows", { clear = true }),
  callback = function(args)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) and vim.fn.maparg("q", "n") == "" then
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        desc = "Close window",
        buffer = args.buf,
        silent = true,
        nowait = true,
      })
    end
  end,
})

autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlightyank", { clear = true }),
  pattern = "*",
  callback = function() vim.highlight.on_yank() end,
})

autocmd("FileType", {
  desc = "Unlist quickfist buffers",
  group = augroup("unlist_quickfist", { clear = true }),
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

autocmd("BufEnter", {
  desc = "Quit AstroNvim if more than one window is open and only sidebar windows are list",
  group = augroup("auto_quit", { clear = true }),
  callback = function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- Both neo-tree and aerial will auto-quit if there is only a single window left
    if #wins <= 1 then return end
    local sidebar_fts = { aerial = true, ["neo-tree"] = true }
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        -- If any visible windows are not sidebars, early return
        if not sidebar_fts[filetype] then
          return
        -- If the visible window is a sidebar
        else
          -- only count filetypes once, so remove a found sidebar from the detection
          sidebar_fts[filetype] = nil
        end
      end
    end
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else
      vim.cmd.qall()
    end
  end,
})

if is_available "alpha-nvim" then
  autocmd({ "User", "BufWinEnter" }, {
    desc = "Disable status, tablines, and cmdheight for alpha",
    group = augroup("alpha_settings", { clear = true }),
    callback = function(args)
      if
        (
          (args.event == "User" and args.file == "AlphaReady")
          or (args.event == "BufWinEnter" and vim.api.nvim_get_option_value("filetype", { buf = args.buf }) == "alpha")
        ) and not vim.g.before_alpha
      then
        vim.g.before_alpha = {
          showtabline = vim.opt.showtabline:get(),
          laststatus = vim.opt.laststatus:get(),
          cmdheight = vim.opt.cmdheight:get(),
        }
        vim.opt.showtabline, vim.opt.laststatus, vim.opt.cmdheight = 0, 0, 0
      elseif
        vim.g.before_alpha
        and args.event == "BufWinEnter"
        and vim.api.nvim_get_option_value("buftype", { buf = args.buf }) ~= "nofile"
      then
        vim.opt.laststatus, vim.opt.showtabline, vim.opt.cmdheight =
          vim.g.before_alpha.laststatus, vim.g.before_alpha.showtabline, vim.g.before_alpha.cmdheight
        vim.g.before_alpha = nil
      end
    end,
  })
  autocmd("VimEnter", {
    desc = "Start Alpha when vim is opened with no arguments",
    group = augroup("alpha_autostart", { clear = true }),
    callback = function()
      local should_skip
      local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
      if
        vim.fn.argc() > 0 -- don't start when opening a file
        or #lines > 1 -- don't open if current buffer has more than 1 line
        or (#lines == 1 and lines[1]:len() > 0) -- don't open the current buffer if it has anything on the first line
        or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
        or not vim.o.modifiable -- don't open if not modifiable
      then
        should_skip = true
      else
        for _, arg in pairs(vim.v.argv) do
          if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
            should_skip = true
            break
          end
        end
      end
      if should_skip then return end
      require("alpha").start(true, require("alpha").default_config)
      vim.schedule(function() vim.cmd.doautocmd "FileType" end)
    end,
  })
end

-- HACK: indent blankline doesn't properly refresh when scrolling the window
-- remove when fixed upstream: https://github.com/lukas-reineke/indent-blankline.nvim/issues/489
if is_available "indent-blankline.nvim" then
  autocmd("WinScrolled", {
    desc = "Refresh indent blankline on window scroll",
    group = augroup("indent_blankline_refresh_scroll", { clear = true }),
    callback = function()
      -- TODO: remove neovim version check when dropping support for Neovim 0.8
      if vim.fn.has "nvim-0.9" ~= 1 or (vim.v.event.all and vim.v.event.all.leftcol ~= 0) then
        pcall(vim.cmd.IndentBlanklineRefresh)
      end
    end,
  })
end

if is_available "resession.nvim" then
  autocmd("VimLeavePre", {
    desc = "Save session on close",
    group = augroup("resession_auto_save", { clear = true }),
    callback = function()
      local buf_utils = require "astronvim.utils.buffer"
      local autosave = buf_utils.sessions.autosave
      if autosave and buf_utils.is_valid_session() then
        local save = require("resession").save
        if autosave.last then save("Last Session", { notify = false }) end
        if autosave.cwd then save(vim.fn.getcwd(), { dir = "dirsession", notify = false }) end
      end
    end,
  })
end

if is_available "neo-tree.nvim" then
  autocmd("BufEnter", {
    desc = "Open Neo-Tree on startup with directory",
    group = augroup("neotree_start", { clear = true }),
    callback = function()
      if package.loaded["neo-tree"] then
        vim.api.nvim_del_augroup_by_name "neotree_start"
      else
        local stats = (vim.uv or vim.loop).fs_stat(vim.api.nvim_buf_get_name(0)) -- TODO: REMOVE vim.loop WHEN DROPPING SUPPORT FOR Neovim v0.9
        if stats and stats.type == "directory" then
          vim.api.nvim_del_augroup_by_name "neotree_start"
          require "neo-tree"
        end
      end
    end,
  })
  autocmd("TermClose", {
    pattern = "*lazygit*",
    desc = "Refresh Neo-Tree when closing lazygit",
    group = augroup("neotree_refresh", { clear = true }),
    callback = function()
      local manager_avail, manager = pcall(require, "neo-tree.sources.manager")
      if manager_avail then
        for _, source in ipairs { "filesystem", "git_status", "document_symbols" } do
          local module = "neo-tree.sources." .. source
          if package.loaded[module] then manager.refresh(require(module).name) end
        end
      end
    end,
  })
end

autocmd("ColorScheme", {
  desc = "Load custom highlights from user configuration",
  group = augroup("astronvim_highlights", { clear = true }),
  callback = function()
    if vim.g.colors_name then
      for _, module in ipairs { "init", vim.g.colors_name } do
        for group, spec in pairs(astronvim.user_opts("highlights." .. module)) do
          vim.api.nvim_set_hl(0, group, spec)
        end
      end
    end
    astroevent("ColorScheme", false)
  end,
})

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  desc = "AstroNvim user events for file detection (AstroFile and AstroGitFile)",
  group = augroup("file_user_events", { clear = true }),
  callback = function(args)
    local current_file = vim.fn.resolve(vim.fn.expand "%")
    if not (current_file == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
      astroevent "File"
      if
        require("astronvim.utils.git").file_worktree()
        or utils.cmd({ "git", "-C", vim.fn.fnamemodify(current_file, ":p:h"), "rev-parse" }, false)
      then
        astroevent "GitFile"
        vim.api.nvim_del_augroup_by_name "file_user_events"
      end
    end
  end,
})

cmd(
  "AstroChangelog",
  function() require("astronvim.utils.updater").changelog() end,
  { desc = "Check AstroNvim Changelog" }
)
cmd(
  "AstroUpdatePackages",
  function() require("astronvim.utils.updater").update_packages() end,
  { desc = "Update Plugins and Mason" }
)
cmd("AstroRollback", function() require("astronvim.utils.updater").rollback() end, { desc = "Rollback AstroNvim" })
cmd("AstroUpdate", function() require("astronvim.utils.updater").update() end, { desc = "Update AstroNvim" })
cmd("AstroVersion", function() require("astronvim.utils.updater").version() end, { desc = "Check AstroNvim Version" })
cmd("AstroReload", function() require("astronvim.utils").reload() end, { desc = "Reload AstroNvim (Experimental)" })
