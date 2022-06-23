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
          { provider = provider.git_branch(" "), hl = hl.fg("Conditional", { fg = C.purple_1, style = "bold" })},
          { provider = provider.spacer(3), enabled = conditional.git_available },
          { provider = provider.fileicon(), enabled = conditional.has_filetype, hl = hl.filetype_color },
          { provider = provider.filetype(" "), enabled = conditional.has_filetype },
          { provider = provider.spacer(2), enabled = conditional.has_filetype },
          { provider = provider.git_diff("added", "  " ), hl = hl.fg("GitSignsAdd", { fg = C.green }) },
          { provider = provider.git_diff("changed", "  "), hl = hl.fg("GitSignsChange", { fg = C.orange_1 }) },
          { provider = provider.git_diff("removed", "  "), hl = hl.fg("GitSignsDelete", { fg = C.red_1 }) },
          { provider = provider.spacer(2), enabled = conditional.git_changed },
          { provider = provider.diagnostics(vim.diagnostic.severity.ERROR, "  "), hl = hl.fg("DiagnosticError", { fg = C.red_1 }) },
          { provider = provider.diagnostics(vim.diagnostic.severity.WARN, "  "), hl = hl.fg("DiagnosticWarn", { fg = C.orange_1 }) },
          { provider = provider.diagnostics(vim.diagnostic.severity.INFO, "  "), hl = hl.fg("DiagnosticInfo", { fg = C.white_2 }) },
          { provider = provider.diagnostics(vim.diagnostic.severity.HINT, "  "), hl = hl.fg("DiagnosticHint", { fg = C.yellow_1 }) },
        },
        {
          { provider = provider.lsp_progress(), enabled = conditional.bar_width() },
          { provider = provider.lsp_client_names(true, "   "), short_provider = provider.lsp_client_names(), enabled = conditional.bar_width() },
          { provider = provider.treesitter_status("  綠"), enabled = conditional.bar_width(), hl = hl.fg("GitSignsAdd", { fg = C.green }) },
          { provider = provider.ruler(0, 0, "  ") },
          { provider = provider.percentage("  ") },
          { provider = provider.scrollbar(" "), hl = hl.fg("TypeDef", { fg = C.yellow }) },
          { provider = provider.spacer(2) },
          { provider = provider.spacer(), hl = hl.mode() },
        },
      },
    },
  }))
end
