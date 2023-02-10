local namespace = vim.api.nvim_create_namespace
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local utils = require "core.utils"
local is_available = utils.is_available
local astroevent = utils.event

vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, namespace "auto_hlsearch")

local bufferline_group = augroup("bufferline", { clear = true })
autocmd({ "BufAdd", "BufEnter" }, {
  desc = "Update buffers when adding new buffers",
  group = bufferline_group,
  callback = function(args)
    if not vim.t.bufs then vim.t.bufs = {} end
    local bufs = vim.t.bufs
    if not vim.tbl_contains(bufs, args.buf) then
      table.insert(bufs, args.buf)
      vim.t.bufs = bufs
    end
    vim.t.bufs = vim.tbl_filter(require("core.utils.buffer").is_valid, vim.t.bufs)
    astroevent "BufsUpdated"
  end,
})
autocmd("BufDelete", {
  desc = "Update buffers when deleting buffers",
  group = bufferline_group,
  callback = function(args)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local bufs = vim.t[tab].bufs
      if bufs then
        for i, bufnr in ipairs(bufs) do
          if bufnr == args.buf then
            table.remove(bufs, i)
            vim.t[tab].bufs = bufs
            break
          end
        end
      end
    end
    vim.t.bufs = vim.tbl_filter(require("core.utils.buffer").is_valid, vim.t.bufs)
    astroevent "BufsUpdated"
    vim.cmd.redrawtabline()
  end,
})

autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = augroup("highlighturl", { clear = true }),
  pattern = "*",
  callback = function() utils.set_url_match() end,
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
  local group_name = augroup("alpha_settings", { clear = true })
  autocmd("User", {
    desc = "Disable status and tablines for alpha",
    group = group_name,
    pattern = "AlphaReady",
    callback = function()
      local prev_showtabline = vim.opt.showtabline
      local prev_status = vim.opt.laststatus
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
      vim.opt_local.winbar = nil
      autocmd("BufUnload", {
        pattern = "<buffer>",
        callback = function()
          vim.opt.laststatus = prev_status
          vim.opt.showtabline = prev_showtabline
        end,
      })
    end,
  })
  autocmd("VimEnter", {
    desc = "Start Alpha when vim is opened with no arguments",
    group = group_name,
    callback = function()
      local should_skip = false
      if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 or not vim.o.modifiable then
        should_skip = true
      else
        for _, arg in pairs(vim.v.argv) do
          if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
            should_skip = true
            break
          end
        end
      end
      if not should_skip then require("alpha").start(true, require("alpha").default_config) end
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
        local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == "directory" then
          require "neo-tree"
          vim.api.nvim_del_augroup_by_name "neotree_start"
          vim.api.nvim_exec_autocmds("BufEnter", {})
        end
      end
    end,
  })
end

if is_available "nvim-dap-ui" then
  autocmd("FileType", {
    desc = "Make q close dap floating windows",
    group = augroup("dapui", { clear = true }),
    pattern = "dap-float",
    callback = function() vim.keymap.set("n", "q", "<cmd>close!<cr>") end,
  })
end

autocmd({ "VimEnter", "ColorScheme" }, {
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
    astroevent "ColorScheme"
  end,
})

autocmd("BufRead", {
  group = augroup("git_plugin_lazy_load", { clear = true }),
  callback = function()
    vim.fn.system('git -C "' .. vim.fn.expand "%:p:h" .. '" rev-parse')
    if vim.v.shell_error == 0 then
      vim.api.nvim_del_augroup_by_name "git_plugin_lazy_load"
      if #astronvim.git_plugins > 0 then
        vim.schedule(function() require("lazy").load { plugins = astronvim.git_plugins } end)
      end
    end
  end,
})
autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
  group = augroup("file_plugin_lazy_load", { clear = true }),
  callback = function(args)
    if not (vim.fn.expand "%" == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
      vim.api.nvim_del_augroup_by_name "file_plugin_lazy_load"
      if #astronvim.file_plugins > 0 then
        if vim.tbl_contains(astronvim.file_plugins, "nvim-treesitter") then
          require("lazy").load { plugins = { "nvim-treesitter" } }
        end
        vim.schedule(function() require("lazy").load { plugins = astronvim.file_plugins } end)
      end
    end
  end,
})

local cmd = vim.api.nvim_create_user_command
cmd(
  "AstroUpdatePackages",
  function() require("core.utils.updater").update_packages() end,
  { desc = "Update Plugins and Mason" }
)
cmd("AstroUpdate", function() require("core.utils.updater").update() end, { desc = "Update AstroNvim" })
cmd("AstroRollback", function() require("core.utils.updater").rollback() end, { desc = "Rollback AstroNvim" })
cmd("AstroVersion", function() require("core.utils.updater").version() end, { desc = "Check AstroNvim Version" })
cmd("AstroChangelog", function() require("core.utils.updater").changelog() end, { desc = "Check AstroNvim Changelog" })
cmd(
  "ToggleHighlightURL",
  function() require("core.utils.ui").toggle_url_match() end,
  { desc = "Toggle URL Highlights" }
)
