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

local utils = require "core.utils"
local config = utils.user_settings()

local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local add_command = vim.api.nvim_add_user_command

cmd("BufWritePost", {
  desc = "Auto Compile plugins.lua file",
  group = "_buffer",
  command = "PackerCompile",
  pattern = "plugins.lua",
})

augroup("_cursor_off", {})
cmd("WinLeave", {
  desc = "No cursorline",
  group = "_cursor_off",
  command = "set nocursorline",
})
cmd("WinEnter", {
  desc = "No cursorline",
  group = "_cursor_off",
  command = "set cursorline",
})

add_command("AstroUpdate", [[:lua require("core.utils").update()]])

-- if config.enabled.dashboard and config.enabled.bufferline then
--     augroup("_dashboard_settings")
--     cmd("FileType", {
--         group = "_dashboard_settings",
--         pattern = "dashboard",
--         command = "set showtabline=0"
--     })
-- end

return M
