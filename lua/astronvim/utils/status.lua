--- ### AstroNvim Status API
--
-- Statusline related utility functions to use within AstroNvim and user configurations.
--
-- This module can be loaded with `local status = require "astronvim.utils.status"`
--
-- @module astronvim.utils.status
-- @copyright 2022
-- @license GNU General Public License v3.0

local M = { hl = {}, init = {}, provider = {}, condition = {}, component = {}, utils = {}, env = {}, heirline = {} }

local utils = require "astronvim.utils"
local extend_tbl = utils.extend_tbl
local get_icon = utils.get_icon
local is_available = utils.is_available

M.env.fallback_colors = {
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

M.env.modes = {
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

M.env.separators = astronvim.user_opts("heirline.separators", {
  none = { "", "" },
  left = { "", "  " },
  right = { "  ", "" },
  center = { "  ", "  " },
  tab = { "", " " },
  breadcrumbs = "  ",
  path = "  ",
})

M.env.attributes = astronvim.user_opts("heirline.attributes", {
  buffer_active = { bold = true, italic = true },
  buffer_picker = { bold = true },
  macro_recording = { bold = true },
  git_branch = { bold = true },
  git_diff = { bold = true },
})

M.env.icon_highlights = astronvim.user_opts("heirline.icon_highlights", {
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

M.env.buf_matchers = {
  filetype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list) end,
  buftype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list) end,
  bufname = function(pattern_list, bufnr)
    return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr or 0), ":t"), pattern_list)
  end,
}

M.env.sign_handlers = {}
-- gitsigns handlers
local gitsigns = function(_)
  local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
  if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
end
for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Changedelete", "Delete" } do
  local name = "GitSigns" .. sign
  if not M.env.sign_handlers[name] then M.env.sign_handlers[name] = gitsigns end
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
  if not M.env.sign_handlers[name] then M.env.sign_handlers[name] = diagnostics end
end
-- DAP handlers
local dap_breakpoint = function(_)
  local dap_avail, dap = pcall(require, "dap")
  if dap_avail then vim.schedule(dap.toggle_breakpoint) end
end
for _, sign in ipairs { "", "Rejected", "Condition" } do
  local name = "DapBreakpoint" .. sign
  if not M.env.sign_handlers[name] then M.env.sign_handlers[name] = dap_breakpoint end
end
M.env.sign_handlers = astronvim.user_opts("heirline.sign_handlers", M.env.sign_handlers)

--- Get the highlight background color of the lualine theme for the current colorscheme
-- @param  mode the neovim mode to get the color of
-- @param  fallback the color to fallback on if a lualine theme is not present
-- @return The background color of the lualine theme or the fallback parameter if one doesn't exist
function M.hl.lualine_mode(mode, fallback)
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
-- @return the highlight group for the current mode
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.mode },
function M.hl.mode() return { bg = M.hl.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
-- @return the highlight group for the current mode foreground
-- @usage local heirline_component = require("heirline.utils").surround({ "|", "|" }, require("astronvim.utils.status").hl.mode_bg, heirline_component),

function M.hl.mode_bg() return M.env.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
-- @return the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.fileicon(), hl = require("astronvim.utils.status").hl.filetype_color },
function M.hl.filetype_color(self)
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
-- @param name string, the name of the element to get the attributes and colors for
-- @param include_bg boolean whether or not to include background color (Default: false)
-- @return a table of highlight information
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.get_attributes("treesitter") },
function M.hl.get_attributes(name, include_bg)
  local hl = M.env.attributes[name] or {}
  hl.fg = name .. "_fg"
  if include_bg then hl.bg = name .. "_bg" end
  return hl
end

--- Enable filetype color highlight if enabled in icon_highlights.file_icon options
-- @param name string of the icon_highlights.file_icon table element
-- @return function for setting hl property in a component
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astronvim.utils.status").hl.file_icon("winbar") },
function M.hl.file_icon(name)
  local hl_enabled = M.env.icon_highlights.file_icon[name]
  return function(self)
    if hl_enabled == true or (type(hl_enabled) == "function" and hl_enabled(self)) then
      return M.hl.filetype_color(self)
    end
  end
end

