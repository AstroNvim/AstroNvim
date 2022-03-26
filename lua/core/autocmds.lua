-- local M = {}

-- local utils = require "core.utils"
-- local config = utils.user_settings()

-- vim.cmd [[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins.lua source <afile> | PackerCompile
--   augroup end
-- ]]

-- vim.cmd [[
--   augroup cursor_off
--     autocmd!
--     autocmd WinLeave * set nocursorline
--     autocmd WinEnter * set cursorline
--   augroup end
-- ]]

-- if config.enabled.dashboard and config.enabled.bufferline then
--   vim.cmd [[
--     augroup dashboard_settings
--       autocmd!
--       autocmd FileType dashboard set showtabline=0
--       autocmd BufWinLeave <buffer> set showtabline=2
--       autocmd BufEnter * if &ft is "dashboard" | set nocursorline | endif
--     augroup end
--   ]]
-- end

-- vim.cmd [[
--   command! AstroUpdate lua require('core.utils').update()
-- ]]

-- return M

local M = {}

local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local add_command = vim.api.nvim_add_user_command

augroup("packer_user_config", {})
cmd("BufWritePost", {
  desc = "Auto Compile plugins.lua file",
  group = "packer_user_config",
  command = "PackerCompile",
  pattern = "plugins.lua",
})

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

-- if config.enabled.dashboard and config.enabled.bufferline then
--     augroup("_dashboard_settings")
--     cmd("FileType", {
--         group = "_dashboard_settings",
--         pattern = "dashboard",
--         command = "set showtabline=0"
--     })
-- end

add_command("AstroUpdate", require("core.utils").update, {})

return M
