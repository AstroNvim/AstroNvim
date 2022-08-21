vim.cmd "highlight clear"
if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "default_theme"

local user_plugin_opts = astronvim.user_plugin_opts
local utils = require "default_theme.utils"

C = require "default_theme.colors"

local highlights = {}

for _, module in ipairs { "base", "treesitter", "lsp" } do
  highlights = vim.tbl_deep_extend("force", highlights, require("default_theme." .. module))
end

for plugin, enabled in
  pairs(user_plugin_opts("default_theme.plugins", {
    aerial = true,
    beacon = false,
    bufferline = true,
    dashboard = true,
    gitsigns = true,
    highlighturl = true,
    hop = false,
    indent_blankline = true,
    lightspeed = false,
    ["neo-tree"] = true,
    notify = true,
    ["nvim-tree"] = false,
    ["nvim-web-devicons"] = true,
    rainbow = true,
    symbols_outline = false,
    telescope = true,
    vimwiki = false,
    ["which-key"] = true,
  }))
do
  if enabled then highlights = vim.tbl_deep_extend("force", highlights, require("default_theme.plugins." .. plugin)) end
end

for group, spec in pairs(user_plugin_opts("default_theme.highlights", highlights)) do
  vim.api.nvim_set_hl(0, group, utils.parse_style(spec))
end

astronvim.vim_opts {
  g = {
    terminal_color_0 = C.terminal_color_0 or C.bg,
    terminal_color_1 = C.terminal_color_1 or C.red,
    terminal_color_2 = C.terminal_color_2 or C.green_1,
    terminal_color_3 = C.terminal_color_3 or C.yellow_1,
    terminal_color_4 = C.terminal_color_4 or C.blue,
    terminal_color_5 = C.terminal_color_5 or C.purple_1,
    terminal_color_6 = C.terminal_color_6 or C.cyan,
    terminal_color_7 = C.terminal_color_7 or C.white,
    terminal_color_8 = C.terminal_color_8 or C.white_1,
    terminal_color_9 = C.terminal_color_9 or C.red_5,
    terminal_color_10 = C.terminal_color_10 or C.green,
    terminal_color_11 = C.terminal_color_11 or C.yellow,
    terminal_color_12 = C.terminal_color_12 or C.blue_4,
    terminal_color_13 = C.terminal_color_13 or C.purple_2,
    terminal_color_14 = C.terminal_color_14 or C.cyan_1,
    terminal_color_15 = C.terminal_color_15 or C.fg,
  },
}
