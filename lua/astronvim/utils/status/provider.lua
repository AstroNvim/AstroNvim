--- ### AstroNvim Status Providers
--
-- Statusline related provider functions for building statusline components
--
-- This module can be loaded with `local provider = require "astronvim.utils.status.provider"`
--
-- @module astronvim.utils.status.provider
-- @copyright 2023
-- @license GNU General Public License v3.0

local M = {}

local condition = require "astronvim.utils.status.condition"
local env = require "astronvim.utils.status.env"
local status_utils = require "astronvim.utils.status.utils"

local utils = require "astronvim.utils"
local extend_tbl = utils.extend_tbl
local get_icon = utils.get_icon
local luv = vim.uv or vim.loop -- TODO: REMOVE WHEN DROPPING SUPPORT FOR Neovim v0.9

--- A provider function for the fill string
---@return string # the statusline string for filling the empty space
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.fill }
function M.fill() return "%=" end

--- A provider function for the signcolumn string
---@param opts? table options passed to the stylize function
---@return string # the statuscolumn string for adding the signcolumn
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.signcolumn }
-- @see astronvim.utils.status.utils.stylize
function M.signcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  return status_utils.stylize("%s", opts)
end

--- A provider function for the numbercolumn string
---@param opts? table options passed to the stylize function
---@return function # the statuscolumn string for adding the numbercolumn
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.numbercolumn }
-- @see astronvim.utils.status.utils.stylize
function M.numbercolumn(opts)
  opts = extend_tbl({ thousands = false, culright = true, escape = false }, opts)
  return function()
    local lnum, rnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
    local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
    local str
    if not num and not relnum then
      str = ""
    elseif virtnum ~= 0 then
      str = "%="
    else
      local cur = relnum and (rnum > 0 and rnum or (num and lnum or 0)) or lnum
      if opts.thousands and cur > 999 then
        cur = string.reverse(cur):gsub("%d%d%d", "%1" .. opts.thousands):reverse():gsub("^%" .. opts.thousands, "")
      end
      str = (rnum == 0 and not opts.culright and relnum) and cur .. "%=" or "%=" .. cur
    end
    return status_utils.stylize(str, opts)
  end
end

--- A provider function for building a foldcolumn
---@param opts? table options passed to the stylize function
---@return function # a custom foldcolumn function for the statuscolumn that doesn't show the nest levels
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.foldcolumn }
-- @see astronvim.utils.status.utils.stylize
function M.foldcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  local ffi = require "astronvim.utils.ffi" -- get AstroNvim C extensions
  local fillchars = vim.opt.fillchars:get()
  local foldopen = fillchars.foldopen or get_icon "FoldOpened"
  local foldclosed = fillchars.foldclose or get_icon "FoldClosed"
  local foldsep = fillchars.foldsep or get_icon "FoldSeparator"
  return function() -- move to M.fold_indicator
    local wp = ffi.C.find_window_by_handle(0, ffi.new "Error") -- get window handler
    local width = ffi.C.compute_foldcolumn(wp, 0) -- get foldcolumn width
    -- get fold info of current line
    local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

    local str = ""
    if width ~= 0 then
      str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
      if foldinfo.level == 0 then
        str = str .. (" "):rep(width)
      else
        local closed = foldinfo.lines > 0
        local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
        if first_level < 1 then first_level = 1 end

        for col = 1, width do
          str = str
            .. (
              (vim.v.virtnum ~= 0 and foldsep)
              or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
              or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
              or foldsep
            )
          if col == foldinfo.level then
            str = str .. (" "):rep(width - col)
            break
          end
        end
      end
    end
    return status_utils.stylize(str .. "%*", opts)
  end
end

--- A provider function for the current tab numbre
---@return function # the statusline function to return a string for a tab number
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.tabnr() }
function M.tabnr()
  return function(self) return (self and self.tabnr) and "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" or "" end
end