--- An `init` function to build a set of children components for LSP breadcrumbs
-- @param opts options for configuring the breadcrumbs (default: `{ max_depth = 5, separator = "  ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
-- @usage local heirline_component = { init = require("astronvim.utils.status").init.breadcrumbs { padding = { left = 1 } } }
function M.init.breadcrumbs(opts)
  opts = extend_tbl({
    max_depth = 5,
    separator = M.env.separators.breadcrumbs or "  ",
    icon = { enabled = true, hl = M.env.icon_highlights.breadcrumbs },
    padding = { left = 0, right = 0 },
  }, opts)
  return function(self)
    local data = require("aerial").get_location(true) or {}
    local children = {}
    -- add prefix if needed, use the separator if true, or use the provided character
    if opts.prefix and not vim.tbl_isempty(data) then
      table.insert(children, { provider = opts.prefix == true and opts.separator or opts.prefix })
    end
    local start_idx = 0
    if opts.max_depth and opts.max_depth > 0 then
      start_idx = #data - opts.max_depth
      if start_idx > 0 then
        table.insert(children, { provider = require("astronvim.utils").get_icon "Ellipsis" .. opts.separator })
      end
    end
    -- create a child for each level
    for i, d in ipairs(data) do
      if i > start_idx then
        local child = {
          { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") }, -- add symbol name
          on_click = { -- add on click function
            minwid = M.utils.encode_pos(d.lnum, d.col, self.winnr),
            callback = function(_, minwid)
              local lnum, col, winnr = M.utils.decode_pos(minwid)
              vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
            end,
            name = "heirline_breadcrumbs",
          },
        }
        if opts.icon.enabled then -- add icon and highlight if enabled
          local hl = opts.icon.hl
          if type(hl) == "function" then hl = hl(self) end
          local hlgroup = string.format("Aerial%sIcon", d.kind)
          table.insert(child, 1, {
            provider = string.format("%s ", d.icon),
            hl = (hl and vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
          })
        end
        if #data > 1 and i < #data then table.insert(child, { provider = opts.separator }) end -- add a separator only if needed
        table.insert(children, child)
      end
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = M.pad_string(" ", { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = M.pad_string(" ", { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

--- An `init` function to build a set of children components for a separated path to file
-- @param opts options for configuring the breadcrumbs (default: `{ max_depth = 3, path_func = M.provider.unique_path(), separator = "  ", suffix = true, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
-- @usage local heirline_component = { init = require("astronvim.utils.status").init.separated_path { padding = { left = 1 } } }
function M.init.separated_path(opts)
  opts = extend_tbl({
    max_depth = 3,
    path_func = M.provider.unique_path(),
    separator = M.env.separators.path or "  ",
    suffix = true,
    padding = { left = 0, right = 0 },
  }, opts)
  if opts.suffix == true then opts.suffix = opts.separator end
  return function(self)
    local path = opts.path_func(self)
    if path == "." then path = "" end -- if there is no path, just replace with empty string
    local data = vim.fn.split(path, "/")
    local children = {}
    -- add prefix if needed, use the separator if true, or use the provided character
    if opts.prefix and not vim.tbl_isempty(data) then
      table.insert(children, { provider = opts.prefix == true and opts.separator or opts.prefix })
    end
    local start_idx = 0
    if opts.max_depth and opts.max_depth > 0 then
      start_idx = #data - opts.max_depth
      if start_idx > 0 then
        table.insert(children, { provider = require("astronvim.utils").get_icon "Ellipsis" .. opts.separator })
      end
    end
    -- create a child for each level
    for i, d in ipairs(data) do
      if i > start_idx then
        local child = { { provider = d } }
        local separator = i < #data and opts.separtor or opts.suffix
        if separator then table.insert(child, { provider = separator }) end
        table.insert(children, child)
      end
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = M.pad_string(" ", { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = M.pad_string(" ", { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

--- An `init` function to build multiple update events which is not supported yet by Heirline's update field
-- @param opts an array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
-- @return The Heirline init function
-- @usage local heirline_component = { init = require("astronvim.utils.status").init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }
function M.init.update_events(opts)
  return function(self)
    if not rawget(self, "once") then
      local clear_cache = function() self._win_cache = nil end
      for _, event in ipairs(opts) do
        local event_opts = { callback = clear_cache }
        if type(event) == "table" then
          event_opts.pattern = event.pattern
          event_opts.callback = event.callback or clear_cache
          event.pattern = nil
          event.callback = nil
        end
        vim.api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

--- A provider function for the fill string
-- @return the statusline string for filling the empty space
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.fill }
function M.provider.fill() return "%=" end

--- A provider function for the signcolumn string
-- @param opts options passed to the stylize function
-- @return the statuscolumn string for adding the signcolumn
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.signcolumn }
-- @see astronvim.utils.status.utils.stylize
function M.provider.signcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  return M.utils.stylize("%s", opts)
end

--- A provider function for the numbercolumn string
-- @param opts options passed to the stylize function
-- @return the statuscolumn string for adding the numbercolumn
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.numbercolumn }
-- @see astronvim.utils.status.utils.stylize
function M.provider.numbercolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  return function()
    local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
    local str = ((num and not relnum) and "%l") or ((relnum and not num) and "%r") or "%{v:relnum?v:relnum:v:lnum}"
    return M.utils.stylize(str, opts)
  end
end

--- A provider function for building a foldcolumn
-- @param opts options passed to the stylize function
-- @return a custom foldcolumn function for the statuscolumn that doesn't show the nest levels
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.foldcolumn }
-- @see astronvim.utils.status.utils.stylize
function M.provider.foldcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  local ffi = require "astronvim.utils.ffi" -- get AstroNvim C extensions
  local fillchars = vim.opt.fillchars:get()
  local foldopen = fillchars.foldopen or get_icon "FoldOpened"
  local foldclosed = fillchars.foldclose or get_icon "FoldClosed"
  local foldsep = fillchars.foldsep or get_icon "FoldSeparator"
  return function() -- move to M.provider.fold_indicator
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
              ((closed and (col == foldinfo.level or col == width)) and foldclosed)
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
    return M.utils.stylize(str .. "%*", opts)
  end
end

--- A provider function for the current tab numbre
-- @return the statusline function to return a string for a tab number
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.tabnr() }
function M.provider.tabnr()
  return function(self) return (self and self.tabnr) and "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" or "" end
end

--- A provider function for showing if spellcheck is on
-- @param opts options passed to the stylize function
-- @return the function for outputting if spell is enabled
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.spell() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.spell(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Spellcheck" }, show_empty = true }, opts)
  return function() return M.utils.stylize(vim.wo.spell and opts.str, opts) end
end

--- A provider function for showing if paste is enabled
-- @param opts options passed to the stylize function
-- @return the function for outputting if paste is enabled

-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.paste() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.paste(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Paste" }, show_empty = true }, opts)
  return function() return M.utils.stylize(vim.opt.paste:get() and opts.str, opts) end
end

--- A provider function for displaying if a macro is currently being recorded
-- @param opts a prefix before the recording register and options passed to the stylize function
-- @return a function that returns a string of the current recording status
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.macro_recording() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.macro_recording(opts)
  opts = extend_tbl({ prefix = "@" }, opts)
  return function()
    local register = vim.fn.reg_recording()
    if register ~= "" then register = opts.prefix .. register end
    return M.utils.stylize(register, opts)
  end
end

--- A provider function for displaying the current search count
-- @param opts options for `vim.fn.searchcount` and options passed to the stylize function
-- @return a function that returns a string of the current search location
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.search_count() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function() return vim.fn.searchcount() end
    or function() return vim.fn.searchcount(opts) end
  return function()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == "table" and search.total then
      return M.utils.stylize(
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
-- @param opts options for padding the text and options passed to the stylize function
-- @return the function for displaying the text of the current vim mode
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.mode_text() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.mode_text(opts)
  local max_length = math.max(unpack(vim.tbl_map(function(str) return #str[1] end, vim.tbl_values(M.env.modes))))
  return function()
    local text = M.env.modes[vim.fn.mode()][1]
    if opts.pad_text then
      local padding = max_length - #text
      if opts.pad_text == "right" then
        text = string.rep(" ", padding) .. text
      elseif opts.pad_text == "left" then
        text = text .. string.rep(" ", padding)
      elseif opts.pad_text == "center" then
        text = string.rep(" ", math.floor(padding / 2)) .. text .. string.rep(" ", math.ceil(padding / 2))
      end
    end
    return M.utils.stylize(text, opts)
  end
end

--- A provider function for showing the percentage of the current location in a document
-- @param opts options for Top/Bot text, fixed width, and options passed to the stylize function
-- @return the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.percentage() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.percentage(opts)
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
    return M.utils.stylize(text, opts)
  end
end

--- A provider function for showing the current line and character in a document
-- @param opts options for padding the line and character locations and options passed to the stylize function
-- @return the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see astronvim.utils.status.utils.stylize
function M.provider.ruler(opts)
  opts = extend_tbl({ pad_ruler = { line = 3, char = 2 } }, opts)
  local padding_str = string.format("%%%dd:%%-%dd", opts.pad_ruler.line, opts.pad_ruler.char)
  return function()
    local line = vim.fn.line "."
    local char = vim.fn.virtcol "."
    return M.utils.stylize(string.format(padding_str, line, char), opts)
  end
end

--- A provider function for showing the current location as a scrollbar
-- @param opts options passed to the stylize function
-- @return the function for outputting the scrollbar
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.scrollbar() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    if sbar[i] then return M.utils.stylize(string.rep(sbar[i], 2), opts) end
  end
end

--- A provider to simply show a close button icon
-- @param opts options passed to the stylize function and the kind of icon to use
-- @return return the stylized icon
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.close_button() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.close_button(opts)
  opts = extend_tbl({ kind = "BufferClose" }, opts)
  return M.utils.stylize(get_icon(opts.kind), opts)
end

--- A provider function for showing the current filetype
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.filetype() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.filetype(opts)
  return function(self)
    local buffer = vim.bo[self and self.bufnr or 0]
    return M.utils.stylize(string.lower(buffer.filetype), opts)
  end
end

--- A provider function for showing the current filename
-- @param opts options for argument to fnamemodify to format filename and options passed to the stylize function
-- @return the function for outputting the filename
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.filename() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.filename(opts)
  opts = extend_tbl({
    fallback = "Empty",
    fname = function(nr) return vim.api.nvim_buf_get_name(nr) end,
    modify = ":t",
  }, opts)
  return function(self)
    local filename = vim.fn.fnamemodify(opts.fname(self and self.bufnr or 0), opts.modify)
    return M.utils.stylize((filename == "" and opts.fallback or filename), opts)
  end
end

--- Get a unique filepath between all buffers
-- @param opts options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function
-- @return path to file that uniquely identifies each buffer
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.unique_path() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.unique_path(opts)
  opts = extend_tbl({
    buf_name = function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
    bufnr = 0,
    max_length = 16,
  }, opts)
  return function(self)
    opts.bufnr = self and self.bufnr or opts.bufnr
    local name = opts.buf_name(opts.bufnr)
    local unique_path = ""
    -- check for same buffer names under different dirs
    for _, value in ipairs(vim.t.bufs) do
      if name == opts.buf_name(value) and value ~= opts.bufnr then
        local other = {}
        for match in (vim.api.nvim_buf_get_name(value) .. "/"):gmatch("(.-)" .. "/") do
          table.insert(other, match)
        end

        local current = {}
        for match in (vim.api.nvim_buf_get_name(opts.bufnr) .. "/"):gmatch("(.-)" .. "/") do
          table.insert(current, match)
        end

        unique_path = ""

        for i = #current - 1, 1, -1 do
          local value_current = current[i]
          local other_current = other[i]

          if value_current ~= other_current then
            unique_path = value_current .. "/"
            break
          end
        end
        break
      end
    end
    return M.utils.stylize(
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
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is modified
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_modified() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.file_modified(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileModified" }, show_empty = true }, opts)
  return function(self) return M.utils.stylize(M.condition.file_modified((self or {}).bufnr) and opts.str, opts) end
end

--- A provider function for showing if the current file is read-only
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is read-only
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_read_only() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.file_read_only(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileReadOnly" }, show_empty = true }, opts)
  return function(self) return M.utils.stylize(M.condition.file_read_only((self or {}).bufnr) and opts.str, opts) end
end

--- A provider function for showing the current filetype icon
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype icon
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.file_icon() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.file_icon(opts)
  return function(self)
    local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
    if not devicons_avail then return "" end
    local ft_icon, _ = devicons.get_icon(
      vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
      nil,
      { default = true }
    )
    return M.utils.stylize(ft_icon, opts)
  end
end

--- A provider function for showing the current git branch
-- @param opts options passed to the stylize function
-- @return the function for outputting the git branch
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.git_branch() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.git_branch(opts)
  return function(self) return M.utils.stylize(vim.b[self and self.bufnr or 0].gitsigns_head or "", opts) end
end

--- A provider function for showing the current git diff count of a specific type
-- @param opts options for type of git diff and options passed to the stylize function
-- @return the function for outputting the git diff
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.git_diff({ type = "added" }) }
-- @see astronvim.utils.status.utils.stylize
function M.provider.git_diff(opts)
  if not opts or not opts.type then return end
  return function(self)
    local status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
    return M.utils.stylize(
      status and status[opts.type] and status[opts.type] > 0 and tostring(status[opts.type]) or "",
      opts
    )
  end
end

--- A provider function for showing the current diagnostic count of a specific severity
-- @param opts options for severity of diagnostic and options passed to the stylize function
-- @return the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.diagnostics({ severity = "ERROR" }) }
-- @see astronvim.utils.status.utils.stylize
function M.provider.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function(self)
    local bufnr = self and self.bufnr or 0
    local count = #vim.diagnostic.get(bufnr, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    return M.utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

--- A provider function for showing the current progress of loading language servers
-- @param opts options passed to the stylize function
-- @return the function for outputting the LSP progress
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.lsp_progress() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.lsp_progress(opts)
  return function()
    local Lsp = vim.lsp.util.get_progress_messages()[1]
    return M.utils.stylize(
      Lsp
        and (
          get_icon("LSP" .. ((Lsp.percentage or 0) >= 70 and { "Loaded", "Loaded", "Loaded" } or {
            "Loading1",
            "Loading2",
            "Loading3",
          })[math.floor(vim.loop.hrtime() / 12e7) % 3 + 1])
          .. (Lsp.title and " " .. Lsp.title or "")
          .. (Lsp.message and " " .. Lsp.message or "")
          .. (Lsp.percentage and " (" .. Lsp.percentage .. "%)" or "")
        ),
      opts
    )
  end
end

--- A provider function for showing the connected LSP client names
-- @param opts options for explanding null_ls clients, max width percentage, and options passed to the stylize function
-- @return the function for outputting the LSP client names
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.lsp_client_names({ expand_null_ls = true, truncate = 0.25 }) }
-- @see astronvim.utils.status.utils.stylize
function M.provider.lsp_client_names(opts)
  opts = extend_tbl({ expand_null_ls = true, truncate = 0.25 }, opts)
  return function(self)
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = self and self.bufnr or 0 }) do
      if client.name == "null-ls" and opts.expand_null_ls then
        local null_ls_sources = {}
        for _, type in ipairs { "FORMATTING", "DIAGNOSTICS" } do
          for _, source in ipairs(M.utils.null_ls_sources(vim.bo.filetype, type)) do
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
      local max_width = math.floor(M.utils.width() * opts.truncate)
      if #str > max_width then str = string.sub(str, 0, max_width) .. "…" end
    end
    return M.utils.stylize(str, opts)
  end
end

--- A provider function for showing if treesitter is connected
-- @param opts options passed to the stylize function
-- @return the function for outputting TS if treesitter is connected
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.treesitter_status() }
-- @see astronvim.utils.status.utils.stylize
function M.provider.treesitter_status(opts)
  return function() return M.utils.stylize(require("nvim-treesitter.parser").has_parser() and "TS" or "", opts) end
end

--- A provider function for displaying a single string
-- @param opts options passed to the stylize function
-- @return the stylized statusline string
-- @usage local heirline_component = { provider = require("astronvim.utils.status").provider.str({ str = "Hello" }) }
-- @see astronvim.utils.status.utils.stylize
function M.provider.str(opts)
  opts = extend_tbl({ str = " " }, opts)
  return M.utils.stylize(opts.str, opts)
end

--- A condition function if the window is currently active
-- @return boolean of whether or not the window is currently actie
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.is_active }
function M.condition.is_active() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end

--- A condition function if the buffer filetype,buftype,bufname match a pattern
-- @param patterns the table of patterns to match
-- @param bufnr number of the buffer to match (Default: 0 [current])
-- @return boolean of whether or not LSP is attached
-- @usage local heirline_component = { provider = "Example Provider", condition = function() return require("astronvim.utils.status").condition.buffer_matches { buftype = { "terminal" } } end }
function M.condition.buffer_matches(patterns, bufnr)
  for kind, pattern_list in pairs(patterns) do
    if M.env.buf_matchers[kind](pattern_list, bufnr) then return true end
  end
  return false
end

--- A condition function if a macro is being recorded
-- @return boolean of whether or not a macro is currently being recorded
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.is_macro_recording }
function M.condition.is_macro_recording() return vim.fn.reg_recording() ~= "" end

--- A condition function if search is visible
-- @return boolean of whether or not searching is currently visible
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.is_hlsearch }
function M.condition.is_hlsearch() return vim.v.hlsearch ~= 0 end

--- A condition function if the current file is in a git repo
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not the current file is in a git repo
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.is_git_repo }
function M.condition.is_git_repo(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  return vim.b[bufnr or 0].gitsigns_head or vim.b[bufnr or 0].gitsigns_status_dict
end

--- A condition function if there are any git changes
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not there are any git changes
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.git_changed }
function M.condition.git_changed(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  local git_status = vim.b[bufnr or 0].gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

--- A condition function if the current buffer is modified
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not the current buffer is modified
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.file_modified }
function M.condition.file_modified(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  return vim.bo[bufnr or 0].modified
end

--- A condition function if the current buffer is read only
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not the current buffer is read only or not modifiable
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.file_read_only }
function M.condition.file_read_only(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  local buffer = vim.bo[bufnr or 0]
  return not buffer.modifiable or buffer.readonly
end

--- A condition function if the current file has any diagnostics
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not the current file has any diagnostics
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.has_diagnostics }
function M.condition.has_diagnostics(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  return vim.g.diagnostics_mode > 0 and #vim.diagnostic.get(bufnr or 0) > 0
end

--- A condition function if there is a defined filetype
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not there is a filetype
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.has_filetype }
function M.condition.has_filetype(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  return vim.fn.empty(vim.fn.expand "%:t") ~= 1 and vim.bo[bufnr or 0].filetype and vim.bo[bufnr or 0].filetype ~= ""
end

--- A condition function if Aerial is available
-- @return boolean of whether or not aerial plugin is installed
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.aerial_available }
-- function M.condition.aerial_available() return is_available "aerial.nvim" end
function M.condition.aerial_available() return package.loaded["aerial"] end

