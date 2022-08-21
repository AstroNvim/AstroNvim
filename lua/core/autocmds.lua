local is_available = astronvim.is_available
local user_plugin_opts = astronvim.user_plugin_opts
local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local create_command = vim.api.nvim_create_user_command

augroup("highlighturl", { clear = true })
cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = "highlighturl",
  pattern = "*",
  callback = function() astronvim.set_url_match() end,
})

augroup("auto_quit", { clear = true })
cmd("BufEnter", {
  desc = "Quit AstroNvim if more than one window is open and only sidebar windows are list",
  group = "auto_quit",
  callback = function()
    local num_wins = #vim.api.nvim_list_wins()
    local sidebar_fts = { "aerial", "neo-tree" }
    local sidebars = {}
    vim.tbl_map(function(bufnr)
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if vim.tbl_contains(sidebar_fts, ft) then sidebars[ft] = true end
    end, vim.api.nvim_list_bufs())
    if num_wins > 1 and vim.tbl_count(sidebars) == num_wins then vim.cmd "quit" end
  end,
})

if is_available "alpha-nvim" then
  augroup("alpha_settings", { clear = true })
  if is_available "bufferline.nvim" then
    cmd("FileType", {
      desc = "Disable tabline for alpha",
      group = "alpha_settings",
      pattern = "alpha",
      callback = function()
        local prev_showtabline = vim.opt.showtabline
        vim.opt.showtabline = 0
        cmd("BufUnload", {
          pattern = "<buffer>",
          callback = function() vim.opt.showtabline = prev_showtabline end,
        })
      end,
    })
  end
  cmd("FileType", {
    desc = "Disable statusline for alpha",
    group = "alpha_settings",
    pattern = "alpha",
    callback = function()
      local prev_status = vim.opt.laststatus
      vim.opt.laststatus = 0
      cmd("BufUnload", {
        pattern = "<buffer>",
        callback = function() vim.opt.laststatus = prev_status end,
      })
    end,
  })
  cmd("VimEnter", {
    desc = "Start Alpha when vim is opened with no arguments",
    group = "alpha_settings",
    callback = function()
      -- optimized start check from https://github.com/goolord/alpha-nvim
      local alpha_avail, alpha = pcall(require, "alpha")
      if alpha_avail then
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
        if not should_skip then alpha.start(true) end
      end
    end,
  })
end

if is_available "neo-tree.nvim" then
  augroup("neotree_start", { clear = true })
  cmd("BufEnter", {
    desc = "Open Neo-Tree on startup with directory",
    group = "neotree_start",
    callback = function()
      local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
      if stats and stats.type == "directory" then require("neo-tree.setup.netrw").hijack() end
    end,
  })
end

if is_available "feline.nvim" then
  augroup("feline_setup", { clear = true })
  cmd("ColorScheme", {
    desc = "Reload feline on colorscheme change",
    group = "feline_setup",
    callback = function()
      package.loaded["configs.feline"] = nil
      require "configs.feline"
    end,
  })
end

augroup("astronvim_highlights", { clear = true })
cmd({ "VimEnter", "ColorScheme" }, {
  desc = "Load custom highlights from user configuration",
  group = "astronvim_highlights",
  callback = function()
    if vim.g.colors_name then
      for group, spec in pairs(user_plugin_opts("highlights." .. vim.g.colors_name)) do
        vim.api.nvim_set_hl(0, group, spec)
      end
    end
  end,
})

create_command("AstroUpdate", function() astronvim.updater.update() end, { desc = "Update AstroNvim" })
create_command("AstroReload", function() astronvim.updater.reload() end, { desc = "Reload AstroNvim" })
create_command("AstroVersion", function() astronvim.updater.version() end, { desc = "Check AstroNvim Version" })
create_command("ToggleHighlightURL", astronvim.toggle_url_match, { desc = "Toggle URL Highlights" })
