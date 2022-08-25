local status_ok, heirline = pcall(require, "heirline")
if not status_ok or not astronvim.status then return end
local C = require "default_theme.colors"

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
    git_added = gitsignsadd.fg,
    git_changed = gitsignschange.fg,
    git_removed = gitsignsdelete.fg,
    diag_ERROR = diagnosticerror.fg,
    diag_WARN = diagnosticwarn.fg,
    diag_INFO = diagnosticinfo.fg,
    diag_HINT = diagnostichint.fg,
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
    astronvim.status.component.lsp(),
    astronvim.status.component.treesitter(),
    astronvim.status.component.nav(),
    astronvim.status.component.mode { surround = { separator = "right" } },
  },
  {
    init = astronvim.status.init.pick_child_on_condition,
    {
      condition = function() return astronvim.status.condition.buffer_matches { buftype = { "terminal" } } end,
      init = function() vim.opt_local.winbar = nil end,
    },
    {
      condition = astronvim.status.condition.is_active,
      astronvim.status.component.breadcrumbs { hl = { fg = "winbar_fg", bg = "winbar_bg" } },
    },
    {
      astronvim.status.component.file_info {
        file_icon = { highlight = false },
        hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" },
        surround = false,
      },
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
