local M = {}

local utils = require "core.utils"
local colorscheme = utils.user_plugin_opts "colorscheme"

local set = vim.opt
local g = vim.g

vim.api.nvim_command(("colorscheme %s"):format(colorscheme))

set.fileencoding = "utf-8" -- File content encoding for the buffer
set.spelllang = "en" -- Support US english
set.clipboard = "unnamedplus" -- Connection to the system clipboard
set.mouse = "a" -- Enable mouse support
set.signcolumn = "yes" -- Always show the sign column
set.foldmethod = "manual" -- Create folds manually
set.completeopt = { "menuone", "noselect" } -- Options for insert mode completion
set.colorcolumn = "99999" -- Fix for the indentline problem
set.backup = false -- Disable making a backup file
set.expandtab = true -- Enable the use of space in tab
set.hidden = true -- Ignore unsaved buffers
set.hlsearch = true -- Highlight all the matches of search pattern
set.ignorecase = true -- Case insensitive searching
set.smartcase = true -- Case sensitivie searching
set.spell = false -- Disable spelling checking and highlighting
set.showmode = false -- Disable showing modes in command line
set.smartindent = true -- Do auto indenting when starting a new line
set.splitbelow = true -- Splitting a new window below the current one
set.splitright = true -- Splitting a new window at the right of the current one
set.swapfile = false -- Disable use of swapfile for the buffer
set.termguicolors = true -- Enable 24-bit RGB color in the TUI
set.undofile = true -- Enable persistent undo
set.writebackup = false -- Disable making a backup before overwriting a file
set.cursorline = true -- Highlight the text line of the cursor
set.number = true -- Show numberline
set.relativenumber = true -- Show relative numberline
set.wrap = false -- Disable wrapping of lines longer than the width of window
set.conceallevel = 0 -- Show text normally
set.cmdheight = 1 -- Number of screen lines to use for the command line
set.shiftwidth = 2 -- Number of space inserted for indentation
set.tabstop = 2 -- Number of space in a tab
set.scrolloff = 8 -- Number of lines to keep above and below the cursor
set.sidescrolloff = 8 -- Number of columns to keep at the sides of the cursor
set.pumheight = 10 -- Height of the pop up menu
set.history = 100 -- Number of commands to remember in a history table
set.timeoutlen = 300 -- Length of time to wait for a mapped sequence
set.updatetime = 300 -- Length of time to wait before triggering the plugin
set.fillchars = { eob = " " } -- Disable `~` on nonexistent lines

g.do_filetype_lua = 1 -- use filetype.lua
g.did_load_filetypes = 0 -- don't use filetype.vim

return M
