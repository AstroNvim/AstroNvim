--- ### AstroNvim Status Utilities
--
-- Statusline related uitility functions
--
-- This module can be loaded with `local status_utils = require "astronvim.utils.status.utils"`
--
-- @module astronvim.utils.status.utils
-- @copyright 2023
-- @license GNU General Public License v3.0

local M = {}

local env = require "astronvim.utils.status.env"

local utils = require "astronvim.utils"
local extend_tbl = utils.extend_tbl
local get_icon = utils.get_icon

--- Convert a component parameter table to a table that can be used with the component builder
---@param opts? table a table of provider options
---@param provider? function|string a provider in `M.providers`
---@return table|false # the provider table that can be used in `M.component.builder`
function M.build_provider(opts, provider, _)
  return opts
      and {
        provider = provider,
        opts = opts,
        condition = opts.condition,
        on_click = opts.on_click,
        update = opts.update,
        hl = opts.hl,
      }
    or false
end

--- Convert key/value table of options to an array of providers for the component builder
---@param opts table the table of options for the components
---@param providers string[] an ordered list like array of providers that are configured in the options table
---@param setup? function a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `M.build_provider`
---@return table # the fully setup options table with the appropriately ordered providers
function M.setup_providers(opts, providers, setup)
  setup = setup or M.build_provider
  for i, provider in ipairs(providers) do
    opts[i] = setup(opts[provider], provider, i)
  end
  return opts
end

--- A utility function to get the width of the bar
---@param is_winbar? boolean true if you want the width of the winbar, false if you want the statusline width
---@return integer # the width of the specified bar
function M.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

--- Add left and/or right padding to a string
---@param str string the string to add padding to
---@param padding table a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
---@return string # the padded string
function M.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0) or ""
end

local function escape(str) return str:gsub("%%", "%%%%") end

--- A utility function to stylize a string with an icon from lspkind, separators, and left/right padding
---@param str? string the string to stylize
---@param opts? table options of `{ padding = { left = 0, right = 0 }, separator = { left = "|", right = "|" }, escape = true, show_empty = false, icon = { kind = "NONE", padding = { left = 0, right = 0 } } }`
---@return string # the stylized string
-- @usage local string = require("astronvim.utils.status").utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })
function M.stylize(str, opts)
  opts = extend_tbl({
    padding = { left = 0, right = 0 },
    separator = { left = "", right = "" },
    show_empty = false,
    escape = true,
    icon = { kind = "NONE", padding = { left = 0, right = 0 } },
  }, opts)
  local icon = M.pad_string(get_icon(opts.icon.kind), opts.icon.padding)
  return str
      and (str ~= "" or opts.show_empty)
      and opts.separator.left .. M.pad_string(icon .. (opts.escape and escape(str) or str), opts.padding) .. opts.separator.right
    or ""
end

--- Surround component with separator and color adjustment
---@param separator string|string[] the separator index to use in `env.separators`
---@param color function|string|table the color to use as the separator foreground/component background
---@param component table the component to surround
---@param condition boolean|function the condition for displaying the surrounded component
---@return table # the new surrounded component
function M.surround(separator, color, component, condition)
  local function surround_color(self)
    local colors = type(color) == "function" and color(self) or color
    return type(colors) == "string" and { main = colors } or colors
  end

  separator = type(separator) == "string" and env.separators[separator] or separator
  local surrounded = { condition = condition }
  if separator[1] ~= "" then
    table.insert(surrounded, {
      provider = separator[1],
      hl = function(self)
        local s_color = surround_color(self)
        if s_color then return { fg = s_color.main, bg = s_color.left } end
      end,
    })
  end
  table.insert(surrounded, {
    hl = function(self)
      local s_color = surround_color(self)
      if s_color then return { bg = s_color.main } end
    end,
    extend_tbl(component, {}),
  })
  if separator[2] ~= "" then
    table.insert(surrounded, {
      provider = separator[2],
      hl = function(self)
        local s_color = surround_color(self)
        if s_color then return { fg = s_color.main, bg = s_color.right } end
      end,
    })
  end
  return surrounded
end

--- Encode a position to a single value that can be decoded later
---@param line integer line number of position
---@param col integer column number of position
---@param winnr integer a window number
---@return integer the encoded position
function M.encode_pos(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end

--- Decode a previously encoded position to it's sub parts
---@param c integer the encoded position
---@return integer line, integer column, integer window
function M.decode_pos(c) return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63) end

--- Get a list of registered null-ls providers for a given filetype
---@param filetype string the filetype to search null-ls for
---@return table # a table of null-ls sources
function M.null_ls_providers(filetype)
  local registered = {}
  -- try to load null-ls
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    -- get the available sources of a given filetype
    for _, source in ipairs(sources.get_available(filetype)) do
      -- get each source name
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        table.insert(registered[method], source.name)
      end
    end
  end
  -- return the found null-ls sources
  return registered
end

--- Get the null-ls sources for a given null-ls method
---@param filetype string the filetype to search null-ls for
---@param method string the null-ls method (check null-ls documentation for available methods)
---@return string[] # the available sources for the given filetype and method
function M.null_ls_sources(filetype, method)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and M.null_ls_providers(filetype)[methods.internal[method]] or {}
end

--- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
---@param self any the self parameter from Heirline component on_click.callback function call
---@param minwid any the minwid parameter from Heirline component on_click.callback function call
---@param clicks any the clicks parameter from Heirline component on_click.callback function call
---@param button any the button parameter from Heirline component on_click.callback function call
---@param mods any the button parameter from Heirline component on_click.callback function call
---@return table # the argument table with the decoded mouse information and signcolumn signs information
-- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astronvim.utils.status").utils.statuscolumn_clickargs(...) end } }
function M.statuscolumn_clickargs(self, minwid, clicks, button, mods)
  local args = {
    minwid = minwid,
    clicks = clicks,
    button = button,
    mods = mods,
    mousepos = vim.fn.getmousepos(),
  }
  if not self.signs then self.signs = {} end
  args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
  if args.char == " " then args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1) end
  args.sign = self.signs[args.char]
  if not args.sign then -- update signs if not found on first click
    for _, sign_def in ipairs(vim.fn.sign_getdefined()) do
      if sign_def.text then self.signs[sign_def.text:gsub("%s", "")] = sign_def end
    end
    args.sign = self.signs[args.char]
  end
  vim.api.nvim_set_current_win(args.mousepos.winid)
  vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
  return args
end

return M
