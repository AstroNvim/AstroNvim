
-- general
-------------------------------------------------------
vim.g.maplocalleader = ','
vim.wo.relativenumber = false
vim.o.number = true
vim.wo.number = true
-- vim.o.cmdheight=2

-- timeing:
-------------------------------------------------------
vim.opt.timeoutlen=300   --- Time out on mappings
vim.opt.ttimeoutlen=10   --- Time out on key codes
vim.opt.updatetime=200   --- Idle time to write swap and trigger CursorHold
vim.opt.redrawtime=2000  --- Time in milliseconds for stopping display redraw

-- colors:
-------------------------------------------------------
local colorscheme =  'onehalflight' -- 'default_theme' --'onehalflight' , 'onehalfdark'
vim.cmd(string.format("colorscheme %s", colorscheme))
-- vim.o.background = 'light'



-- see also: https://github.com/LunarVim/LunarVim/blob/f1779fddcc34a8ad4cd0af0bc1e3a83f42844dbe/lua/lvim/config/settings.lua    
--
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.cmdheight = 2 -- more space in the neovim command line for displaying messages
vim.opt.colorcolumn = "99999" -- fixes indentline for now
-- vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
-- vim.opt.foldmethod = "manual" -- folding, set to "expr" for treesitter based folding
-- vim.opt.foldexpr = "" -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
-- vim.opt.guifont = "monospace:h17" -- the font used in graphical neovim applications
vim.opt.hidden = true -- required to keep multiple buffers and open multiple buffers
vim.opt.hlsearch = true -- highlight all matches on previous search pattern
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.smartcase = true
