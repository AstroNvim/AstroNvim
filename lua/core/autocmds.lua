local M = {}

local utils = require "core.utils"

local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local create_command = vim.api.nvim_create_user_command

augroup("cursor_off", {})
cmd("WinLeave", {
  desc = "No cursorline",
  group = "cursor_off",
  command = "set nocursorline",
})
cmd("WinEnter", {
  desc = "No cursorline",
  group = "cursor_off",
  command = "set cursorline",
})

augroup("highlighturl", {})
cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = "highlighturl",
  pattern = "*",
  callback = require("core.utils").set_url_match,
})

if utils.is_available "dashboard-nvim" then
  augroup("dashboard_settings", {})
  if utils.is_available "bufferline.nvim" then
    cmd("FileType", {
      desc = "Disable tabline for dashboard",
      group = "dashboard_settings",
      pattern = "dashboard",
      command = "set showtabline=0",
    })
    cmd("BufWinLeave", {
      desc = "Reenable tabline when leaving dashboard",
      group = "dashboard_settings",
      pattern = "<buffer>",
      command = "set showtabline=2",
    })
  end
  cmd("FileType", {
    desc = "Disable statusline for dashboard",
    group = "dashboard_settings",
    pattern = "dashboard",
    command = "set laststatus=0",
  })
  cmd("BufWinLeave", {
    desc = "Reenable statusline when leaving dashboard",
    group = "dashboard_settings",
    pattern = "<buffer>",
    command = "set laststatus=3",
  })
  cmd("BufEnter", {
    desc = "No cursorline on dashboard",
    group = "dashboard_settings",
    pattern = "*",
    command = "if &ft is 'dashboard' | set nocursorline | endif",
  })
end

create_command("AstroUpdate", require("core.utils").update, { desc = "Update AstroNvim" })

create_command("ToggleHighlightURL", require("core.utils").toggle_url_match, { desc = "Toggle URL Highlights" })

return M