--- A provider function for showing if spellcheck is on
---@param opts? table options passed to the stylize function
---@return function # the function for outputting if spell is enabled
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.spell() }
-- @see astronvim.utils.status.utils.stylize
function M.spell(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Spellcheck" }, show_empty = true }, opts)
  return function() return status_utils.stylize(vim.wo.spell and opts.str or nil, opts) end
end

--- A provider function for showing if paste is enabled
---@param opts? table options passed to the stylize function
---@return function # the function for outputting if paste is enabled
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.paste() }
-- @see astronvim.utils.status.utils.stylize
function M.paste(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Paste" }, show_empty = true }, opts)
  local paste = vim.opt.paste
  if type(paste) ~= "boolean" then paste = paste:get() end
  return function() return status_utils.stylize(paste and opts.str or nil, opts) end
end

--- A provider function for displaying if a macro is currently being recorded
---@param opts? table a prefix before the recording register and options passed to the stylize function
---@return function # a function that returns a string of the current recording status
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.macro_recording() }
-- @see astronvim.utils.status.utils.stylize
function M.macro_recording(opts)
  opts = extend_tbl({ prefix = "@" }, opts)
  return function()
    local register = vim.fn.reg_recording()
    if register ~= "" then register = opts.prefix .. register end
    return status_utils.stylize(register, opts)
  end
end

--- A provider function for displaying the current command
---@param opts? table of options passed to the stylize function
---@return string # the statusline string for showing the current command
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.showcmd() }
-- @see astronvim.utils.status.utils.stylize
function M.showcmd(opts)
  opts = extend_tbl({ minwid = 0, maxwid = 5, escape = false }, opts)
  return status_utils.stylize(("%%%d.%d(%%S%%)"):format(opts.minwid, opts.maxwid), opts)
end

--- A provider function for displaying the current search count
---@param opts? table options for `vim.fn.searchcount` and options passed to the stylize function
---@return function # a function that returns a string of the current search location
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.search_count() }
-- @see astronvim.utils.status.utils.stylize
function M.search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function() return vim.fn.searchcount() end
    or function() return vim.fn.searchcount(opts) end
  return function()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == "table" and search.total then
      return status_utils.stylize(
        string.format(
          "%s%d/%s%d",
          search.current > search.maxcount and ">" or "",
          math.min(search.current, search.maxcount),
          search.incomplete == 2 and ">" or "",
          math.min(search.total, search.maxcount)
        ),
        opts
      )
    end
  end
end

--- A provider function for showing the text of the current vim mode
---@param opts? table options for padding the text and options passed to the stylize function
---@return function # the function for displaying the text of the current vim mode
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.mode_text() }
-- @see astronvim.utils.status.utils.stylize
function M.mode_text(opts)
  local max_length = math.max(unpack(vim.tbl_map(function(str) return #str[1] end, vim.tbl_values(env.modes))))
  return function()
    local text = env.modes[vim.fn.mode()][1]
    if opts and opts.pad_text then
      local padding = max_length - #text
      if opts.pad_text == "right" then
        text = string.rep(" ", padding) .. text
      elseif opts.pad_text == "left" then
        text = text .. string.rep(" ", padding)
      elseif opts.pad_text == "center" then
        text = string.rep(" ", math.floor(padding / 2)) .. text .. string.rep(" ", math.ceil(padding / 2))
      end
    end
    return status_utils.stylize(text, opts)
  end
end

--- A provider function for showing the percentage of the current location in a document
---@param opts? table options for Top/Bot text, fixed width, and options passed to the stylize function
---@return function # the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.percentage() }
-- @see astronvim.utils.status.utils.stylize
function M.percentage(opts)
  opts = extend_tbl({ escape = false, fixed_width = true, edge_text = true }, opts)
  return function()
    local text = "%" .. (opts.fixed_width and (opts.edge_text and "2" or "3") or "") .. "p%%"
    if opts.edge_text then
      local current_line = vim.fn.line "."
      if current_line == 1 then
        text = "Top"
      elseif current_line == vim.fn.line "$" then
        text = "Bot"
      end
    end
    return status_utils.stylize(text, opts)
  end
end

--- A provider function for showing the current line and character in a document
---@param opts? table options for padding the line and character locations and options passed to the stylize function
---@return function # the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see astronvim.utils.status.utils.stylize
function M.ruler(opts)
  opts = extend_tbl({ pad_ruler = { line = 3, char = 2 } }, opts)
  local padding_str = string.format("%%%dd:%%-%dd", opts.pad_ruler.line, opts.pad_ruler.char)
  return function()
    local line = vim.fn.line "."
    local char = vim.fn.virtcol "."
    return status_utils.stylize(string.format(padding_str, line, char), opts)
  end
end

--- A provider function for showing the current location as a scrollbar
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the scrollbar
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.scrollbar() }
-- @see astronvim.utils.status.utils.stylize
function M.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    if sbar[i] then return status_utils.stylize(string.rep(sbar[i], 2), opts) end
  end
end

--- A provider to simply show a close button icon
---@param opts? table options passed to the stylize function and the kind of icon to use
---@return string # the stylized icon
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.close_button() }
-- @see astronvim.utils.status.utils.stylize
function M.close_button(opts)
  opts = extend_tbl({ kind = "BufferClose" }, opts)
  return status_utils.stylize(get_icon(opts.kind), opts)
end

--- A provider function for showing the current filetype
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the filetype
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.filetype() }
-- @see astronvim.utils.status.utils.stylize
function M.filetype(opts)
  return function(self)
    local buffer = vim.bo[self and self.bufnr or 0]
    return status_utils.stylize(string.lower(buffer.filetype), opts)
  end
