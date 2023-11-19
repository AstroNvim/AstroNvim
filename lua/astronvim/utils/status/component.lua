--- ### AstroNvim Status Components
--
-- Statusline related component functions to use with Heirline
--
-- This module can be loaded with `local component = require "astronvim.utils.status.component"`
--
-- @module astronvim.utils.status.component
-- @copyright 2023
-- @license GNU General Public License v3.0

local M = {}

local condition = require "astronvim.utils.status.condition"
local env = require "astronvim.utils.status.env"
local hl = require "astronvim.utils.status.hl"
local init = require "astronvim.utils.status.init"
local provider = require "astronvim.utils.status.provider"
local status_utils = require "astronvim.utils.status.utils"

local utils = require "astronvim.utils"
local buffer_utils = require "astronvim.utils.buffer"
local extend_tbl = utils.extend_tbl
local get_icon = utils.get_icon
local is_available = utils.is_available

--- A Heirline component for filling in the empty space of the bar
---@param opts? table options for configuring the other fields of the heirline component
---@return table # The heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.fill()
function M.fill(opts) return extend_tbl({ provider = provider.fill() }, opts) end

--- A function to build a set of children components for an entire file information section
---@param opts? table options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.file_info()
function M.file_info(opts)
  opts = extend_tbl({
    file_icon = { hl = hl.file_icon "statusline", padding = { left = 1, right = 1 } },
    filename = {},
    file_modified = { padding = { left = 1 } },
    file_read_only = { padding = { left = 1 } },
    surround = { separator = "left", color = "file_info_bg", condition = condition.has_filetype },
    hl = hl.get_attributes "file_info",
  }, opts)
  return M.builder(status_utils.setup_providers(opts, {
    "file_icon",
    "unique_path",
    "filename",
    "filetype",
    "file_modified",
    "file_read_only",
    "close_button",
  }))
end

--- A function with different file_info defaults specifically for use in the tabline
---@param opts? table options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.tabline_file_info()
function M.tabline_file_info(opts)
  return M.file_info(extend_tbl({
    file_icon = {
      condition = function(self) return not self._show_picker end,
      hl = hl.file_icon "tabline",
    },
    unique_path = {
      hl = function(self) return hl.get_attributes(self.tab_type .. "_path") end,
    },
    close_button = {
      hl = function(self) return hl.get_attributes(self.tab_type .. "_close") end,
      padding = { left = 1, right = 1 },
      on_click = {
        callback = function(_, minwid) buffer_utils.close(minwid) end,
        minwid = function(self) return self.bufnr end,
        name = "heirline_tabline_close_buffer_callback",
      },
    },
    padding = { left = 1, right = 1 },
    hl = function(self)
      local tab_type = self.tab_type
      if self._show_picker and self.tab_type ~= "buffer_active" then tab_type = "buffer_visible" end
      return hl.get_attributes(tab_type)
    end,
    surround = false,
  }, opts))
end

--- A function to build a set of children components for an entire navigation section
---@param opts? table options for configuring ruler, percentage, scrollbar, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.nav()
function M.nav(opts)
  opts = extend_tbl({
    ruler = {},
    percentage = { padding = { left = 1 } },
    scrollbar = { padding = { left = 1 }, hl = { fg = "scrollbar" } },
    surround = { separator = "right", color = "nav_bg" },
    hl = hl.get_attributes "nav",
    update = { "CursorMoved", "CursorMovedI", "BufEnter" },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "ruler", "percentage", "scrollbar" }))
end

--- A function to build a set of children components for information shown in the cmdline
---@param opts? table options for configuring macro recording, search count, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.cmd_info()
function M.cmd_info(opts)
  opts = extend_tbl({
    macro_recording = {
      icon = { kind = "MacroRecording", padding = { right = 1 } },
      condition = condition.is_macro_recording,
      update = {
        "RecordingEnter",
        "RecordingLeave",
        -- TODO: remove when dropping support for Neovim v0.8
        callback = vim.fn.has "nvim-0.9" == 0 and vim.schedule_wrap(function() vim.cmd.redrawstatus() end) or nil,
      },
    },
    search_count = {
      icon = { kind = "Search", padding = { right = 1 } },
      padding = { left = 1 },
      condition = condition.is_hlsearch,
    },
    showcmd = {
      padding = { left = 1 },
      condition = condition.is_statusline_showcmd,
    },
    surround = {
      separator = "center",
      color = "cmd_info_bg",
      condition = function()
        return condition.is_hlsearch() or condition.is_macro_recording() or condition.is_statusline_showcmd()
      end,
    },
    condition = function() return vim.opt.cmdheight:get() == 0 end,
    hl = hl.get_attributes "cmd_info",
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "macro_recording", "search_count", "showcmd" }))
end

