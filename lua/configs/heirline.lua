local status_ok, heirline = pcall(require, "heirline")
if not status_ok or not astronvim.status then return end
local C = require "default_theme.colors"
local utils = require "heirline.utils"
local conditions = require "heirline.conditions"

local function setup_colors()
  local statusline = astronvim.get_hlgroup("StatusLine", { fg = C.fg, bg = C.grey_4 })
  local winbar = astronvim.get_hlgroup("WinBar", { fg = C.grey_2, bg = C.bg })
  local winbarnc = astronvim.get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
  local conditional = astronvim.get_hlgroup("Conditional", { fg = C.purple_1, bg = C.grey_4 })
  local string = astronvim.get_hlgroup("String", { fg = C.green, bg = C.grey_4 })
  local typedef = astronvim.get_hlgroup("TypeDef", { fg = C.yellow, bg = C.grey_4 })
  local heirlinenormal = astronvim.get_hlgroup("HerlineNormal", { fg = C.blue, bg = C.grey_4 })
  local heirlineinsert = astronvim.get_hlgroup("HeirlineInsert", { fg = C.green, bg = C.grey_4 })
  local heirlinevisual = astronvim.get_hlgroup("HeirlineVisual", { fg = C.purple, bg = C.grey_4 })
  local heirlinereplace = astronvim.get_hlgroup("HeirlineReplace", { fg = C.red_1, bg = C.grey_4 })
  local heirlinecommand = astronvim.get_hlgroup("HeirlineCommand", { fg = C.yellow_1, bg = C.grey_4 })
  local heirlineinactive = astronvim.get_hlgroup("HeirlineInactive", { fg = C.grey_7, bg = C.grey_4 })
  local gitsignsadd = astronvim.get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.grey_4 })
  local gitsignschange = astronvim.get_hlgroup("GitSignsChange", { fg = C.orange_1, bg = C.grey_4 })
  local gitsignsdelete = astronvim.get_hlgroup("GitSignsDelete", { fg = C.red_1, bg = C.grey_4 })
  local diagnosticerror = astronvim.get_hlgroup("DiagnosticError", { fg = C.red_1, bg = C.grey_4 })
  local diagnosticwarn = astronvim.get_hlgroup("DiagnosticWarn", { fg = C.orange_1, bg = C.grey_4 })
  local diagnosticinfo = astronvim.get_hlgroup("DiagnosticInfo", { fg = C.white_2, bg = C.grey_4 })
  local diagnostichint = astronvim.get_hlgroup("DiagnosticHint", { fg = C.yellow_1, bg = C.grey_4 })
  local colors = astronvim.user_plugin_opts("heirline.colors", {
    fg = statusline.fg,
    bg = statusline.bg,
    section_fg = statusline.fg,
    section_bg = statusline.bg,
    branch_fg = conditional.fg,
    ts_fg = string.fg,
    scrollbar = typedef.fg,
    git_add = gitsignsadd.fg,
    git_change = gitsignschange.fg,
    git_del = gitsignsdelete.fg,
    diag_error = diagnosticerror.fg,
    diag_warn = diagnosticwarn.fg,
    diag_info = diagnosticinfo.fg,
    diag_hint = diagnostichint.fg,
    normal = astronvim.status.hl.lualine_mode("normal", heirlinenormal.fg),
    insert = astronvim.status.hl.lualine_mode("insert", heirlineinsert.fg),
    visual = astronvim.status.hl.lualine_mode("visual", heirlinevisual.fg),
    replace = astronvim.status.hl.lualine_mode("replace", heirlinereplace.fg),
    command = astronvim.status.hl.lualine_mode("command", heirlinecommand.fg),
    inactive = heirlineinactive.fg,
    winbar_fg = winbar.fg,
    winbar_bg = winbar.bg,
    winbarnc_fg = winbarnc.fg,
    winbarnc_bg = winbarnc.bg,
  })

  for _, section in ipairs { "branch", "file", "git", "diagnostic", "lsp", "ts", "nav" } do
    if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
    if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
  end
  return colors
end

-- define Heirline components
astronvim.status.components.left_mode = utils.surround(
  { "", astronvim.status.separators.left[2] },
  astronvim.status.hl.mode_bg,
  { provider = astronvim.status.provider.str { str = " " } }
)

