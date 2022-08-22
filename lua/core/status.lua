astronvim.status = { hl = {}, init = {}, provider = {}, condition = {}, components = {}, utils = {}, env = {} }

astronvim.status.env.heirline_filename = not astronvim.is_available "bufferline.nvim"
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

function astronvim.status.hl.lualine_mode(mode, fallback)
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. (vim.g.colors_name or "default_theme"))
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

function astronvim.status.hl.mode() return { fg = astronvim.status.hl.mode_fg() } end

function astronvim.status.hl.mode_fg() return astronvim.status.env.modes[vim.fn.mode()][2] end

function astronvim.status.hl.filetype_color()
  local _, color = require("nvim-web-devicons").get_icon_color(vim.fn.expand "%:t", nil, { default = true })
  return { fg = color }
end

function astronvim.status.init.breadcrumbs(separator, opts)
  separator = separator or " > "
  local aerial_avail, aerial = pcall(require, "aerial")
  opts = vim.tbl_deep_extend(
    "force",
    { icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } },
    opts or {}
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
      if #data > 1 and i < #data then table.insert(child, { provider = separator }) end -- add a separator only if needed
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

function astronvim.status.provider.ruler(line_padding, char_padding, opts)
  return astronvim.status.utils.stylize(string.format("%%%dl:%%%dc", line_padding or 0, char_padding or 0), opts)
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

function astronvim.status.provider.filename(modify, opts)
  return function()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), modify or ":t")
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

function astronvim.status.provider.git_diff(type, opts)
  return function()
    local status = vim.b.gitsigns_status_dict
    return astronvim.status.utils.stylize(
      status and status[type] and status[type] > 0 and tostring(status[type]) or "",
      opts
    )
  end
end

function astronvim.status.provider.diagnostics(severity, opts)
  return function()
    local count = #vim.diagnostic.get(0, severity and { severity = vim.diagnostic.severity[severity] })
    return astronvim.status.utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

function astronvim.status.provider.breadcrumbs(depth, separator, icons, opts)
  return function()
    local aerial_avail, aerial = pcall(require, "aerial")
    return astronvim.status.utils.stylize(
      aerial_avail and astronvim.format_symbols(aerial.get_location(true), depth, separator or " > ", icons) or "",
      opts
    )
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

function astronvim.status.provider.lsp_client_names(expand_null_ls, trunc, opts)
  return function()
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.buf_get_clients(0)) do
      if client.name == "null-ls" and expand_null_ls then
        vim.list_extend(buf_client_names, astronvim.null_ls_sources(vim.bo.filetype, "FORMATTING"))
        vim.list_extend(buf_client_names, astronvim.null_ls_sources(vim.bo.filetype, "DIAGNOSTICS"))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    local str = table.concat(buf_client_names, ", ")
    if type(trunc) == "number" then
      local max_width = math.floor(astronvim.status.utils.width() * trunc)
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

function astronvim.status.provider.str(str, opts) return astronvim.status.utils.stylize(str or " ", opts) end

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
  opts = vim.tbl_deep_extend("force", {
    padding = {
      left = 0,
      right = 0,
    },
    separator = {
      left = "",
      right = "",
    },
    icon = "",
  }, opts or {})
  if type(opts.icon) == "table" then
    opts.icon = astronvim.pad_string(astronvim.get_icon(opts.icon.kind), opts.icon.padding)
  end
  return str
      and str ~= ""
      and opts.separator.left .. astronvim.pad_string(opts.icon .. str, opts.padding) .. opts.separator.right
    or ""
end

function astronvim.status.utils.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

