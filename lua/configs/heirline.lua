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

local bar_components = astronvim.user_plugin_opts("heirline.components", {
  statusline = {
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
  winbar = {
    active = { astronvim.status.components.breadcrumbs },
    inactive = { astronvim.status.components.filename },
  },
}, false)

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  bar_components.statusline and vim.tbl_deep_extend(
    "force",
    bar_components.statusline,
    { hl = { fg = "fg", bg = "bg" } }
  ) or nil,
  bar_components.winbar and {
    init = utils.pick_child_on_condition,
    vim.tbl_deep_extend(
      "force",
      bar_components.winbar.active,
      { condition = conditions.is_active, hl = { fg = "winbar_fg", bg = "winbar_bg" } }
    ),
    vim.tbl_deep_extend("force", bar_components.winbar.inactive, { hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" } }),
  } or nil,
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
