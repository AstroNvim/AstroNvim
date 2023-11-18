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
local function ui_notify(silent, ...) return not silent and require("astronvim.utils").notify(...) end

--- Toggle notifications for UI toggles
---@param silent? boolean if true then don't sent a notification
function M.toggle_ui_notifications(silent) -- TODO: rename to toggle_notifications in AstroNvim v4
  vim.g.ui_notifications_enabled = not vim.g.ui_notifications_enabled
  ui_notify(silent, string.format("Notifications %s", bool2str(vim.g.ui_notifications_enabled)))
end

--- Toggle autopairs
---@param silent? boolean if true then don't sent a notification
function M.toggle_autopairs(silent)
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.g.autopairs_enabled = autopairs.state.disabled
    ui_notify(silent, string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    ui_notify(silent, "autopairs not available")
  end
end

--- Toggle diagnostics
---@param silent? boolean if true then don't sent a notification
function M.toggle_diagnostics(silent)
  vim.g.diagnostics_mode = (vim.g.diagnostics_mode - 1) % 4
  vim.diagnostic.config(require("astronvim.utils.lsp").diagnostics[vim.g.diagnostics_mode])
  if vim.g.diagnostics_mode == 0 then
    ui_notify(silent, "diagnostics off")
  elseif vim.g.diagnostics_mode == 1 then
    ui_notify(silent, "only status diagnostics")
  elseif vim.g.diagnostics_mode == 2 then
    ui_notify(silent, "virtual text off")
  else
    ui_notify(silent, "all diagnostics on")
  end
end

--- Toggle background="dark"|"light"
---@param silent? boolean if true then don't sent a notification
function M.toggle_background(silent)
  vim.go.background = vim.go.background == "light" and "dark" or "light"
  ui_notify(silent, string.format("background=%s", vim.go.background))
end

--- Toggle cmp entrirely
---@param silent? boolean if true then don't sent a notification
function M.toggle_cmp(silent)
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, _ = pcall(require, "cmp")
  ui_notify(silent, ok and string.format("completion %s", bool2str(vim.g.cmp_enabled)) or "completion not available")
end

--- Toggle auto format
---@param silent? boolean if true then don't sent a notification
function M.toggle_autoformat(silent)
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  ui_notify(silent, string.format("Global autoformatting %s", bool2str(vim.g.autoformat_enabled)))
end

--- Toggle buffer local auto format
---@param bufnr? number the buffer to toggle syntax on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_autoformat(bufnr, silent)
  bufnr = bufnr or 0
  local old_val = vim.b[bufnr].autoformat_enabled
  if old_val == nil then old_val = vim.g.autoformat_enabled end
  vim.b[bufnr].autoformat_enabled = not old_val
  ui_notify(silent, string.format("Buffer autoformatting %s", bool2str(vim.b[bufnr].autoformat_enabled)))
end

--- Toggle buffer semantic token highlighting for all language servers that support it
---@param bufnr? number the buffer to toggle the clients on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_semantic_tokens(bufnr, silent)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  local toggled = false
  for _, client in ipairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
      toggled = true
    end
  end
  ui_notify(
    not toggled or silent,
    string.format("Buffer lsp semantic highlighting %s", bool2str(vim.b[bufnr].semantic_tokens_enabled))
  )
end

--- Toggle buffer LSP inlay hints
---@param bufnr? number the buffer to toggle the clients on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_inlay_hints(bufnr, silent)
  bufnr = bufnr or 0
  vim.b[bufnr].inlay_hints_enabled = not vim.b[bufnr].inlay_hints_enabled
  -- TODO: remove check after dropping support for Neovim v0.9
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(bufnr, vim.b[bufnr].inlay_hints_enabled)
    ui_notify(silent, string.format("Inlay hints %s", bool2str(vim.b[bufnr].inlay_hints_enabled)))
  end
end

--- Toggle codelens
---@param silent? boolean if true then don't sent a notification
function M.toggle_codelens(silent)
  vim.g.codelens_enabled = not vim.g.codelens_enabled
  if not vim.g.codelens_enabled then vim.lsp.codelens.clear() end
  ui_notify(silent, string.format("CodeLens %s", bool2str(vim.g.codelens_enabled)))
end

--- Toggle showtabline=2|0
---@param silent? boolean if true then don't sent a notification
function M.toggle_tabline(silent)
  vim.opt.showtabline = vim.opt.showtabline:get() == 0 and 2 or 0
  ui_notify(silent, string.format("tabline %s", bool2str(vim.opt.showtabline:get() == 2)))
end

--- Toggle conceal=2|0
---@param silent? boolean if true then don't sent a notification
function M.toggle_conceal(silent)
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  ui_notify(silent, string.format("conceal %s", bool2str(vim.opt.conceallevel:get() == 2)))
end

--- Toggle laststatus=3|2|0
---@param silent? boolean if true then don't sent a notification
function M.toggle_statusline(silent)
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
  ui_notify(silent, string.format("statusline %s", status))
end

--- Toggle signcolumn="auto"|"no"
---@param silent? boolean if true then don't sent a notification
function M.toggle_signcolumn(silent)
  if vim.wo.signcolumn == "no" then
    vim.wo.signcolumn = "yes"
  elseif vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  ui_notify(silent, string.format("signcolumn=%s", vim.wo.signcolumn))
end

--- Set the indent and tab related numbers
---@param silent? boolean if true then don't sent a notification
function M.set_indent(silent)
  local input_avail, input = pcall(vim.fn.input, "Set indent value (>0 expandtab, <=0 noexpandtab): ")
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then return end
    vim.bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    vim.bo.tabstop = indent -- local to buffer
    vim.bo.softtabstop = indent -- local to buffer
    vim.bo.shiftwidth = indent -- local to buffer
    ui_notify(silent, string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
  end
end

--- Change the number display modes
---@param silent? boolean if true then don't sent a notification
function M.change_number(silent)
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
  ui_notify(
    silent,
    string.format("number %s, relativenumber %s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber))
  )
end

--- Toggle spell
---@param silent? boolean if true then don't sent a notification
function M.toggle_spell(silent)
  vim.wo.spell = not vim.wo.spell -- local to window
  ui_notify(silent, string.format("spell %s", bool2str(vim.wo.spell)))
end

--- Toggle paste
---@param silent? boolean if true then don't sent a notification
function M.toggle_paste(silent)
  vim.opt.paste = not vim.opt.paste:get() -- local to window
  ui_notify(silent, string.format("paste %s", bool2str(vim.opt.paste:get())))
end

--- Toggle wrap
---@param silent? boolean if true then don't sent a notification
function M.toggle_wrap(silent)
  vim.wo.wrap = not vim.wo.wrap -- local to window
  ui_notify(silent, string.format("wrap %s", bool2str(vim.wo.wrap)))
end

--- Toggle syntax highlighting and treesitter
---@param bufnr? number the buffer to toggle syntax on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_syntax(bufnr, silent)
  -- HACK: this should just be `bufnr = bufnr or 0` but it looks like `vim.treesitter.stop` has a bug with `0` being current
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_win_get_buf(0)
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.bo[bufnr].syntax == "off" then
    if ts_avail and parsers.has_parser() then vim.treesitter.start(bufnr) end
    vim.bo[bufnr].syntax = "on"
    if not vim.b[bufnr].semantic_tokens_enabled then M.toggle_buffer_semantic_tokens(bufnr, true) end
  else
    if ts_avail and parsers.has_parser() then vim.treesitter.stop(bufnr) end
    vim.bo[bufnr].syntax = "off"
    if vim.b[bufnr].semantic_tokens_enabled then M.toggle_buffer_semantic_tokens(bufnr, true) end
  end
  ui_notify(silent, string.format("syntax %s", vim.bo[bufnr].syntax))
end
-- TODO: remove old function name in AstroNvim v4
M.toggle_syntax = M.toggle_buffer_syntax

--- Toggle URL/URI syntax highlighting rules
---@param silent? boolean if true then don't sent a notification
function M.toggle_url_match(silent)
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  require("astronvim.utils").set_url_match()
  ui_notify(silent, string.format("URL highlighting %s", bool2str(vim.g.highlighturl_enabled)))
end

local last_active_foldcolumn
--- Toggle foldcolumn=0|1
---@param silent? boolean if true then don't sent a notification
function M.toggle_foldcolumn(silent)
  local curr_foldcolumn = vim.wo.foldcolumn
  if curr_foldcolumn ~= "0" then last_active_foldcolumn = curr_foldcolumn end
  vim.wo.foldcolumn = curr_foldcolumn == "0" and (last_active_foldcolumn or "1") or "0"
  ui_notify(silent, string.format("foldcolumn=%s", vim.wo.foldcolumn))
end

return M
