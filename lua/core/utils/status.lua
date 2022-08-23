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

--- Get the highlight background color of the lualine theme for the current colorscheme
-- @param  mode the neovim mode to get the color of
-- @param  fallback the color to fallback on if a lualine theme is not present
-- @return The background color of the lualine theme or the fallback parameter if one doesn't exist
function astronvim.status.hl.lualine_mode(mode, fallback)
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. (vim.g.colors_name or "default_theme"))
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
-- @return the highlight group for the current mode
-- @usage local heirline_component = { provider = "Example Provider", hl = astronvim.status.hl.mode },
function astronvim.status.hl.mode() return { bg = astronvim.status.hl.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
-- @return the highlight group for the current mode foreground
-- @usage local heirline_component = require("heirline.utils").surround({ "|", "|" }, astronvim.status.hl.mode_bg, heirline_component),
function astronvim.status.hl.mode_bg() return astronvim.status.env.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
-- @return the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = astronvim.status.provider.fileicon(), hl = astronvim.status.hl.filetype_color },
function astronvim.status.hl.filetype_color()
  local _, color = require("nvim-web-devicons").get_icon_color(vim.fn.expand "%:t", nil, { default = true })
  return { fg = color }
end

--- An `init` function to build a set of children components for LSP breadcrumbs
-- @param opts options for configuring the breadcrumbs (default: `{ separator = " > ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
-- @usage local heirline_component = { init = astronvim.status.init.breadcrumbs { padding = { left = 1 } }
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

--- A provider function for the fill string
-- @return the statusline string for filling the empty space
-- @usage local heirline_component = { provider = astronvim.status.provider.fill }
function astronvim.status.provider.fill() return "%=" end

--- A provider function for showing the percentage of the current location in a document
-- @param opts options passed to the stylize function
-- @return the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = astronvim.status.provider.percentage() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.percentage(opts) return astronvim.status.utils.stylize("%p%%", opts) end

--- A provider function for showing the current line and character in a document
-- @param opts options for padding the line and character locations and options passed to the stylize function
-- @return the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = astronvim.status.provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.ruler(opts)
  opts = astronvim.default_tbl(opts, { pad_ruler = { line = 0, char = 0 } })
  return astronvim.status.utils.stylize(string.format("%%%dl:%%%dc", opts.pad_ruler.line, opts.pad_ruler.char), opts)
end

--- A provider function for showing the current location as a scrollbar
-- @param opts options passed to the stylize function
-- @return the function for outputting the scrollbar
-- @usage local heirline_component = { provider = astronvim.status.provider.scrollbar() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    return astronvim.status.utils.stylize(string.rep(sbar[i], 2), opts)
  end
end

--- A provider function for showing the current filetype
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype
-- @usage local heirline_component = { provider = astronvim.status.provider.filetype() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.filetype(opts)
  return function() return astronvim.status.utils.stylize(string.lower(vim.bo.filetype), opts) end
end

--- A provider function for showing the current filename
-- @param opts options for argument to fnamemodify to format filename and options passed to the stylize function
-- @return the function for outputting the filename
-- @usage local heirline_component = { provider = astronvim.status.provider.filename() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.filename(opts)
  opts = astronvim.default_tbl(opts, { modify = ":t" })
  return function()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), opts.modify)
    return astronvim.status.utils.stylize(filename == "" and "[No Name]" or filename, opts)
  end
end

--- A provider function for showing the current filetype icon
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype icon
-- @usage local heirline_component = { provider = astronvim.status.provider.fileicon() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.fileicon(opts)
  return function()
    local ft_icon, _ = require("nvim-web-devicons").get_icon(vim.fn.expand "%:t", nil, { default = true })
    return astronvim.status.utils.stylize(ft_icon, opts)
  end
end

--- A provider function for showing the current git branch
-- @param opts options passed to the stylize function
-- @return the function for outputting the git branch
-- @usage local heirline_component = { provider = astronvim.status.provider.git_branch() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.git_branch(opts)
  return function() return astronvim.status.utils.stylize(vim.b.gitsigns_head or "", opts) end
end

--- A provider function for showing the current git diff count of a specific type
-- @param opts options for type of git diff and options passed to the stylize function
-- @return the function for outputting the git diff
-- @usage local heirline_component = { provider = astronvim.status.provider.git_diff({ type = "added" }) }
-- @see astronvim.status.utils.stylize
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

--- A provider function for showing the current diagnostic count of a specific severity
-- @param opts options for severity of diagnostic and options passed to the stylize function
-- @return the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = astronvim.status.provider.diagnostics({ severity = "ERROR" }) }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function()
    local count = #vim.diagnostic.get(0, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    return astronvim.status.utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

--- A provider function for showing the current progress of loading language servers
-- @param opts options passed to the stylize function
-- @return the function for outputting the LSP progress
-- @usage local heirline_component = { provider = astronvim.status.provider.lsp_progress() }
-- @see astronvim.status.utils.stylize
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

--- A provider function for showing the connected LSP client names
-- @param opts options for explanding null_ls clients, max width percentage, and options passed to the stylize function
-- @return the function for outputting the LSP client names
-- @usage local heirline_component = { provider = astronvim.status.provider.lsp_client_names({ expand_null_ls = true, truncate = 0.25 }) }
-- @see astronvim.status.utils.stylize
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

--- A provider function for showing if treesitter is connected
-- @param opts options passed to the stylize function
-- @return the function for outputting TS if treesitter is connected
-- @usage local heirline_component = { provider = astronvim.status.provider.treesitter_status() }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.treesitter_status(opts)
  return function()
    local ts_avail, ts = pcall(require, "nvim-treesitter.parsers")
    return astronvim.status.utils.stylize((ts_avail and ts.has_parser()) and "TS" or "", opts)
  end
end

--- A provider function for displaying a single string
-- @param opts options passed to the stylize function
-- @return the stylized statusline string
-- @usage local heirline_component = { provider = astronvim.status.provider.str({ str = "Hello" }) }
-- @see astronvim.status.utils.stylize
function astronvim.status.provider.str(opts)
  opts = astronvim.default_tbl(opts, { str = " " })
  return astronvim.status.utils.stylize(opts.str, opts)
end

--- A condition function if there are any git changes
-- @return boolean of wether or not there are any git changes
-- @usage local heirline_component = { provider = "Example Provider", condition = astronvim.status.condition.git_changed }
function astronvim.status.condition.git_changed()
  local git_status = vim.b.gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

--- A condition function if there is a defined filetype
-- @return boolean of wether or not there is a filetype
-- @usage local heirline_component = { provider = "Example Provider", condition = astronvim.status.condition.has_filetype }
function astronvim.status.condition.has_filetype()
  return vim.fn.empty(vim.fn.expand "%:t") ~= 1 and vim.bo.filetype and vim.bo.filetype ~= ""
end

--- A condition function if Aerial is available
-- @return boolean of wether or not aerial plugin is installed
-- @usage local heirline_component = { provider = "Example Provider", condition = astronvim.status.condition.aerial_available }
function astronvim.status.condition.aerial_available() return astronvim.is_available "aerial.nvim" end

--- A condition function if treesitter is in use
-- @return boolean of wether or not treesitter is active
-- @usage local heirline_component = { provider = "Example Provider", condition = astronvim.status.condition.treesitter_available }
function astronvim.status.condition.treesitter_available()
  local ts_avail, ts = pcall(require, "nvim-treesitter.parsers")
  return ts_avail and ts.has_parser()
end

--- A utility function to stylize a string with an icon from lspkind, separators, and left/right padding
-- @param str the string to stylize
-- @param opts options of `{ padding = { left = 0, right = 0 }, separator = { left = "|", right = "|" }, icon = { kind = "NONE", padding = { left = 0, right = 0 } } }`
-- @return the stylized string
-- @usage local string = astronvim.status.utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })
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

--- A utility function to get the width of the bar
-- @param is_winbar boolean true if you want the width of the winbar, false if you want the statusline width
-- @return the width of the specified bar
function astronvim.status.utils.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

return astronvim.status
