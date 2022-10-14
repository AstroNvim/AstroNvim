astronvim.initialize_packer()

local colorscheme = astronvim.user_plugin_opts("colorscheme", nil, false)
vim.cmd.colorscheme(vim.tbl_contains(vim.fn.getcompletion("", "color"), colorscheme) and colorscheme or "default_theme")
