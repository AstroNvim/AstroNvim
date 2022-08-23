--- ### AstroNvim Status
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.status`
--
-- This module can also be manually loaded with `local status = require "core.utils.status"`
--
-- @module core.utils.status
-- @copyright 2022
-- @license GNU General Public License v3.0
astronvim.status = { hl = {}, init = {}, provider = {}, condition = {}, components = {}, utils = {}, env = {} }

astronvim.status.env.modes = {
  ["n"] = { "NORMAL", "normal" },
  ["no"] = { "N-PENDING", "normal" },
  ["i"] = { "INSERT", "insert" },
  ["ic"] = { "INSERT", "insert" },
  ["t"] = { "TERMINAL", "insert" },
  ["v"] = { "VISUAL", "visual" },
  ["V"] = { "V-LINE", "visual" },
  [""] = { "V-BLOCK", "visual" },
  ["R"] = { "REPLACE", "replace" },
  ["Rv"] = { "V-REPLACE", "replace" },
  ["s"] = { "SELECT", "visual" },
  ["S"] = { "S-LINE", "visual" },
  [""] = { "S-BLOCK", "visual" },
  ["c"] = { "COMMAND", "command" },
  ["cv"] = { "COMMAND", "command" },
  ["ce"] = { "COMMAND", "command" },
  ["r"] = { "PROMPT", "inactive" },
  ["rm"] = { "MORE", "inactive" },
  ["r?"] = { "CONFIRM", "inactive" },
  ["!"] = { "SHELL", "inactive" },
}

astronvim.status.separators = astronvim.user_plugin_opts("heirline.separators", {
  left = { "", "  " },
  right = { "  ", "" },
  center = { "  ", "  " },
})

--- Get the highlight color of the lualine theme for the current colorscheme
-- @param  mode the neovim mode to get the color of
-- @param  fallback the color to fallback on if a lualine theme is not present
-- @return The background color of the lualine theme or the fallback parameter if one doesn't exist
function astronvim.status.hl.lualine_mode(mode, fallback)
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. (vim.g.colors_name or "default_theme"))
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

function astronvim.status.hl.mode() return { fg = astronvim.status.hl.mode_fg() } end

--- Get the foreground color group for the current mode
-- @return the highlight group for the current mode foreground
function astronvim.status.hl.mode_fg() return astronvim.status.env.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
-- @return the highlight group for the current filetype foreground
function astronvim.status.hl.filetype_color()
  local _, color = require("nvim-web-devicons").get_icon_color(vim.fn.expand "%:t", nil, { default = true })
  return { fg = color }
end

--- An `init` function to build a set of children components for LSP breadcrumbs
-- @param opts options for configuring the breadcrumbs (default: `{ separator = " > ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
function astronvim.status.init.breadcrumbs(opts)
  local aerial_avail, aerial = pcall(require, "aerial")
  opts = astronvim.default_tbl(
    opts,
    { separator = " > ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }
  )
  return function(self)
    local data = aerial_avail and aerial.get_location(true) or {}
    local children = {}
    -- create a child for each level
    for i, d in ipairs(data) do
      local child = {
        { provider = d.name }, -- add symbol name
        on_click = { -- add on click function
          callback = function() vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { d.lnum, d.col }) end,
          name = string.format("goto_symbol_%d_%d", d.lnum, d.col),
        },
      }
      if opts.icon.enabled then -- add icon and highlight if enabled
        table.insert(child, 1, {
          provider = string.format("%s ", d.icon),
          hl = opts.icon.hl and string.format("Aerial%sIcon", d.kind) or nil,
        })
      end
      if #data > 1 and i < #data then table.insert(child, { provider = opts.separator }) end -- add a separator only if needed
      table.insert(children, child)
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = astronvim.pad_string(" ", { left = opts.padding.left }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = astronvim.pad_string(" ", { right = opts.padding.right }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

function astronvim.status.provider.fill() return "%=" end

function astronvim.status.provider.percentage(opts) return astronvim.status.utils.stylize("%p%%", opts) end

function astronvim.status.provider.ruler(opts)
  opts = astronvim.default_tbl(opts, { pad_ruler = { line = 0, char = 0 } })
  return astronvim.status.utils.stylize(string.format("%%%dl:%%%dc", opts.pad_ruler.line, opts.pad_ruler.char), opts)
end

function astronvim.status.provider.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    return astronvim.status.utils.stylize(string.rep(sbar[i], 2), opts)
  end
end

function astronvim.status.provider.filetype(opts)
  return function() return astronvim.status.utils.stylize(string.lower(vim.bo.filetype), opts) end
end

function astronvim.status.provider.filename(opts)
  opts = astronvim.default_tbl(opts, { modify = ":t" })
  return function()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), opts.modify)
    return astronvim.status.utils.stylize(filename == "" and "[No Name]" or filename, opts)
  end
end

function astronvim.status.provider.fileicon(opts)
  return function()
    local ft_icon, _ = require("nvim-web-devicons").get_icon(vim.fn.expand "%:t", nil, { default = true })
    return astronvim.status.utils.stylize(ft_icon, opts)
  end
end

function astronvim.status.provider.git_branch(opts)
  return function() return astronvim.status.utils.stylize(vim.b.gitsigns_head or "", opts) end
end

function astronvim.status.provider.git_diff(opts)
  if not opts or not opts.type then return end
  return function()
    local status = vim.b.gitsigns_status_dict
    return astronvim.status.utils.stylize(
      status and status[opts.type] and status[opts.type] > 0 and tostring(status[opts.type]) or "",
      opts
    )
  end
end

function astronvim.status.provider.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function()
    local count = #vim.diagnostic.get(0, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    return astronvim.status.utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

function astronvim.status.provider.lsp_progress(opts)
  return function()
    local Lsp = vim.lsp.util.get_progress_messages()[1]
    return astronvim.status.utils.stylize(
      Lsp
          and string.format(
            " %%<%s %s %s (%s%%%%) ",
            ((Lsp.percentage or 0) >= 70 and { "", "", "" } or { "", "", "" })[math.floor(
              vim.loop.hrtime() / 12e7
            ) % 3 + 1],
            Lsp.title or "",
            Lsp.message or "",
            Lsp.percentage or 0
          )
        or "",
      opts
    )
  end
end

function astronvim.status.provider.lsp_client_names(opts)
  opts = astronvim.default_tbl(opts, { expand_null_ls = true, truncate = 0.25 })
  return function()
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.buf_get_clients(0)) do
      if client.name == "null-ls" and opts.expand_null_ls then
        vim.list_extend(buf_client_names, astronvim.null_ls_sources(vim.bo.filetype, "FORMATTING"))
        vim.list_extend(buf_client_names, astronvim.null_ls_sources(vim.bo.filetype, "DIAGNOSTICS"))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    local str = table.concat(buf_client_names, ", ")
    if type(opts.truncate) == "number" then
      local max_width = math.floor(astronvim.status.utils.width() * opts.truncate)
      if #str > max_width then str = string.sub(str, 0, max_width) .. "…" end
    end
    return astronvim.status.utils.stylize(str, opts)
  end