end

--- A provider function for showing the current filename
---@param opts? table options for argument to fnamemodify to format filename and options passed to the stylize function
---@return function # the function for outputting the filename
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.filename() }
-- @see astronvim.utils.status.utils.stylize
function M.filename(opts)
  opts = extend_tbl({
    fallback = "Untitled",
    fname = function(nr) return vim.api.nvim_buf_get_name(nr) end,
    modify = ":t",
  }, opts)
  return function(self)
    local path = opts.fname(self and self.bufnr or 0)
    local filename = vim.fn.fnamemodify(path, opts.modify)
    return status_utils.stylize((path == "" and opts.fallback or filename), opts)
  end
end

--- A provider function for showing the current file encoding
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the file encoding
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_encoding() }
-- @see astronvim.utils.status.utils.stylize
function M.file_encoding(opts)
  return function(self)
    local buf_enc = vim.bo[self and self.bufnr or 0].fenc
    return status_utils.stylize(string.upper(buf_enc ~= "" and buf_enc or vim.o.enc), opts)
  end
end

--- A provider function for showing the current file format
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the file format
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_format() }
-- @see astronvim.utils.status.utils.stylize
function M.file_format(opts)
  return function(self)
    local buf_format = vim.bo[self and self.bufnr or 0].fileformat
    return status_utils.stylize(string.upper(buf_format ~= "" and buf_format or vim.o.fileformat), opts)
  end
end

--- Get a unique filepath between all buffers
---@param opts? table options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function
---@return function # path to file that uniquely identifies each buffer
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.unique_path() }
-- @see astronvim.utils.status.utils.stylize
function M.unique_path(opts)
  opts = extend_tbl({
    buf_name = function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
    bufnr = 0,
    max_length = 16,
  }, opts)
  local function path_parts(bufnr)
    local parts = {}
    for match in (vim.api.nvim_buf_get_name(bufnr) .. "/"):gmatch("(.-)" .. "/") do
      table.insert(parts, match)
    end
    return parts
  end
  return function(self)
    opts.bufnr = self and self.bufnr or opts.bufnr
    local name = opts.buf_name(opts.bufnr)
    local unique_path = ""
    -- check for same buffer names under different dirs
    local current
    for _, value in ipairs(vim.t.bufs) do
      if name == opts.buf_name(value) and value ~= opts.bufnr then
        if not current then current = path_parts(opts.bufnr) end
        local other = path_parts(value)

        for i = #current - 1, 1, -1 do
          if current[i] ~= other[i] then
            unique_path = current[i] .. "/"
            break
          end
        end
      end
    end
    return status_utils.stylize(
      (
        opts.max_length > 0
        and #unique_path > opts.max_length
        and string.sub(unique_path, 1, opts.max_length - 2) .. get_icon "Ellipsis" .. "/"
      ) or unique_path,
      opts
    )
  end
end

--- A provider function for showing if the current file is modifiable
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the indicator if the file is modified
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_modified() }
-- @see astronvim.utils.status.utils.stylize
function M.file_modified(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileModified" }, show_empty = true }, opts)
  return function(self)
    return status_utils.stylize(condition.file_modified((self or {}).bufnr) and opts.str or nil, opts)
  end
end

--- A provider function for showing if the current file is read-only
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the indicator if the file is read-only
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_read_only() }
-- @see astronvim.utils.status.utils.stylize
function M.file_read_only(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileReadOnly" }, show_empty = true }, opts)
  return function(self)
    return status_utils.stylize(condition.file_read_only((self or {}).bufnr) and opts.str or nil, opts)
  end
end

--- A provider function for showing the current filetype icon
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the filetype icon
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_icon() }
-- @see astronvim.utils.status.utils.stylize
function M.file_icon(opts)
  return function(self)
    local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
    if not devicons_avail then return "" end
    local ft_icon, _ = devicons.get_icon(
      vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
      nil,
      { default = true }
    )
    return status_utils.stylize(ft_icon, opts)
  end