--- A condition function if LSP is attached
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not LSP is attached
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.lsp_attached }
function M.condition.lsp_attached(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  return next(vim.lsp.get_active_clients { bufnr = bufnr or 0 }) ~= nil
end

--- A condition function if treesitter is in use
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of whether or not treesitter is active
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astronvim.utils.status").condition.treesitter_available }
function M.condition.treesitter_available(bufnr)
  if not package.loaded["nvim-treesitter"] then return false end
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  local parsers = require "nvim-treesitter.parsers"
  return parsers.has_parser(parsers.get_buf_lang(bufnr or vim.api.nvim_get_current_buf()))
end

--- A condition function if the foldcolumn is enabled
-- @treturn true if vim.opt.foldcolumn > 0, false if vim.opt.foldcolumn == 0
function M.condition.foldcolumn_enabled() return vim.opt.foldcolumn:get() ~= "0" end

--- A condition function if the number column is enabled
-- @treturn true if vim.opt.number or vim.opt.relativenumber, false if neither
function M.condition.numbercolumn_enabled() return vim.opt.number:get() or vim.opt.relativenumber:get() end

local function escape(str) return str:gsub("%%", "%%%%") end

--- A utility function to stylize a string with an icon from lspkind, separators, and left/right padding
-- @param str the string to stylize
-- @param opts options of `{ padding = { left = 0, right = 0 }, separator = { left = "|", right = "|" }, escape = true, show_empty = false, icon = { kind = "NONE", padding = { left = 0, right = 0 } } }`
-- @return the stylized string
-- @usage local string = require("astronvim.utils.status").utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })
function M.utils.stylize(str, opts)
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

