--- ### AstroNvim UI Options
--
--  Utility functions for easy UI toggles.
--
-- This module can be loaded with `local ui = require("astronvim.utils.ui")`
--
-- @module astronvim.utils.ui
-- @see astronvim.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

local M = {}

local function bool2str(bool) return bool and "on" or "off" end

local function ui_notify(str)
  if vim.g.ui_notifications_enabled then require("astronvim.utils").notify(str) end
end

--- Toggle notifications for UI toggles
function M.toggle_ui_notifications()
  vim.g.ui_notifications_enabled = not vim.g.ui_notifications_enabled
  ui_notify(string.format("ui notifications %s", bool2str(vim.g.ui_notifications_enabled)))
end

--- Toggle autopairs
function M.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.g.autopairs_enabled = autopairs.state.disabled
    ui_notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    ui_notify "autopairs not available"
  end
end

--- Toggle diagnostics
function M.toggle_diagnostics()
  vim.g.diagnostics_mode = (vim.g.diagnostics_mode - 1) % 4
  vim.diagnostic.config(require("astronvim.utils.lsp").diagnostics[vim.g.diagnostics_mode])
  if vim.g.diagnostics_mode == 0 then
    ui_notify "diagnostics off"
  elseif vim.g.diagnostics_mode == 1 then
    ui_notify "only status diagnostics"
  elseif vim.g.diagnostics_mode == 2 then
    ui_notify "virtual text off"
  else
    ui_notify "all diagnostics on"
  end
end

--- Toggle background="dark"|"light"
function M.toggle_background()
  vim.go.background = vim.go.background == "light" and "dark" or "light"
  ui_notify(string.format("background=%s", vim.go.background))
end

--- Toggle cmp entrirely
function M.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, _ = pcall(require, "cmp")
  ui_notify(ok and string.format("completion %s", bool2str(vim.g.cmp_enabled)) or "completion not available")
end

--- Toggle auto format
function M.toggle_autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  ui_notify(string.format("Global autoformatting %s", bool2str(vim.g.autoformat_enabled)))
end

--- Toggle buffer local auto format
function M.toggle_buffer_autoformat()
  local old_val = vim.b.autoformat_enabled
  if old_val == nil then old_val = vim.g.autoformat_enabled end
  vim.b.autoformat_enabled = not old_val
  ui_notify(string.format("Buffer autoformatting %s", bool2str(vim.b.autoformat_enabled)))
end

--- Toggle buffer semantic token highlighting for all language servers that support it
---@param bufnr? number the buffer to toggle the clients on
function M.toggle_buffer_semantic_tokens(bufnr)
  vim.b.semantic_tokens_enabled = vim.b.semantic_tokens_enabled == false

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b.semantic_tokens_enabled and "start" or "stop"](bufnr or 0, client.id)
      ui_notify(string.format("Buffer lsp semantic highlighting %s", bool2str(vim.b.semantic_tokens_enabled)))
    end
  end
end

--- Toggle codelens
function M.toggle_codelens()
  vim.g.codelens_enabled = not vim.g.codelens_enabled
  if not vim.g.codelens_enabled then vim.lsp.codelens.clear() end
  ui_notify(string.format("CodeLens %s", bool2str(vim.g.codelens_enabled)))
end

--- Toggle showtabline=2|0
function M.toggle_tabline()
  vim.opt.showtabline = vim.opt.showtabline:get() == 0 and 2 or 0
  ui_notify(string.format("tabline %s", bool2str(vim.opt.showtabline:get() == 2)))
end

--- Toggle conceal=2|0
function M.toggle_conceal()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  ui_notify(string.format("conceal %s", bool2str(vim.opt.conceallevel:get() == 2)))
end

--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = "local"
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = "global"
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = "off"
  end
  ui_notify(string.format("statusline %s", status))
end

--- Toggle signcolumn="auto"|"no"
function M.toggle_signcolumn()
  if vim.wo.signcolumn == "no" then
    vim.wo.signcolumn = "yes"
  elseif vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  ui_notify(string.format("signcolumn=%s", vim.wo.signcolumn))
end

--- Set the indent and tab related numbers
function M.set_indent()
  local input_avail, input = pcall(vim.fn.input, "Set indent value (>0 expandtab, <=0 noexpandtab): ")
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then return end
    vim.bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    vim.bo.tabstop = indent -- local to buffer
    vim.bo.softtabstop = indent -- local to buffer
    vim.bo.shiftwidth = indent -- local to buffer
    ui_notify(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
  end
end

--- Change the number display modes
function M.change_number()
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
  ui_notify(string.format("number %s, relativenumber %s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

--- Toggle spell
function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  ui_notify(string.format("spell %s", bool2str(vim.wo.spell)))
end

--- Toggle paste
function M.toggle_paste()
  vim.opt.paste = not vim.opt.paste:get() -- local to window
  ui_notify(string.format("paste %s", bool2str(vim.opt.paste:get())))
end

--- Toggle wrap
function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  ui_notify(string.format("wrap %s", bool2str(vim.wo.wrap)))
end

--- Toggle syntax highlighting and treesitter
function M.toggle_syntax()
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.g.syntax_on then -- global var for on//off
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufDisable "highlight" end
    vim.cmd.syntax "off" -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufEnable "highlight" end
    vim.cmd.syntax "on" -- set vim.g.syntax_on = true
  end
  ui_notify(string.format("syntax %s", bool2str(vim.g.syntax_on)))
end

--- Toggle URL/URI syntax highlighting rules
function M.toggle_url_match()
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  require("astronvim.utils").set_url_match()
end

local last_active_foldcolumn
--- Toggle foldcolumn=0|1
function M.toggle_foldcolumn()
  local curr_foldcolumn = vim.wo.foldcolumn
  if curr_foldcolumn ~= "0" then last_active_foldcolumn = curr_foldcolumn end
  vim.wo.foldcolumn = curr_foldcolumn == "0" and (last_active_foldcolumn or "1") or "0"
  ui_notify(string.format("foldcolumn=%s", vim.wo.foldcolumn))
end

return M
