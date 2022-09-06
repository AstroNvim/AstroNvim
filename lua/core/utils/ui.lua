--- ### AstroNvim UI Options
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.ui`
--
-- This module can also be manually loaded with `local updater = require("core.utils").ui`
--
-- @module core.utils.ui
-- @see core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

astronvim.ui = {}

local bool2str = function(bool) return bool and "on" or "off" end

--- Toggle autopairs
function astronvim.ui.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    vim.notify "autopairs not available"
  end
end

--- Toggle diagnostics
function astronvim.ui.toggle_diagnostics()
  vim.g.diagnostics_enabled = not vim.g.diagnostics_enabled
  vim.diagnostic.config(vim.g.diagnostics_enabled and astronvim.lsp.default_diagnostics or {
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  })
  vim.notify(string.format("diagnostics %s", bool2str(vim.g.diagnostics_enabled)))
end

--- Toggle background="dark"|"light"
function astronvim.ui.toggle_background()
  vim.go.background = vim.go.background == "light" and "dark" or "light"
  vim.notify(string.format("background=%s", vim.go.background))
end

--- Toggle cmp entrirely
function astronvim.ui.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.setup { enabled = vim.g.cmp_enabled }
    vim.notify(string.format("completion %s", bool2str(vim.g.cmp_enabled)))
  else
    vim.notify "completion not available"
  end
end

--- Toggle signcolumn="auto"|"no"
function astronvim.ui.toggle_signcolumn()
  if vim.wo.signcolumn == "no" then
    vim.wo.signcolumn = "yes"
  elseif vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  vim.notify(string.format("signcolumn=%s", vim.wo.signcolumn))
end

--- Set the indent and tab related numbers
function astronvim.ui.set_indent()
  local indent = tonumber(vim.fn.input "Set indent value (>0 expandtab, <=0 noexpandtab, 0 vim defaults): ") or -8
  vim.bo.expandtab = (indent > 0) -- local to buffer
  indent = math.abs(indent)
  vim.bo.tabstop = indent -- local to buffer
  vim.bo.softtabstop = indent -- local to buffer
  vim.bo.shiftwidth = indent -- local to buffer
  vim.notify(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
end

--- Change the number display modes
function astronvim.ui.change_number()
  local number = vim.wo.number -- local to window
  local relativenumber = vim.wo.relativenumber -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
  elseif number and not relativenumber then
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false
  else -- not number and relativenumber
    vim.wo.relativenumber = false
  end
  vim.notify(string.format("number=%s, relativenumber=%s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

--- Toggle spell
function astronvim.ui.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  vim.notify(string.format("spell=%s", bool2str(vim.wo.spell)))
end

--- Toggle wrap
function astronvim.ui.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  vim.notify(string.format("wrap=%s", bool2str(vim.wo.wrap)))
end

--- Toggle syntax highlighting and treesitter
function astronvim.ui.toggle_syntax()
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.g.syntax_on then -- global var for on//off
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufDisable "highlight" end
    vim.cmd.syntax "off" -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufEnable "highlight" end
    vim.cmd.syntax "on" -- set vim.g.syntax_on = true
  end
  vim.notify(string.format("syntax %s", bool2str(vim.g.syntax_on)))
end

--- Toggle URL/URI syntax highlighting rules
function astronvim.ui.toggle_url_match()
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  astronvim.set_url_match()
end