--- A Heirline component for filling in the empty space of the bar
-- @param opts options for configuring the other fields of the heirline component
-- @return The heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.fill()
function M.component.fill(opts) return extend_tbl({ provider = M.provider.fill() }, opts) end

--- A function to build a set of children components for an entire file information section
-- @param opts options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.file_info()
function M.component.file_info(opts)
  opts = extend_tbl({
    file_icon = { hl = M.hl.file_icon "statusline", padding = { left = 1, right = 1 } },
    filename = {},
    file_modified = { padding = { left = 1 } },
    file_read_only = { padding = { left = 1 } },
    surround = { separator = "left", color = "file_info_bg", condition = M.condition.has_filetype },
    hl = M.hl.get_attributes "file_info",
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, {
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
-- @param opts options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.tabline_file_info()
function M.component.tabline_file_info(opts)
  return M.component.file_info(extend_tbl({
    file_icon = {
      condition = function(self) return not self._show_picker end,
      hl = M.hl.file_icon "tabline",
    },
    unique_path = {
      hl = function(self) return M.hl.get_attributes(self.tab_type .. "_path") end,
    },
    close_button = {
      hl = function(self) return M.hl.get_attributes(self.tab_type .. "_close") end,
      padding = { left = 1, right = 1 },
      on_click = {
        callback = function(_, minwid) require("astronvim.utils.buffer").close(minwid) end,
        minwid = function(self) return self.bufnr end,
        name = "heirline_tabline_close_buffer_callback",
      },
    },
    padding = { left = 1, right = 1 },
    hl = function(self)
      local tab_type = self.tab_type
      if self._show_picker and self.tab_type ~= "buffer_active" then tab_type = "buffer_visible" end
      return M.hl.get_attributes(tab_type)
    end,
    surround = false,
  }, opts))
end

--- A function to build a set of children components for an entire navigation section
-- @param opts options for configuring ruler, percentage, scrollbar, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.nav()
function M.component.nav(opts)
  opts = extend_tbl({
    ruler = {},
    percentage = { padding = { left = 1 } },
    scrollbar = { padding = { left = 1 }, hl = { fg = "scrollbar" } },
    surround = { separator = "right", color = "nav_bg" },
    hl = M.hl.get_attributes "nav",
    update = { "CursorMoved", "CursorMovedI", "BufEnter" },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "ruler", "percentage", "scrollbar" }))
end

--- A function to build a set of children components for information shown in the cmdline
-- @param opts options for configuring macro recording, search count, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.cmd_info()
function M.component.cmd_info(opts)
  opts = extend_tbl({
    macro_recording = {
      icon = { kind = "MacroRecording", padding = { right = 1 } },
      condition = M.condition.is_macro_recording,
      update = {
        "RecordingEnter",
        "RecordingLeave",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
      },
    },
    search_count = {
      icon = { kind = "Search", padding = { right = 1 } },
      padding = { left = 1 },
      condition = M.condition.is_hlsearch,
    },
    surround = {
      separator = "center",
      color = "cmd_info_bg",
      condition = function() return M.condition.is_hlsearch() or M.condition.is_macro_recording() end,
    },
    condition = function() return vim.opt.cmdheight:get() == 0 end,
    hl = M.hl.get_attributes "cmd_info",
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "macro_recording", "search_count" }))
end

--- A function to build a set of children components for a mode section
-- @param opts options for configuring mode_text, paste, spell, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.mode { mode_text = true }
function M.component.mode(opts)
  opts = extend_tbl({
    mode_text = false,
    paste = false,
    spell = false,
    surround = { separator = "left", color = M.hl.mode_bg },
    hl = M.hl.get_attributes "mode",
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  }, opts)
  if not opts["mode_text"] then opts.str = { str = " " } end
  return M.component.builder(M.utils.setup_providers(opts, { "mode_text", "str", "paste", "spell" }))
end

--- A function to build a set of children components for an LSP breadcrumbs section
-- @param opts options for configuring breadcrumbs and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.breadcumbs()
function M.component.breadcrumbs(opts)
  opts = extend_tbl({ padding = { left = 1 }, condition = M.condition.aerial_available, update = "CursorMoved" }, opts)
  opts.init = M.init.breadcrumbs(opts)
  return opts
end

--- A function to build a set of children components for the current file path
-- @param opts options for configuring path and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.separated_path()
function M.component.separated_path(opts)
  opts = extend_tbl({ padding = { left = 1 }, update = { "BufEnter", "DirChanged" } }, opts)
  opts.init = M.init.separated_path(opts)
  return opts
end

--- A function to build a set of children components for a git branch section
-- @param opts options for configuring git branch and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.git_branch()
function M.component.git_branch(opts)
  opts = extend_tbl({
    git_branch = { icon = { kind = "GitBranch", padding = { right = 1 } } },
    surround = { separator = "left", color = "git_branch_bg", condition = M.condition.is_git_repo },
    hl = M.hl.get_attributes "git_branch",
    on_click = {
      name = "heirline_branch",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_branches() end, 100)
        end
      end,
    },
    update = { "User", pattern = "GitSignsUpdate" },
    init = M.init.update_events { "BufEnter" },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "git_branch" }))
