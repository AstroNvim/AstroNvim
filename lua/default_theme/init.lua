vim.cmd "hi clear"
if vim.fn.exists "syntax_on" then
  vim.cmd "syntax reset"
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "default_theme"

C = require "default_theme.colors"

local util = require "default_theme.util"
local base = require "default_theme.base"
local treesitter = require "default_theme.treesitter"
local lsp = require "default_theme.lsp"
local others = require "default_theme.others"

local default_theme = {
  base,
  treesitter,
  lsp,
  others,
}

for _, file in ipairs(default_theme) do
  for group, colors in pairs(file) do
    util.highlight(group, colors)
  end
end
