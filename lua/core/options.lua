local M = {}

local utils = require "core.utils"
local colorscheme = utils.user_plugin_opts "colorscheme"

local set = vim.opt
local g = vim.g

vim.api.nvim_command(("colorscheme %s"):format(colorscheme))

set.clipboard = "unnamedplus" -- Connection to the system clipboard
set.completeopt = { "menuone", "noselect" } -- Options for insert mode completion
set.copyindent = true -- Copy the previous indentation on autoindenting
set.cursorline = true -- Highlight the text line of the cursor
set.expandtab = true -- Enable the use of space in tab
set.fileencoding = "utf-8" -- File content encoding for the buffer
set.fillchars = { eob = " " } -- Disable `~` on nonexistent lines
set.history = 100 -- Number of commands to remember in a history table
set.ignorecase = true -- Case insensitive searching
set.mouse = "a" -- Enable mouse support
set.number = true -- Show numberline
set.preserveindent = true -- Preserve indent structure as much as possible
set.pumheight = 10 -- Height of the pop up menu
set.relativenumber = true -- Show relative numberline
set.scrolloff = 8 -- Number of lines to keep above and below the cursor
set.shiftwidth = 2 -- Number of space inserted for indentation
set.showmode = false -- Disable showing modes in command line
set.sidescrolloff = 8 -- Number of columns to keep at the sides of the cursor
set.signcolumn = "yes" -- Always show the sign column
set.smartcase = true -- Case sensitivie searching
set.splitbelow = true -- Splitting a new window below the current one
set.splitright = true -- Splitting a new window at the right of the current one
set.swapfile = false -- Disable use of swapfile for the buffer
set.tabstop = 2 -- Number of space in a tab
set.termguicolors = true -- Enable 24-bit RGB color in the TUI
set.timeoutlen = 300 -- Length of time to wait for a mapped sequence
set.undofile = true -- Enable persistent undo
set.updatetime = 300 -- Length of time to wait before triggering the plugin
set.wrap = false -- Disable wrapping of lines longer than the width of window
set.writebackup = false -- Disable making a backup before overwriting a file

g.do_filetype_lua = 1 -- use filetype.lua
g.did_load_filetypes = 0 -- don't use filetype.vim
g.highlighturl_enabled = true -- highlight URLs by default

return M
