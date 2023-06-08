--- ### AstroNvim Status Highlighting
--
-- Statusline related highlighting utilities
--
-- This module can be loaded with `local hl = require "astronvim.utils.status.hl"`
--
-- @module astronvim.utils.status.hl
-- @copyright 2023
-- @license GNU General Public License v3.0

local M = {}

local env = require "astronvim.utils.status.env"

--- Get the highlight background color of the lualine theme for the current colorscheme
---@param mode string the neovim mode to get the color of
---@param fallback string the color to fallback on if a lualine theme is not present
---@return string # The background color of the lualine theme or the fallback parameter if one doesn't exist
function M.lualine_mode(mode, fallback)
  if not vim.g.colors_name then return fallback end
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
---@return table # the highlight group for the current mode
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.mode },
function M.mode() return { bg = M.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
---@return string # the highlight group for the current mode foreground
-- @usage local heirline_component = require("heirline.utils").surround({ "|", "|" }, require("astronvim.utils.status").hl.mode_bg, heirline_component),

function M.mode_bg() return env.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
---@return table # the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.fileicon(), hl = require("astronvim.utils.status").hl.filetype_color },
function M.filetype_color(self)
  local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
  if not devicons_avail then return {} end
  local _, color = devicons.get_icon_color(
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
    nil,
    { default = true }
  )
  return { fg = color }
end

--- Merge the color and attributes from user settings for a given name
---@param name string, the name of the element to get the attributes and colors for
---@param include_bg? boolean whether or not to include background color (Default: false)
---@return table # a table of highlight information
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.get_attributes("treesitter") },
function M.get_attributes(name, include_bg)
  local hl = env.attributes[name] or {}
  hl.fg = name .. "_fg"
  if include_bg then hl.bg = name .. "_bg" end
  return hl
end

--- Enable filetype color highlight if enabled in icon_highlights.file_icon options
---@param name string the icon_highlights.file_icon table element
---@return function # for setting hl property in a component
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.file_icon("winbar") },
function M.file_icon(name)
  local hl_enabled = env.icon_highlights.file_icon[name]
  return function(self)
    if hl_enabled == true or (type(hl_enabled) == "function" and hl_enabled(self)) then
      return M.filetype_color(self)
    end
  end
end

return M
