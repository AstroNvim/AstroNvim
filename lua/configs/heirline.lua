local status_ok, heirline = pcall(require, "heirline")
if not status_ok then return end
local C = require "default_theme.colors"
local utils = require "heirline.utils"
local conditions = require "heirline.conditions"
local st = require "core.status"

local function hl_default(hlgroup, prop, default)
  return vim.fn.hlexists(hlgroup) == 1 and utils.get_highlight(hlgroup)[prop] or default
end

local function setup_colors()
  local colors = astronvim.user_plugin_opts("heirline.colors", {
    fg = hl_default("StatusLine", "fg", C.fg),
    bg = hl_default("StatusLine", "bg", C.grey_4),
    section_bg = hl_default("StatusLine", "bg", C.grey_4),
    section_fg = hl_default("StatusLine", "fg", C.grey_4),
    branch_fg = hl_default("Conditional", "fg", C.purple_1),
    ts_fg = hl_default("String", "fg", C.green),
    scrollbar = hl_default("TypeDef", "fg", C.yellow),
    git_add = hl_default("GitSignsAdd", "fg", C.green),
    git_change = hl_default("GitSignsChange", "fg", C.orange_1),
    git_del = hl_default("GitSignsDelete", "fg", C.red_1),
    diag_error = hl_default("DiagnosticError", "fg", C.red_1),
    diag_warn = hl_default("DiagnosticWarn", "fg", C.orange_1),
    diag_info = hl_default("DiagnosticInfo", "fg", C.white_2),
    diag_hint = hl_default("DiagnosticHint", "fg", C.yellow_1),
    normal = st.hl.lualine_mode("normal", hl_default("HeirlineNormal", "fg", C.blue)),
    insert = st.hl.lualine_mode("insert", hl_default("HeirlineInsert", "fg", C.green)),
    visual = st.hl.lualine_mode("visual", hl_default("HeirlineVisual", "fg", C.purple)),
    replace = st.hl.lualine_mode("replace", hl_default("HeirlineReplace", "fg", C.red_1)),
    command = st.hl.lualine_mode("command", hl_default("HeirlineCommand", "fg", C.yellow_1)),
    inactive = hl_default("HeirlineInactive", "fg", C.grey_7),
    winbar_fg = hl_default("WinBar", "fg", C.grey_2),
    winbar_bg = hl_default("WinBar", "bg", C.bg),
    winbarnc_fg = hl_default("WinBarNC", "fg", C.grey),
    winbarnc_bg = hl_default("WinBarNC", "bg", C.bg),
  })

  for _, section in ipairs { "branch", "file", "git", "diagnostic", "lsp", "ts", "nav" } do
    if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
    if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
  end
  return colors
end

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  {
    hl = { fg = "fg", bg = "bg" },
    utils.surround({ "", st.separators.left[2] }, st.hl.mode_fg, { provider = st.provider.str " " }),
    {
      condition = conditions.is_git_repo,
      hl = { fg = "branch_fg" },
      utils.surround(st.separators.left, "branch_bg", {
        {
          provider = st.provider.git_branch { icon = { kind = "GitBranch", padding = { right = 1 } } },
          hl = { bold = true },
        },
      }),
    },
    {
      condition = st.condition.has_filetype,
      hl = { fg = "file_fg" },
      utils.surround(st.separators.left, "file_bg", {
        { provider = st.provider.fileicon(), hl = st.hl.filetype_color },
        { provider = st.provider.filetype { padding = { left = 1 } } },
      }),
    },
    {
      condition = st.condition.git_changed,
      hl = { fg = "git_fg" },
      utils.surround(st.separators.left, "git_bg", {
        {
          provider = st.provider.git_diff("added", { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } }),
          hl = { fg = "git_add" },
        },
        {
          provider = st.provider.git_diff(
            "changed",
            { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "git_change" },
        },
        {
          provider = st.provider.git_diff(
            "removed",
            { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "git_del" },
        },
      }),
    },
    {
      condition = conditions.has_diagnostics,
      hl = { fg = "diagnostic_fg" },
      utils.surround(st.separators.left, "diagnostic_bg", {
        {
          provider = st.provider.diagnostics(
            "ERROR",
            { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "diag_error" },
        },
        {
          provider = st.provider.diagnostics(
            "WARN",
            { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "diag_warn" },
        },
        {
          provider = st.provider.diagnostics(
            "INFO",
            { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "diag_info" },
        },
        {
          provider = st.provider.diagnostics(
            "HINT",
            { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } }
          ),
          hl = { fg = "diag_hint" },
        },
      }),
    },
    { provider = st.provider.fill() },
    {
      condition = conditions.lsp_attached,
      hl = { fg = "lsp_fg" },
      utils.surround(st.separators.right, "lsp_bg", {
        utils.make_flexible_component(
          1,
          { provider = st.provider.lsp_progress { padding = { right = 1 } } },
          { provider = "" }
        ),
        utils.make_flexible_component(2, {
          provider = st.provider.lsp_client_names(
            true,
            0.25,
            { icon = { kind = "ActiveLSP", padding = { right = 2 } } }
          ),
        }, { provider = st.provider.str("LSP", { icon = { kind = "ActiveLSP", padding = { right = 2 } } }) }),
      }),
    },
    {
      condition = st.condition.treesitter_available,
      hl = { fg = "ts_fg" },
      utils.surround(st.separators.right, "ts_bg", {
        { provider = st.provider.str("TS", { icon = { kind = "ActiveTS" } }) },
      }),
    },
    {
      hl = { fg = "nav_fg" },
      utils.surround(st.separators.right, "nav_bg", {
        { provider = st.provider.ruler(0, 0) },
        { provider = st.provider.percentage { padding = { left = 1 } } },
        { provider = st.provider.scrollbar { padding = { left = 1 } }, hl = { fg = "scrollbar" } },
      }),
    },
    utils.surround({ st.separators.right[1], "" }, st.hl.mode_fg, { provider = st.provider.str " " }),
  },
  {
    init = utils.pick_child_on_condition,
    { -- active winbar
      condition = conditions.is_active,
      hl = { fg = "winbar_fg", bg = "winbar_bg" },
      {
        provider = st.provider.breadcrumbs(nil, " > ", true, { padding = { left = 1 } }),
        condition = st.condition.aerial_available,
      },
    },
    { -- fallback if not active
      hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" },
      { provider = st.provider.fileicon { padding = { left = 1, right = 1 } } },
      { provider = st.provider.filename() },
    },
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
  group = "Heirline",
  desc = "Disable winbar for some windows",
  callback = function(args)
    local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo[args.buf].buftype)
    local filetype =
      vim.tbl_contains({ "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" }, vim.bo[args.buf].filetype)
    if buftype or filetype then vim.opt_local.winbar = nil end
  end,
})
