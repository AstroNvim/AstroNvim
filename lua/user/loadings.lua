
-- local source_dir = vim.fn.fnamemodify(vim.fn.expand('<sfile>'), ':h')
-- if vim.fn.filereadable(source_dir .. '/xyz.lua') then ... end

require("user.local.settings")

require("user.settings")
require("user.autocommands")
require("user.commands")
require("user.keybindings").unmapKeys()
require("user.keybindings").generalVimKeys()
require("user.keybindings").comment()
require("user.keybindings").floating_win()

-- require("user.which-keys")
vim.api.nvim_set_keymap("n", "mw", "<Plug>kommentary_line_default", {})