--- A function to build a set of children components for a mode section
---@param opts? table options for configuring mode_text, paste, spell, and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.mode { mode_text = true }
function M.mode(opts)
  opts = extend_tbl({
    mode_text = false,
    paste = false,
    spell = false,
    surround = { separator = "left", color = hl.mode_bg },
    hl = hl.get_attributes "mode",
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  }, opts)
  if not opts["mode_text"] then opts.str = { str = " " } end
  return M.builder(status_utils.setup_providers(opts, { "mode_text", "str", "paste", "spell" }))
end

--- A function to build a set of children components for an LSP breadcrumbs section
---@param opts? table options for configuring breadcrumbs and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.breadcumbs()
function M.breadcrumbs(opts)
  opts = extend_tbl({ padding = { left = 1 }, condition = condition.aerial_available, update = "CursorMoved" }, opts)
  opts.init = init.breadcrumbs(opts)
  return opts
end

--- A function to build a set of children components for the current file path
---@param opts? table options for configuring path and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.separated_path()
function M.separated_path(opts)
  opts = extend_tbl({ padding = { left = 1 }, update = { "BufEnter", "DirChanged" } }, opts)
  opts.init = init.separated_path(opts)
  return opts
end

--- A function to build a set of children components for a git branch section
---@param opts? table options for configuring git branch and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.git_branch()
function M.git_branch(opts)
  opts = extend_tbl({
    git_branch = { icon = { kind = "GitBranch", padding = { right = 1 } } },
    surround = { separator = "left", color = "git_branch_bg", condition = condition.is_git_repo },
    hl = hl.get_attributes "git_branch",
    on_click = {
      name = "heirline_branch",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_branches { use_file_path = true } end, 100)
        end
      end,
    },
    update = { "User", pattern = "GitSignsUpdate" },
    init = init.update_events { "BufEnter" },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "git_branch" }))
end

