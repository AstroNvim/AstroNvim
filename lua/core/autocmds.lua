local M = {}

local utils = require "core.utils"

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

if utils.is_available "dashboard-nvim" and utils.is_available "bufferline.nvim" then
  vim.cmd [[
    augroup dashboard_settings
      autocmd!
      autocmd FileType dashboard set showtabline=0
      autocmd BufWinLeave <buffer> set showtabline=2
      autocmd BufEnter * if &ft is "dashboard" | set nocursorline | endif
    augroup end
  ]]
end

vim.cmd [[
  command! AstroUpdate lua require('core.utils').update()
]]

return M
