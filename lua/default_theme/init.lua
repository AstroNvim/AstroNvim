vim.cmd { cmd = "highlight", args = { "clear" } }
if vim.fn.exists "syntax_on" then
  vim.cmd { cmd = "syntax", args = { "reset" } }
end
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
  if enabled then
    highlights = vim.tbl_deep_extend("force", highlights, require("default_theme.plugins." .. plugin))
  end
end

for group, spec in pairs(user_plugin_opts("default_theme.highlights", highlights)) do
  vim.api.nvim_set_hl(0, group, utils.parse_style(spec))
end
