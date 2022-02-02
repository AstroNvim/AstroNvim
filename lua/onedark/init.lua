vim.cmd "hi clear"
if vim.fn.exists "syntax_on" then
  vim.cmd "syntax reset"
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "onedark"

C = require "onedark.colors"

local util = require "onedark.util"
local base = require "onedark.base"
local treesitter = require "onedark.treesitter"
local lsp = require "onedark.lsp"
local others = require "onedark.others"

local onedark = {
  base,
  treesitter,
  lsp,
  others,
}

for _, file in ipairs(onedark) do
  for group, colors in pairs(file) do
    util.highlight(group, colors)
  end
end