end

function astronvim.status.provider.treesitter_status(opts)
  return function()
    local ts_avail, ts = pcall(require, "nvim-treesitter.parsers")
    return astronvim.status.utils.stylize((ts_avail and ts.has_parser()) and "TS" or "", opts)
  end
end

function astronvim.status.provider.str(opts)
  opts = astronvim.default_tbl(opts, { str = " " })
  return astronvim.status.utils.stylize(opts.str, opts)
end

function astronvim.status.condition.git_available() return vim.b.gitsigns_head ~= nil end

function astronvim.status.condition.git_changed()
  local git_status = vim.b.gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

function astronvim.status.condition.has_filetype()
  return vim.fn.empty(vim.fn.expand "%:t") ~= 1 and vim.bo.filetype and vim.bo.filetype ~= ""
end

function astronvim.status.condition.aerial_available() return astronvim.is_available "aerial.nvim" end

function astronvim.status.condition.treesitter_available()
  local ts_avail, ts = pcall(require, "nvim-treesitter.parsers")
  return ts_avail and ts.has_parser()
end

function astronvim.status.utils.stylize(str, opts)
  opts = astronvim.default_tbl(opts, {
    padding = { left = 0, right = 0 },
    separator = { left = "", right = "" },
    icon = { kind = "NONE", padding = { left = 0, right = 0 } },
  })
  local icon = astronvim.pad_string(astronvim.get_icon(opts.icon.kind), opts.icon.padding)
  return str
      and str ~= ""
      and opts.separator.left .. astronvim.pad_string(icon .. str, opts.padding) .. opts.separator.right
    or ""
end

function astronvim.status.utils.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

return astronvim.status