astronvim.status.components.right_mode = utils.surround(
  { astronvim.status.separators.right[1], "" },
  astronvim.status.hl.mode_bg,
  { provider = astronvim.status.provider.str { str = " " } }
)

astronvim.status.components.fill = { provider = astronvim.status.provider.fill() }

astronvim.status.components.nav = {
  hl = { fg = "nav_fg" },
  utils.surround(astronvim.status.separators.right, "nav_bg", astronvim.status.components.nav()),
}

astronvim.status.components.filename = astronvim.status.components.file_info {
  file_icon = { highlight = false, padding = { left = 1 } },
  padding = { left = 1 },
}

astronvim.status.components.filename_filetype = {
  condition = astronvim.status.condition.has_filetype,
  hl = { fg = "file_fg" },
  utils.surround(
    astronvim.status.separators.left,
    "file_bg",
    astronvim.status.components.file_info(astronvim.is_available "bufferline.nvim" and {
      file_icon = { padding = { left = 1 } },
      filetype = {},
      filename = false,
      file_modified = false,
    } or { file_icon = { padding = { left = 1 } } })
  ),
}

astronvim.status.components.git_branch = {
  condition = conditions.is_git_repo,
  hl = { fg = "branch_fg" },
  utils.surround(astronvim.status.separators.left, "branch_bg", {
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
  }),
}

astronvim.status.components.git_diff = {
  condition = astronvim.status.condition.git_changed,
  hl = { fg = "git_fg" },
  utils.surround(
    astronvim.status.separators.left,
    "git_bg",
    astronvim.status.components.builder {
      {
        provider = "git_diff",
        opts = { type = "added", icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
        hl = { fg = "git_add" },
      },
      {
        provider = "git_diff",
        opts = { type = "changed", icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
        hl = { fg = "git_change" },
      },
      {
        provider = "git_diff",
        opts = { type = "removed", icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
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
    }
  ),
}

astronvim.status.components.diagnostics = {
  condition = conditions.has_diagnostics,
  hl = { fg = "diagnostic_fg" },
  utils.surround(astronvim.status.separators.left, "diagnostic_bg", {
    astronvim.status.components.builder {
      {
        provider = "diagnostics",
        opts = { severity = "ERROR", icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_error" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "WARN", icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_warn" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "INFO", icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_info" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "HINT", icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
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
      provider = astronvim.status.provider.lsp_client_names {
        icon = { kind = "ActiveLSP", padding = { right = 2 } },
      },
    }, {
      provider = astronvim.status.provider.str { str = "LSP", icon = { kind = "ActiveLSP", padding = { right = 2 } } },
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
  init = astronvim.status.init.breadcrumbs { padding = { left = 1 } },
  condition = astronvim.status.condition.aerial_available,
}

astronvim.status.components.treesitter = {
  condition = astronvim.status.condition.treesitter_available,
  hl = { fg = "ts_fg" },
  utils.surround(astronvim.status.separators.right, "ts_bg", {
    provider = astronvim.status.provider.str { str = "TS", icon = { kind = "ActiveTS" } },
  }),
}

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  {
    hl = { fg = "fg", bg = "bg" },
    astronvim.status.components.left_mode,
    astronvim.status.components.git_branch,
    astronvim.status.components.filename_filetype,
    astronvim.status.components.git_diff,
    astronvim.status.components.diagnostics,
    astronvim.status.components.fill,
    astronvim.status.components.lsp,
    astronvim.status.components.treesitter,
    astronvim.status.components.nav,
    astronvim.status.components.right_mode,
  },
  {
    init = utils.pick_child_on_condition,
    {
      condition = function() return conditions.buffer_matches { buftype = { "terminal" } } end,
      init = function() vim.opt_local.winbar = nil end,
    },
    { condition = conditions.is_active, astronvim.status.components.breadcrumbs },
    { astronvim.status.components.filename },
  },
})
heirline.setup(heirline_opts[1], heirline_opts[2])

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = "Heirline",
  desc = "Refresh heirline colors",
  callback = function()
    heirline.reset_highlights()
    heirline.load_colors(setup_colors())
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "HeirlineInitWinbar",
  group = "Heirline",
  desc = "Disable winbar for some windows",
  callback = function(args)
    local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo[args.buf].buftype)
    local filetype =
      vim.tbl_contains({ "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" }, vim.bo[args.buf].filetype)
    if buftype or filetype then vim.opt_local.winbar = nil end
  end,
})
