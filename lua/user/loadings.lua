
require("user.settings")
require("user.autocommands")
require("user.commands")
require("user.keybindings").unmapKeys()
require("user.keybindings").generalVimKeys()
require("user.keybindings").comment()
require("user.keybindings").terminal()
-- require("user.which-keys")
vim.api.nvim_set_keymap("n", "mw", "<Plug>kommentary_line_default", {})

-- onehalflight  -- 

