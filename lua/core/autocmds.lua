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
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- Both neo-tree and aerial will auto-quit if there is only a single window left
    if #wins <= 1 then return end
    local sidebar_fts = { aerial = true, ["neo-tree"] = true }
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        -- If any visible windows are not sidebars, early return
        if not sidebar_fts[vim.api.nvim_buf_get_option(bufnr, "filetype")] then return end
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

augroup("astronvim_highlights", { clear = true })
cmd({ "VimEnter", "ColorScheme" }, {
  desc = "Load custom highlights from user configuration",
  group = "astronvim_highlights",
  callback = function()
    if vim.g.colors_name then
      for _, module in ipairs { "init", vim.g.colors_name } do
        for group, spec in pairs(user_plugin_opts("highlights." .. module)) do
          vim.api.nvim_set_hl(0, group, spec)
        end
      end
    end
  end,
})

create_command("AstroUpdate", function() astronvim.updater.update() end, { desc = "Update AstroNvim" })
create_command("AstroReload", function() astronvim.updater.reload() end, { desc = "Reload AstroNvim" })
create_command("AstroVersion", function() astronvim.updater.version() end, { desc = "Check AstroNvim Version" })
create_command("AstroChangelog", function() astronvim.updater.changelog() end, { desc = "Check AstroNvim Changelog" })
create_command("ToggleHighlightURL", function() astronvim.ui.toggle_url_match() end, { desc = "Toggle URL Highlights" })
