local M = {}

local utils = require "core.utils"

local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local create_command = vim.api.nvim_create_user_command

augroup("highlighturl", { clear = true })
cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = "highlighturl",
  pattern = "*",
  callback = require("core.utils").set_url_match,
})

if utils.is_available "alpha-nvim" then
  augroup("alpha_settings", { clear = true })
  if utils.is_available "bufferline.nvim" then
    cmd("FileType", {
      desc = "Disable tabline for alpha",
      group = "alpha_settings",
      pattern = "alpha",
      command = "set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2",
    })
  end
  cmd("FileType", {
    desc = "Disable statusline for alpha",
    group = "alpha_settings",
    pattern = "alpha",
    command = "set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3",
  })
end

create_command("AstroUpdate", require("core.utils").update, { desc = "Update AstroNvim" })

create_command("ToggleHighlightURL", require("core.utils").toggle_url_match, { desc = "Toggle URL Highlights" })

return M