end

--- A provider function for showing the current git branch
---@param opts table options passed to the stylize function
---@return function # the function for outputting the git branch
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.git_branch() }
-- @see astronvim.utils.status.utils.stylize
function M.git_branch(opts)
  return function(self) return status_utils.stylize(vim.b[self and self.bufnr or 0].gitsigns_head or "", opts) end
end

--- A provider function for showing the current git diff count of a specific type
---@param opts? table options for type of git diff and options passed to the stylize function
---@return function|nil # the function for outputting the git diff
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.git_diff({ type = "added" }) }
-- @see astronvim.utils.status.utils.stylize
function M.git_diff(opts)
  if not opts or not opts.type then return end
  return function(self)
    local status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
    return status_utils.stylize(
      status and status[opts.type] and status[opts.type] > 0 and tostring(status[opts.type]) or "",
      opts
    )
  end
end

--- A provider function for showing the current diagnostic count of a specific severity
---@param opts table options for severity of diagnostic and options passed to the stylize function
---@return function|nil # the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.diagnostics({ severity = "ERROR" }) }
-- @see astronvim.utils.status.utils.stylize
function M.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function(self)
    local bufnr = self and self.bufnr or 0
    local count = #vim.diagnostic.get(bufnr, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    return status_utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

--- A provider function for showing the current progress of loading language servers
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the LSP progress
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.lsp_progress() }
-- @see astronvim.utils.status.utils.stylize
function M.lsp_progress(opts)
  local spinner = utils.get_spinner("LSPLoading", 1) or { "" }
  return function()
    local _, Lsp = next(astronvim.lsp.progress)
    return status_utils.stylize(Lsp and (spinner[math.floor(luv.hrtime() / 12e7) % #spinner + 1] .. table.concat({
      Lsp.title or "",
      Lsp.message or "",
      Lsp.percentage and "(" .. Lsp.percentage .. "%)" or "",
    }, " ")), opts)
  end
end

--- A provider function for showing the connected LSP client names
---@param opts? table options for explanding null_ls clients, max width percentage, and options passed to the stylize function
---@return function # the function for outputting the LSP client names
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.lsp_client_names({ expand_null_ls = true, truncate = 0.25 }) }
-- @see astronvim.utils.status.utils.stylize
function M.lsp_client_names(opts)
  opts = extend_tbl({ expand_null_ls = true, truncate = 0.25 }, opts)
  return function(self)
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = self and self.bufnr or 0 }) do
      if client.name == "null-ls" and opts.expand_null_ls then
        local null_ls_sources = {}
        for _, type in ipairs { "FORMATTING", "DIAGNOSTICS" } do
          for _, source in ipairs(status_utils.null_ls_sources(vim.bo.filetype, type)) do
            null_ls_sources[source] = true
          end
        end
        vim.list_extend(buf_client_names, vim.tbl_keys(null_ls_sources))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    local str = table.concat(buf_client_names, ", ")
    if type(opts.truncate) == "number" then
      local max_width = math.floor(status_utils.width() * opts.truncate)
      if #str > max_width then str = string.sub(str, 0, max_width) .. "…" end
    end
    return status_utils.stylize(str, opts)
  end
end

--- A provider function for showing if treesitter is connected
---@param opts? table options passed to the stylize function
---@return function # function for outputting TS if treesitter is connected
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.treesitter_status() }
-- @see astronvim.utils.status.utils.stylize
function M.treesitter_status(opts)
  return function() return status_utils.stylize(require("nvim-treesitter.parser").has_parser() and "TS" or "", opts) end
end

--- A provider function for displaying a single string
---@param opts? table options passed to the stylize function
---@return string # the stylized statusline string
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.str({ str = "Hello" }) }
-- @see astronvim.utils.status.utils.stylize
function M.str(opts)
  opts = extend_tbl({ str = " " }, opts)
  return status_utils.stylize(opts.str, opts)
end

return M
