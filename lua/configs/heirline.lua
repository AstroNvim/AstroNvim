local heirline = require "heirline"
if not astronvim.status then return end
local C = require "default_theme.colors"

local function setup_colors()
  local StatusLine = astronvim.get_hlgroup("StatusLine", { fg = C.fg, bg = C.grey_4 })
  local WinBar = astronvim.get_hlgroup("WinBar", { fg = C.grey_2, bg = C.bg })
  local WinBarNC = astronvim.get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
  local Conditional = astronvim.get_hlgroup("Conditional", { fg = C.purple_1, bg = C.grey_4 })
  local String = astronvim.get_hlgroup("String", { fg = C.green, bg = C.grey_4 })
  local TypeDef = astronvim.get_hlgroup("TypeDef", { fg = C.yellow, bg = C.grey_4 })
  local HeirlineNormal = astronvim.get_hlgroup("HerlineNormal", { fg = C.blue, bg = C.grey_4 })
  local HeirlineInsert = astronvim.get_hlgroup("HeirlineInsert", { fg = C.green, bg = C.grey_4 })
  local HeirlineVisual = astronvim.get_hlgroup("HeirlineVisual", { fg = C.purple, bg = C.grey_4 })
  local HeirlineReplace = astronvim.get_hlgroup("HeirlineReplace", { fg = C.red_1, bg = C.grey_4 })
  local HeirlineCommand = astronvim.get_hlgroup("HeirlineCommand", { fg = C.yellow_1, bg = C.grey_4 })
  local HeirlineInactive = astronvim.get_hlgroup("HeirlineInactive", { fg = C.grey_7, bg = C.grey_4 })
  local GitSignsAdd = astronvim.get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.grey_4 })
  local GitSignsChange = astronvim.get_hlgroup("GitSignsChange", { fg = C.orange_1, bg = C.grey_4 })
  local GitSignsDelete = astronvim.get_hlgroup("GitSignsDelete", { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticError = astronvim.get_hlgroup("DiagnosticError", { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticWarn = astronvim.get_hlgroup("DiagnosticWarn", { fg = C.orange_1, bg = C.grey_4 })
  local DiagnosticInfo = astronvim.get_hlgroup("DiagnosticInfo", { fg = C.white_2, bg = C.grey_4 })
  local DiagnosticHint = astronvim.get_hlgroup("DiagnosticHint", { fg = C.yellow_1, bg = C.grey_4 })
  local colors = astronvim.user_plugin_opts("heirline.colors", {
    fg = StatusLine.fg,
    bg = StatusLine.bg,
    section_fg = StatusLine.fg,
    section_bg = StatusLine.bg,
    git_branch_fg = Conditional.fg,
    treesitter_fg = String.fg,
    scrollbar = TypeDef.fg,
    git_added = GitSignsAdd.fg,
    git_changed = GitSignsChange.fg,
    git_removed = GitSignsDelete.fg,
    diag_ERROR = DiagnosticError.fg,
    diag_WARN = DiagnosticWarn.fg,
    diag_INFO = DiagnosticInfo.fg,
    diag_HINT = DiagnosticHint.fg,
    normal = astronvim.status.hl.lualine_mode("normal", HeirlineNormal.fg),
    insert = astronvim.status.hl.lualine_mode("insert", HeirlineInsert.fg),
    visual = astronvim.status.hl.lualine_mode("visual", HeirlineVisual.fg),
    replace = astronvim.status.hl.lualine_mode("replace", HeirlineReplace.fg),
    command = astronvim.status.hl.lualine_mode("command", HeirlineCommand.fg),
    inactive = HeirlineInactive.fg,
    winbar_fg = WinBar.fg,
    winbar_bg = WinBar.bg,
    winbarnc_fg = WinBarNC.fg,
    winbarnc_bg = WinBarNC.bg,
  })

  for _, section in ipairs {
    "git_branch",
    "file_info",
    "git_diff",
    "diagnostics",
    "lsp",
    "macro_recording",
    "cmd_info",
    "treesitter",
    "nav",
  } do
    if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
    if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
  end
  return colors
end

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  {
    hl = { fg = "fg", bg = "bg" },
    astronvim.status.component.mode(),
    astronvim.status.component.git_branch(),
    astronvim.status.component.file_info(
      astronvim.is_available "bufferline.nvim" and { filetype = {}, filename = false, file_modified = false } or nil
    ),
    astronvim.status.component.git_diff(),
    astronvim.status.component.diagnostics(),
    astronvim.status.component.fill(),
    astronvim.status.component.cmd_info(),
    astronvim.status.component.fill(),
    astronvim.status.component.lsp(),
    astronvim.status.component.treesitter(),
    astronvim.status.component.nav(),
    astronvim.status.component.mode { surround = { separator = "right" } },
  },
  {
    fallthrough = false,
    {
      condition = function()
        return astronvim.status.condition.buffer_matches {
          buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
          filetype = { "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" },
        }
      end,
      init = function() vim.opt_local.winbar = nil end,
    },
    {
      condition = astronvim.status.condition.is_active,
      astronvim.status.component.breadcrumbs { hl = { fg = "winbar_fg", bg = "winbar_bg" } },
    },
    astronvim.status.component.file_info {
      unique_path = {},
      file_icon = { hl = false },
      hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" },
      surround = false,
    },
  },
})
heirline.setup(heirline_opts[1], heirline_opts[2], heirline_opts[3])

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "AstroColorScheme",
  group = "Heirline",
  desc = "Refresh heirline colors",
  callback = function() require("heirline.utils").on_colorscheme(setup_colors()) end,
})
