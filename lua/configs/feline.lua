local status_ok, feline = pcall(require, "feline")
if status_ok then
  local C = require "default_theme.colors"
  local hl = require("core.status").hl
  local provider = require("core.status").provider
  local conditional = require("core.status").conditional
  -- stylua: ignore
  feline.setup(astronvim.user_plugin_opts("plugins.feline", {
    disable = { filetypes = { "^NvimTree$", "^neo%-tree$", "^dashboard$", "^Outline$", "^aerial$" } },
    theme = hl.group("StatusLine", { fg = C.fg, bg = C.bg_1 }),
    components = {
      active = {
        {
          { provider = provider.spacer(), hl = hl.mode() },
          { provider = provider.spacer(2) },
          { provider = "git_branch", hl = hl.fg("Conditional", { fg = C.purple_1, style = "bold" }), icon = " " },
          { provider = provider.spacer(3), enabled = conditional.git_available },
          { provider = { name = "file_type", opts = { filetype_icon = true, case = "lowercase" } }, enabled = conditional.has_filetype },
          { provider = provider.spacer(2), enabled = conditional.has_filetype },
          { provider = "git_diff_added", hl = hl.fg("GitSignsAdd", { fg = C.green }), icon = "  " },
          { provider = "git_diff_changed", hl = hl.fg("GitSignsChange", { fg = C.orange_1 }), icon = " 柳" },
          { provider = "git_diff_removed", hl = hl.fg("GitSignsDelete", { fg = C.red_1 }), icon = "  " },
          { provider = provider.spacer(2), enabled = conditional.git_changed },
          { provider = "diagnostic_errors", hl = hl.fg("DiagnosticError", { fg = C.red_1 }), icon = "  " },
          { provider = "diagnostic_warnings", hl = hl.fg("DiagnosticWarn", { fg = C.orange_1 }), icon = "  " },
          { provider = "diagnostic_info", hl = hl.fg("DiagnosticInfo", { fg = C.white_2 }), icon = "  " },
          { provider = "diagnostic_hints", hl = hl.fg("DiagnosticHint", { fg = C.yellow_1 }), icon = "  " },
        },
        {
          { provider = provider.lsp_progress, enabled = conditional.bar_width() },
          { provider = provider.lsp_client_names(true), short_provider = provider.lsp_client_names(), enabled = conditional.bar_width(), icon = "   " },
          { provider = provider.spacer(2), enabled = conditional.bar_width() },
          { provider = provider.treesitter_status, enabled = conditional.bar_width(), hl = hl.fg("GitSignsAdd", { fg = C.green }) },
          { provider = provider.spacer(2) },
          { provider = "position" },
          { provider = provider.spacer(2) },
          { provider = "line_percentage" },
          { provider = provider.spacer() },
          { provider = "scroll_bar", hl = hl.fg("TypeDef", { fg = C.yellow }) },
          { provider = provider.spacer(2) },
          { provider = provider.spacer(), hl = hl.mode() },
        },
      },
    },
  }))
end