--- A function to build a set of children components for a git difference section
---@param opts? table options for configuring git changes and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.git_diff()
function M.git_diff(opts)
  opts = extend_tbl({
    added = { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
    changed = { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
    removed = { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
    hl = hl.get_attributes "git_diff",
    on_click = {
      name = "heirline_git",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_status { use_file_path = true } end, 100)
        end
      end,
    },
    surround = { separator = "left", color = "git_diff_bg", condition = condition.git_changed },
    update = { "User", pattern = "GitSignsUpdate" },
    init = init.update_events { "BufEnter" },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "added", "changed", "removed" }, function(p_opts, p)
    local out = status_utils.build_provider(p_opts, p)
    if out then
      out.provider = "git_diff"
      out.opts.type = p
      if out.hl == nil then out.hl = { fg = "git_" .. p } end
    end
    return out
  end))
end

--- A function to build a set of children components for a diagnostics section
---@param opts? table options for configuring diagnostic providers and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.diagnostics()
function M.diagnostics(opts)
  opts = extend_tbl({
    ERROR = { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
    WARN = { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
    INFO = { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
    HINT = { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
    surround = { separator = "left", color = "diagnostics_bg", condition = condition.has_diagnostics },
    hl = hl.get_attributes "diagnostics",
    on_click = {
      name = "heirline_diagnostic",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").diagnostics() end, 100)
        end
      end,
    },
    update = { "DiagnosticChanged", "BufEnter" },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "ERROR", "WARN", "INFO", "HINT" }, function(p_opts, p)
    local out = status_utils.build_provider(p_opts, p)
    if out then
      out.provider = "diagnostics"
      out.opts.severity = p
      if out.hl == nil then out.hl = { fg = "diag_" .. p } end
    end
    return out
  end))
end

--- A function to build a set of children components for a Treesitter section
---@param opts? table options for configuring diagnostic providers and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.treesitter()
function M.treesitter(opts)
  opts = extend_tbl({
    str = { str = "TS", icon = { kind = "ActiveTS", padding = { right = 1 } } },
    surround = {
      separator = "right",
      color = "treesitter_bg",
      condition = condition.treesitter_available,
    },
    hl = hl.get_attributes "treesitter",
    update = { "OptionSet", pattern = "syntax" },
    init = init.update_events { "BufEnter" },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "str" }))
end

--- A function to build a set of children components for an LSP section
---@param opts? table options for configuring lsp progress and client_name providers and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.lsp()
function M.lsp(opts)
  opts = extend_tbl({
    lsp_progress = {
      str = "",
      padding = { right = 1 },
      update = {
        "User",
        pattern = "AstroLspProgress",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
      },
    },
    lsp_client_names = {
      str = "LSP",
      update = {
        "LspAttach",
        "LspDetach",
        "BufEnter",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
      },
      icon = { kind = "ActiveLSP", padding = { right = 2 } },
    },
    hl = hl.get_attributes "lsp",
    surround = { separator = "right", color = "lsp_bg", condition = condition.lsp_attached },
    on_click = {
      name = "heirline_lsp",
      callback = function()
        vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
      end,
    },
  }, opts)
  return M.builder(status_utils.setup_providers(
    opts,
    { "lsp_progress", "lsp_client_names" },
    function(p_opts, p, i)
      return p_opts
          and {
            flexible = i,
            status_utils.build_provider(p_opts, provider[p](p_opts)),
            status_utils.build_provider(p_opts, provider.str(p_opts)),
          }
        or false
    end
  ))
end

--- A function to build a set of components for a foldcolumn section in a statuscolumn
---@param opts? table options for configuring foldcolumn and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.foldcolumn()
function M.foldcolumn(opts)
  opts = extend_tbl({
    foldcolumn = { padding = { right = 1 } },
    condition = condition.foldcolumn_enabled,
    on_click = {
      name = "fold_click",
      callback = function(...)
        local char = status_utils.statuscolumn_clickargs(...).char
        local fillchars = vim.opt_local.fillchars:get()
        if char == (fillchars.foldopen or get_icon "FoldOpened") then
          vim.cmd "norm! zc"
        elseif char == (fillchars.foldclose or get_icon "FoldClosed") then
          vim.cmd "norm! zo"
        end
      end,
    },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "foldcolumn" }))
end

--- A function to build a set of components for a numbercolumn section in statuscolumn
---@param opts? table options for configuring numbercolumn and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.numbercolumn()
function M.numbercolumn(opts)
  opts = extend_tbl({
    numbercolumn = { padding = { right = 1 } },
    condition = condition.numbercolumn_enabled,
    on_click = {
      name = "line_click",
      callback = function(...)
        local args = status_utils.statuscolumn_clickargs(...)
        if args.mods:find "c" then
          local dap_avail, dap = pcall(require, "dap")
          if dap_avail then vim.schedule(dap.toggle_breakpoint) end
        end
      end,
    },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "numbercolumn" }))
end

--- A function to build a set of components for a signcolumn section in statuscolumn
---@param opts? table options for configuring signcolumn and the overall padding
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.signcolumn()
function M.signcolumn(opts)
  opts = extend_tbl({
    signcolumn = {},
    condition = condition.signcolumn_enabled,
    on_click = {
      name = "sign_click",
      callback = function(...)
        local args = status_utils.statuscolumn_clickargs(...)
        if args.sign and args.sign.name and env.sign_handlers[args.sign.name] then
          env.sign_handlers[args.sign.name](args)
        end
      end,
    },
  }, opts)
  return M.builder(status_utils.setup_providers(opts, { "signcolumn" }))
end

--- A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding
---@param opts? table a list of components to build into a section
---@return table # The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })
function M.builder(opts)
  opts = extend_tbl({ padding = { left = 0, right = 0 } }, opts)
  local children = {}
  if opts.padding.left > 0 then -- add left padding
    table.insert(children, { provider = status_utils.pad_string(" ", { left = opts.padding.left - 1 }) })
  end
  for key, entry in pairs(opts) do
    if
      type(key) == "number"
      and type(entry) == "table"
      and provider[entry.provider]
      and (entry.opts == nil or type(entry.opts) == "table")
    then
      entry.provider = provider[entry.provider](entry.opts)
    end
    children[key] = entry
  end
  if opts.padding.right > 0 then -- add right padding
    table.insert(children, { provider = status_utils.pad_string(" ", { right = opts.padding.right - 1 }) })
  end
  return opts.surround
      and status_utils.surround(opts.surround.separator, opts.surround.color, children, opts.surround.condition)
    or children
end

return M
