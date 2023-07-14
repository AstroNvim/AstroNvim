--- ### AstroNvim Status Environment
--
-- Statusline related environment variables shared between components/providers/etc.
--
-- This module can be loaded with `local env = require "astronvim.utils.status.env"`
--
-- @module astronvim.utils.status.env
-- @copyright 2023
-- @license GNU General Public License v3.0

local M = {}

M.fallback_colors = {
  none = "NONE",
  fg = "#abb2bf",
  bg = "#1e222a",
  dark_bg = "#2c323c",
  blue = "#61afef",
  green = "#98c379",
  grey = "#5c6370",
  bright_grey = "#777d86",
  dark_grey = "#5c5c5c",
  orange = "#ff9640",
  purple = "#c678dd",
  bright_purple = "#a9a1e1",
  red = "#e06c75",
  bright_red = "#ec5f67",
  white = "#c9c9c9",
  yellow = "#e5c07b",
  bright_yellow = "#ebae34",
}

M.modes = {
  ["n"] = { "NORMAL", "normal" },
  ["no"] = { "OP", "normal" },
  ["nov"] = { "OP", "normal" },
  ["noV"] = { "OP", "normal" },
  ["no"] = { "OP", "normal" },
  ["niI"] = { "NORMAL", "normal" },
  ["niR"] = { "NORMAL", "normal" },
  ["niV"] = { "NORMAL", "normal" },
  ["i"] = { "INSERT", "insert" },
  ["ic"] = { "INSERT", "insert" },
  ["ix"] = { "INSERT", "insert" },
  ["t"] = { "TERM", "terminal" },
  ["nt"] = { "TERM", "terminal" },
  ["v"] = { "VISUAL", "visual" },
  ["vs"] = { "VISUAL", "visual" },
  ["V"] = { "LINES", "visual" },
  ["Vs"] = { "LINES", "visual" },
  [""] = { "BLOCK", "visual" },
  ["s"] = { "BLOCK", "visual" },
  ["R"] = { "REPLACE", "replace" },
  ["Rc"] = { "REPLACE", "replace" },
  ["Rx"] = { "REPLACE", "replace" },
  ["Rv"] = { "V-REPLACE", "replace" },
  ["s"] = { "SELECT", "visual" },
  ["S"] = { "SELECT", "visual" },
  [""] = { "BLOCK", "visual" },
  ["c"] = { "COMMAND", "command" },
  ["cv"] = { "COMMAND", "command" },
  ["ce"] = { "COMMAND", "command" },
  ["r"] = { "PROMPT", "inactive" },
  ["rm"] = { "MORE", "inactive" },
  ["r?"] = { "CONFIRM", "inactive" },
  ["!"] = { "SHELL", "inactive" },
  ["null"] = { "null", "inactive" },
}

M.separators = astronvim.user_opts("heirline.separators", {
  none = { "", "" },
  left = { "", "  " },
  right = { "  ", "" },
  center = { "  ", "  " },
  tab = { "", " " },
  breadcrumbs = "  ",
  path = "  ",
})

M.attributes = astronvim.user_opts("heirline.attributes", {
  buffer_active = { bold = true, italic = true },
  buffer_picker = { bold = true },
  macro_recording = { bold = true },
  git_branch = { bold = true },
  git_diff = { bold = true },
})

M.icon_highlights = astronvim.user_opts("heirline.icon_highlights", {
  file_icon = {
    tabline = function(self) return self.is_active or self.is_visible end,
    statusline = true,
  },
})

local function pattern_match(str, pattern_list)
  for _, pattern in ipairs(pattern_list) do
    if str:find(pattern) then return true end
  end
  return false
end

M.buf_matchers = {
  filetype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list) end,
  buftype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list) end,
  bufname = function(pattern_list, bufnr)
    return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr or 0), ":t"), pattern_list)
  end,
}

M.sign_handlers = {}
-- gitsigns handlers
local gitsigns = function(_)
  local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
  if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
end
for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Changedelete", "Delete" } do
  local name = "GitSigns" .. sign
  if not M.sign_handlers[name] then M.sign_handlers[name] = gitsigns end
end
-- diagnostic handlers
local diagnostics = function(args)
  if args.mods:find "c" then
    vim.schedule(vim.lsp.buf.code_action)
  else
    vim.schedule(vim.diagnostic.open_float)
  end
end
for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
  local name = "DiagnosticSign" .. sign
  if not M.sign_handlers[name] then M.sign_handlers[name] = diagnostics end
end
-- DAP handlers
local dap_breakpoint = function(_)
  local dap_avail, dap = pcall(require, "dap")
  if dap_avail then vim.schedule(dap.toggle_breakpoint) end
end
for _, sign in ipairs { "", "Rejected", "Condition" } do
  local name = "DapBreakpoint" .. sign
  if not M.sign_handlers[name] then M.sign_handlers[name] = dap_breakpoint end
end
M.sign_handlers = astronvim.user_opts("heirline.sign_handlers", M.sign_handlers)

return M