end

--- A function to build a set of children components for a git difference section
-- @param opts options for configuring git changes and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.git_diff()
function M.component.git_diff(opts)
  opts = extend_tbl({
    added = { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
    changed = { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
    removed = { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
    hl = M.hl.get_attributes "git_diff",
    on_click = {
      name = "heirline_git",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_status() end, 100)
        end
      end,
    },
    surround = { separator = "left", color = "git_diff_bg", condition = M.condition.git_changed },
    update = { "User", pattern = "GitSignsUpdate" },
    init = M.init.update_events { "BufEnter" },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "added", "changed", "removed" }, function(p_opts, provider)
    local out = M.utils.build_provider(p_opts, provider)
    if out then
      out.provider = "git_diff"
      out.opts.type = provider
      if out.hl == nil then out.hl = { fg = "git_" .. provider } end
    end
    return out
  end))
end

--- A function to build a set of children components for a diagnostics section
-- @param opts options for configuring diagnostic providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.diagnostics()
function M.component.diagnostics(opts)
  opts = extend_tbl({
    ERROR = { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
    WARN = { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
    INFO = { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
    HINT = { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
    surround = { separator = "left", color = "diagnostics_bg", condition = M.condition.has_diagnostics },
    hl = M.hl.get_attributes "diagnostics",
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
  return M.component.builder(
    M.utils.setup_providers(opts, { "ERROR", "WARN", "INFO", "HINT" }, function(p_opts, provider)
      local out = M.utils.build_provider(p_opts, provider)
      if out then
        out.provider = "diagnostics"
        out.opts.severity = provider
        if out.hl == nil then out.hl = { fg = "diag_" .. provider } end
      end
      return out
    end)
  )
end

--- A function to build a set of children components for a Treesitter section
-- @param opts options for configuring diagnostic providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.treesitter()
function M.component.treesitter(opts)
  opts = extend_tbl({
    str = { str = "TS", icon = { kind = "ActiveTS", padding = { right = 1 } } },
    surround = {
      separator = "right",
      color = "treesitter_bg",
      condition = M.condition.treesitter_available,
    },
    hl = M.hl.get_attributes "treesitter",
    update = { "OptionSet", pattern = "syntax" },
    init = M.init.update_events { "BufEnter" },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "str" }))
end

--- A function to build a set of children components for an LSP section
-- @param opts options for configuring lsp progress and client_name providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.lsp()
function M.component.lsp(opts)
  opts = extend_tbl({
    lsp_progress = {
      str = "",
      padding = { right = 1 },
      update = {
        "User",
        pattern = { "LspProgressUpdate", "LspRequest" },
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
    hl = M.hl.get_attributes "lsp",
    surround = { separator = "right", color = "lsp_bg", condition = M.condition.lsp_attached },
    on_click = {
      name = "heirline_lsp",
      callback = function()
        vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
      end,
    },
  }, opts)
  return M.component.builder(
    M.utils.setup_providers(
      opts,
      { "lsp_progress", "lsp_client_names" },
      function(p_opts, provider, i)
        return p_opts
            and {
              flexible = i,
              M.utils.build_provider(p_opts, M.provider[provider](p_opts)),
              M.utils.build_provider(p_opts, M.provider.str(p_opts)),
            }
          or false
      end
    )
  )
end

--- A function to build a set of components for a foldcolumn section in a statuscolumn
-- @param opts options for configuring foldcolumn and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.foldcolumn()
function M.component.foldcolumn(opts)
  opts = extend_tbl({
    foldcolumn = { padding = { right = 1 } },
    condition = M.condition.foldcolumn_enabled,
    on_click = {
      name = "fold_click",
      callback = function(...)
        local char = M.utils.statuscolumn_clickargs(...).char
        local fillchars = vim.opt_local.fillchars:get()
        if char == (fillchars.foldopen or get_icon "FoldOpened") then
          vim.cmd "norm! zc"
        elseif char == (fillchars.foldcolse or get_icon "FoldClosed") then
          vim.cmd "norm! zo"
        end
      end,
    },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "foldcolumn" }))
end

--- A function to build a set of components for a numbercolumn section in statuscolumn
-- @param opts options for configuring numbercolumn and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.numbercolumn()
function M.component.numbercolumn(opts)
  opts = extend_tbl({
    numbercolumn = { padding = { right = 1 } },
    condition = M.condition.numbercolumn_enabled,
    on_click = {
      name = "line_click",
      callback = function(...)
        local args = M.utils.statuscolumn_clickargs(...)
        if args.mods:find "c" then
          local dap_avail, dap = pcall(require, "dap")
          if dap_avail then vim.schedule(dap.toggle_breakpoint) end
        end
      end,
    },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "numbercolumn" }))
end

--- A function to build a set of components for a signcolumn section in statuscolumn
-- @param opts options for configuring signcolumn and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").component.signcolumn()
function M.component.signcolumn(opts)
  opts = extend_tbl({
    signcolumn = {},
    condition = M.condition.signcolumn_enabled,
    on_click = {
      name = "sign_click",
      callback = function(...)
        local args = M.utils.statuscolumn_clickargs(...)
        if args.sign and args.sign.name and M.env.sign_handlers[args.sign.name] then
          M.env.sign_handlers[args.sign.name](args)
        end
      end,
    },
  }, opts)
  return M.component.builder(M.utils.setup_providers(opts, { "signcolumn" }))
end

--- A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding
-- @param opts a list of components to build into a section
-- @return The Heirline component table
-- @usage local heirline_component = require("astronvim.utils.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })
function M.component.builder(opts)
  opts = extend_tbl({ padding = { left = 0, right = 0 } }, opts)
  local children = {}
  if opts.padding.left > 0 then -- add left padding
    table.insert(children, { provider = M.pad_string(" ", { left = opts.padding.left - 1 }) })
  end
  for key, entry in pairs(opts) do
    if
      type(key) == "number"
      and type(entry) == "table"
      and M.provider[entry.provider]
      and (entry.opts == nil or type(entry.opts) == "table")
    then
      entry.provider = M.provider[entry.provider](entry.opts)
    end
    children[key] = entry
  end
  if opts.padding.right > 0 then -- add right padding
    table.insert(children, { provider = M.pad_string(" ", { right = opts.padding.right - 1 }) })
  end
  return opts.surround
      and M.utils.surround(opts.surround.separator, opts.surround.color, children, opts.surround.condition)
    or children
end

--- Convert a component parameter table to a table that can be used with the component builder
-- @param opts a table of provider options
-- @param provider a provider in `M.providers`
-- @return the provider table that can be used in `M.component.builder`
function M.utils.build_provider(opts, provider, _)
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
-- @param opts the table of options for the components
-- @param providers an ordered list like array of providers that are configured in the options table
-- @param setup a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `M.utils.build_provider`
-- @return the fully setup options table with the appropriately ordered providers
function M.utils.setup_providers(opts, providers, setup)
  setup = setup or M.utils.build_provider
  for i, provider in ipairs(providers) do
    opts[i] = setup(opts[provider], provider, i)
  end
  return opts
end

--- A utility function to get the width of the bar
-- @param is_winbar boolean true if you want the width of the winbar, false if you want the statusline width
-- @return the width of the specified bar
function M.utils.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

--- Add left and/or right padding to a string
-- @param str the string to add padding to
-- @param padding a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
-- @return the padded string
function M.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0) or ""
end

--- Surround component with separator and color adjustment
-- @param separator the separator index to use in `M.env.separators`
-- @param color the color to use as the separator foreground/component background
-- @param component the component to surround
-- @param condition the condition for displaying the surrounded component
-- @return the new surrounded component
function M.utils.surround(separator, color, component, condition)
  local function surround_color(self)
    local colors = type(color) == "function" and color(self) or color
    return type(colors) == "string" and { main = colors } or colors
  end

  separator = type(separator) == "string" and M.env.separators[separator] or separator
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
-- @param line line number of position
-- @param col column number of position
-- @param winnr a window number
-- @return the encoded position
function M.utils.encode_pos(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end

--- Decode a previously encoded position to it's sub parts
-- @param c the encoded position
-- @return line number, column number, window id
function M.utils.decode_pos(c) return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63) end

--- Get a list of registered null-ls providers for a given filetype
-- @param filetype the filetype to search null-ls for
-- @return a list of null-ls sources
function M.utils.null_ls_providers(filetype)
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
-- @param filetype the filetype to search null-ls for
-- @param method the null-ls method (check null-ls documentation for available methods)
-- @return the available sources for the given filetype and method
function M.utils.null_ls_sources(filetype, method)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and M.utils.null_ls_providers(filetype)[methods.internal[method]] or {}
end

--- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
-- @param self the self parameter from Heirline component on_click.callback function call
-- @param minwid the minwid parameter from Heirline component on_click.callback function call
-- @param clicks the clicks parameter from Heirline component on_click.callback function call
-- @param button the button parameter from Heirline component on_click.callback function call
-- @param mods the button parameter from Heirline component on_click.callback function call
-- @return the argument table with the decoded mouse information and signcolumn signs information
-- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astronvim.utils.status").utils.statuscolumn_clickargs(...) end } }
function M.utils.statuscolumn_clickargs(self, minwid, clicks, button, mods)
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

--- A helper function to get the type a tab or buffer is
-- @param self the self table from a heirline component function
-- @param prefix the prefix of the type, either "tab" or "buffer" (Default: "buffer")
-- @return the string of prefix with the type (i.e. "_active" or "_visible")
function M.heirline.tab_type(self, prefix)
  local tab_type = ""
  if self.is_active then
    tab_type = "_active"
  elseif self.is_visible then
    tab_type = "_visible"
  end
  return (prefix or "buffer") .. tab_type
end

--- Make a list of buffers, rendering each buffer with the provided component
---@param component table
---@return table
M.heirline.make_buflist = function(component)
  local overflow_hl = M.hl.get_attributes("buffer_overflow", true)
  return require("heirline.utils").make_buflist(
    M.utils.surround(
      "tab",
      function(self)
        return {
          main = M.heirline.tab_type(self) .. "_bg",
          left = "tabline_bg",
          right = "tabline_bg",
        }
      end,
      { -- bufferlist
        init = function(self) self.tab_type = M.heirline.tab_type(self) end,
        on_click = { -- add clickable component to each buffer
          callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
          minwid = function(self) return self.bufnr end,
          name = "heirline_tabline_buffer_callback",
        },
        { -- add buffer picker functionality to each buffer
          condition = function(self) return self._show_picker end,
          update = false,
          init = function(self)
            if not (self.label and self._picker_labels[self.label]) then
              local bufname = M.provider.filename()(self)
              local label = bufname:sub(1, 1)
              local i = 2
              while label ~= " " and self._picker_labels[label] do
                if i > #bufname then break end
                label = bufname:sub(i, i)
                i = i + 1
              end
              self._picker_labels[label] = self.bufnr
              self.label = label
            end
          end,
          provider = function(self) return M.provider.str { str = self.label, padding = { left = 1, right = 1 } } end,
          hl = M.hl.get_attributes "buffer_picker",
        },
        component, -- create buffer component
      },
      false -- disable surrounding
    ),
    { provider = get_icon "ArrowLeft" .. " ", hl = overflow_hl },
    { provider = get_icon "ArrowRight" .. " ", hl = overflow_hl },
    function() return vim.t.bufs end, -- use astronvim bufs variable
    false -- disable internal caching
  )
end

--- Alias to require("heirline.utils").make_tablist
function M.heirline.make_tablist(...) return require("heirline.utils").make_tablist(...) end

--- Run the buffer picker and execute the callback function on the selected buffer
-- @param callback function with a single parameter of the buffer number
function M.heirline.buffer_picker(callback)
  local tabline = require("heirline").tabline
  -- if buflist then
  local prev_showtabline = vim.opt.showtabline:get()
  if prev_showtabline ~= 2 then vim.opt.showtabline = 2 end
  vim.cmd.redrawtabline()
  local buflist = tabline and tabline._buflist and tabline._buflist[1]
  if buflist then
    buflist._picker_labels = {}
    buflist._show_picker = true
    vim.cmd.redrawtabline()
    local char = vim.fn.getcharstr()
    local bufnr = buflist._picker_labels[char]
    if bufnr then callback(bufnr) end
    buflist._show_picker = false
  end
  if prev_showtabline ~= 2 then vim.opt.showtabline = prev_showtabline end
  vim.cmd.redrawtabline()
  -- end
end

return M
