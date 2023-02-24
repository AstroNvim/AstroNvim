local signs = {
  { name = "DiagnosticSignError", text = astronvim.get_icon "DiagnosticError" },
  { name = "DiagnosticSignWarn", text = astronvim.get_icon "DiagnosticWarn" },
  { name = "DiagnosticSignHint", text = astronvim.get_icon "DiagnosticHint" },
  { name = "DiagnosticSignInfo", text = astronvim.get_icon "DiagnosticInfo" },
  { name = "DiagnosticSignError", text = astronvim.get_icon "DiagnosticError" },
  { name = "DapStopped", text = astronvim.get_icon "DapStopped", texthl = "DiagnosticWarn" },
  { name = "DapBreakpoint", text = astronvim.get_icon "DapBreakpoint", texthl = "DiagnosticInfo" },
  { name = "DapBreakpointRejected", text = astronvim.get_icon "DapBreakpointRejected", texthl = "DiagnosticError" },
  { name = "DapBreakpointCondition", text = astronvim.get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
  { name = "DapLogPoint", text = astronvim.get_icon "DapLogPoint", texthl = "DiagnosticInfo" },
}

for _, sign in ipairs(signs) do
  if not sign.texthl then sign.texthl = sign.name end
  vim.fn.sign_define(sign.name, sign)
end

astronvim.lsp.diagnostics = {
  -- diagnostics off
  [0] = {
    -- status = "all diagnostics off",
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  },
  -- status only
  [1] = {
    -- status = "status diagnostics only",
    virtual_text = false,
    signs = false,
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  },
  -- virtual text off, signs on
  [2] = {
    -- status = "virtual text off",
    virtual_text = false,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  },
  -- all diagnostics on
  [3] = {
    -- status = "all diagnostics on",
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  },
}

vim.diagnostic.config(astronvim.lsp.diagnostics[vim.g.diagnostics_mode])