local heirline_available, _ = pcall(require, "heirline")
if heirline_available then
  local utils = require "heirline.utils"
  local conditions = require "heirline.conditions"

  astronvim.status.components.left_mode = utils.surround(
    { "", astronvim.status.separators.left[2] },
    astronvim.status.hl.mode_fg,
    { provider = astronvim.status.provider.str " " }
  )

  astronvim.status.components.right_mode = utils.surround(
    { astronvim.status.separators.right[1], "" },
    astronvim.status.hl.mode_fg,
    { provider = astronvim.status.provider.str " " }
  )

  astronvim.status.components.fill = { provider = astronvim.status.provider.fill() }

  astronvim.status.components.nav = {
    hl = { fg = "nav_fg" },
    utils.surround(astronvim.status.separators.right, "nav_bg", {
      { provider = astronvim.status.provider.ruler(0, 0) },
      { provider = astronvim.status.provider.percentage { padding = { left = 1 } } },
      { provider = astronvim.status.provider.scrollbar { padding = { left = 1 } }, hl = { fg = "scrollbar" } },
    }),
  }

  astronvim.status.components.filename = {
    { provider = astronvim.status.provider.fileicon { padding = { left = 1, right = 1 } } },
    { provider = astronvim.status.provider.filename() },
  }

  astronvim.status.components.filename_filetype = {
    condition = astronvim.status.condition.has_filetype,
    hl = { fg = "file_fg" },
    utils.surround(astronvim.status.separators.left, "file_bg", {
      { provider = astronvim.status.provider.fileicon(), hl = astronvim.status.hl.filetype_color },
      {
        init = utils.pick_child_on_condition,
        { -- if filetype is toggled
          condition = function() return not astronvim.status.env.heirline_filename end,
          { provider = astronvim.status.provider.filetype { padding = { left = 1 } } },
        },
        { -- if filename is toggled
          { provider = astronvim.status.provider.filename(nil, { padding = { left = 1 } }) },
        },
      },
      on_click = {
        name = "heirline_filename",
        callback = function() astronvim.status.env.heirline_filename = not astronvim.status.env.heirline_filename end,
      },
    }),
  }

  astronvim.status.components.git_branch = {
    condition = conditions.is_git_repo,
    hl = { fg = "branch_fg" },
    utils.surround(astronvim.status.separators.left, "branch_bg", {
      {
        provider = astronvim.status.provider.git_branch { icon = { kind = "GitBranch", padding = { right = 1 } } },
        hl = { bold = true },
        on_click = {
          name = "heirline_branch",
          callback = function()
            if astronvim.is_available "telescope.nvim" then
              vim.defer_fn(function() require("telescope.builtin").git_branches() end, 100)
            end
          end,
        },
      },
    }),
  }

  astronvim.status.components.git_diff = {
    condition = astronvim.status.condition.git_changed,
    hl = { fg = "git_fg" },
    utils.surround(astronvim.status.separators.left, "git_bg", {
      {
        provider = astronvim.status.provider.git_diff(
          "added",
          { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "git_add" },
      },
      {
        provider = astronvim.status.provider.git_diff(
          "changed",
          { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "git_change" },
      },
      {
        provider = astronvim.status.provider.git_diff(
          "removed",
          { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "git_del" },
      },
      on_click = {
        name = "heirline_git",
        callback = function()
          if astronvim.is_available "telescope.nvim" then
            vim.defer_fn(function() require("telescope.builtin").git_status() end, 100)
          end
        end,
      },
    }),
  }

  astronvim.status.components.diagnostics = {
    condition = conditions.has_diagnostics,
    hl = { fg = "diagnostic_fg" },
    utils.surround(astronvim.status.separators.left, "diagnostic_bg", {
      {
        provider = astronvim.status.provider.diagnostics(
          "ERROR",
          { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "diag_error" },
      },
      {
        provider = astronvim.status.provider.diagnostics(
          "WARN",
          { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "diag_warn" },
      },
      {
        provider = astronvim.status.provider.diagnostics(
          "INFO",
          { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "diag_info" },
      },
      {
        provider = astronvim.status.provider.diagnostics(
          "HINT",
          { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } }
        ),
        hl = { fg = "diag_hint" },
      },
      on_click = {
        name = "heirline_diagnostic",
        callback = function()
          if astronvim.is_available "telescope.nvim" then
            vim.defer_fn(function() require("telescope.builtin").diagnostics() end, 100)
          end
        end,
      },
    }),
  }

  astronvim.status.components.lsp = {
    condition = conditions.lsp_attached,
    hl = { fg = "lsp_fg" },
    utils.surround(astronvim.status.separators.right, "lsp_bg", {
      utils.make_flexible_component(
        1,
        { provider = astronvim.status.provider.lsp_progress { padding = { right = 1 } } },
        { provider = "" }
      ),
      utils.make_flexible_component(2, {
        provider = astronvim.status.provider.lsp_client_names(
          true,
          0.25,
          { icon = { kind = "ActiveLSP", padding = { right = 2 } } }
        ),
      }, {
        provider = astronvim.status.provider.str("LSP", { icon = { kind = "ActiveLSP", padding = { right = 2 } } }),
      }),
      on_click = {
        name = "heirline_lsp",
        callback = function()
          vim.defer_fn(function() vim.cmd "LspInfo" end, 100)
        end,
      },
    }),
  }

  astronvim.status.components.breadcrumbs = {
    init = astronvim.status.init.breadcrumbs(" > ", { padding = { left = 1 } }),
    condition = astronvim.status.condition.aerial_available,
  }

  astronvim.status.components.treesitter = {
    condition = astronvim.status.condition.treesitter_available,
    hl = { fg = "ts_fg" },
    utils.surround(astronvim.status.separators.right, "ts_bg", {
      { provider = astronvim.status.provider.str("TS", { icon = { kind = "ActiveTS" } }) },
    }),
  }
end

return astronvim.status
