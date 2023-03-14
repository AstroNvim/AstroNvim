return function(_, opts)
  local heirline = require "heirline"
  local status = require "astronvim.utils.status"
  local C = status.env.fallback_colors
  local get_hlgroup = require("astronvim.utils").get_hlgroup

  local function setup_colors()
    local Normal = get_hlgroup("Normal", { fg = C.fg, bg = C.bg })
    local Comment = get_hlgroup("Comment", { fg = C.bright_grey, bg = C.bg })
    local Error = get_hlgroup("Error", { fg = C.red, bg = C.bg })
    local StatusLine = get_hlgroup("StatusLine", { fg = C.fg, bg = C.dark_bg })
    local TabLine = get_hlgroup("TabLine", { fg = C.grey, bg = C.none })
    local TabLineSel = get_hlgroup("TabLineSel", { fg = C.fg, bg = C.none })
    local WinBar = get_hlgroup("WinBar", { fg = C.bright_grey, bg = C.bg })
    local WinBarNC = get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
    local Conditional = get_hlgroup("Conditional", { fg = C.bright_purple, bg = C.dark_bg })
    local String = get_hlgroup("String", { fg = C.green, bg = C.dark_bg })
    local TypeDef = get_hlgroup("TypeDef", { fg = C.yellow, bg = C.dark_bg })
    local GitSignsAdd = get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.dark_bg })
    local GitSignsChange = get_hlgroup("GitSignsChange", { fg = C.orange, bg = C.dark_bg })
    local GitSignsDelete = get_hlgroup("GitSignsDelete", { fg = C.bright_red, bg = C.dark_bg })
    local DiagnosticError = get_hlgroup("DiagnosticError", { fg = C.bright_red, bg = C.dark_bg })
    local DiagnosticWarn = get_hlgroup("DiagnosticWarn", { fg = C.orange, bg = C.dark_bg })
    local DiagnosticInfo = get_hlgroup("DiagnosticInfo", { fg = C.white, bg = C.dark_bg })
    local DiagnosticHint = get_hlgroup("DiagnosticHint", { fg = C.bright_yellow, bg = C.dark_bg })
    local HeirlineInactive = get_hlgroup("HeirlineInactive", { bg = nil }).bg
      or status.hl.lualine_mode("inactive", C.dark_grey)
    local HeirlineNormal = get_hlgroup("HeirlineNormal", { bg = nil }).bg or status.hl.lualine_mode("normal", C.blue)
    local HeirlineInsert = get_hlgroup("HeirlineInsert", { bg = nil }).bg or status.hl.lualine_mode("insert", C.green)
    local HeirlineVisual = get_hlgroup("HeirlineVisual", { bg = nil }).bg or status.hl.lualine_mode("visual", C.purple)
    local HeirlineReplace = get_hlgroup("HeirlineReplace", { bg = nil }).bg
      or status.hl.lualine_mode("replace", C.bright_red)
    local HeirlineCommand = get_hlgroup("HeirlineCommand", { bg = nil }).bg
      or status.hl.lualine_mode("command", C.bright_yellow)
    local HeirlineTerminal = get_hlgroup("HeirlineTerminal", { bg = nil }).bg
      or status.hl.lualine_mode("insert", HeirlineInsert)

    local colors = astronvim.user_opts("heirline.colors", {
      close_fg = Error.fg,
      fg = StatusLine.fg,
      bg = StatusLine.bg,
      section_fg = StatusLine.fg,
      section_bg = StatusLine.bg,
      git_branch_fg = Conditional.fg,
      mode_fg = StatusLine.bg,
      treesitter_fg = String.fg,
      scrollbar = TypeDef.fg,
      git_added = GitSignsAdd.fg,
      git_changed = GitSignsChange.fg,
      git_removed = GitSignsDelete.fg,
      diag_ERROR = DiagnosticError.fg,
      diag_WARN = DiagnosticWarn.fg,
      diag_INFO = DiagnosticInfo.fg,
      diag_HINT = DiagnosticHint.fg,
      winbar_fg = WinBar.fg,
      winbar_bg = WinBar.bg,
      winbarnc_fg = WinBarNC.fg,
      winbarnc_bg = WinBarNC.bg,
      tabline_bg = StatusLine.bg,
      tabline_fg = StatusLine.bg,
      buffer_fg = Comment.fg,
      buffer_path_fg = WinBarNC.fg,
      buffer_close_fg = Comment.fg,
      buffer_bg = StatusLine.bg,
      buffer_active_fg = Normal.fg,
      buffer_active_path_fg = WinBarNC.fg,
      buffer_active_close_fg = Error.fg,
      buffer_active_bg = Normal.bg,
      buffer_visible_fg = Normal.fg,
      buffer_visible_path_fg = WinBarNC.fg,
      buffer_visible_close_fg = Error.fg,
      buffer_visible_bg = Normal.bg,
      buffer_overflow_fg = Comment.fg,
      buffer_overflow_bg = StatusLine.bg,
      buffer_picker_fg = Error.fg,
      tab_close_fg = Error.fg,
      tab_close_bg = StatusLine.bg,
      tab_fg = TabLine.fg,
      tab_bg = TabLine.bg,
      tab_active_fg = TabLineSel.fg,
      tab_active_bg = TabLineSel.bg,
      inactive = HeirlineInactive,
      normal = HeirlineNormal,
      insert = HeirlineInsert,
      visual = HeirlineVisual,
      replace = HeirlineReplace,
      command = HeirlineCommand,
      terminal = HeirlineTerminal,
    })

    for _, section in ipairs {
      "git_branch",
      "file_info",
      "git_diff",
      "diagnostics",
      "lsp",
      "macro_recording",
      "mode",
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
  heirline.setup(opts)

  local augroup = vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AstroColorScheme",
    group = augroup,
    desc = "Refresh heirline colors",
    callback = function() require("heirline.utils").on_colorscheme(setup_colors()) end,
  })
end
