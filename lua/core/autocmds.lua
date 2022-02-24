local M = {}

local utils = require "core.utils"
local config = utils.user_settings()
local colorscheme = config.colorscheme

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]]

vim.cmd [[
  augroup cursor_off
    autocmd!
    autocmd WinLeave * set nocursorline
    autocmd WinEnter * set cursorline
  augroup end
]]

if config.enabled.dashboard and config.enabled.bufferline then
  vim.cmd [[
    augroup dashboard_settings
      autocmd!
      autocmd FileType dashboard set showtabline=0
      autocmd BufWinLeave <buffer> set showtabline=2
      autocmd BufEnter * if &ft is "dashboard" | set laststatus=0 | else | set laststatus=2 | endif
      autocmd BufEnter * if &ft is "dashboard" | set nocursorline | endif
    augroup end
  ]]
end

vim.cmd(string.format(
  [[
    augroup colorscheme
      autocmd!
      autocmd VimEnter * colorscheme %s
    augroup end]],
  colorscheme
))

vim.cmd [[
  command! AstroUpdate lua require('core.utils').update()
]]

return M
