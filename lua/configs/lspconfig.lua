local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then return end

local signs = {
  { name = "DiagnosticSignError", text = astronvim.get_icon "DiagnosticError" },
  { name = "DiagnosticSignWarn", text = astronvim.get_icon "DiagnosticWarn" },
  { name = "DiagnosticSignHint", text = astronvim.get_icon "DiagnosticHint" },
  { name = "DiagnosticSignInfo", text = astronvim.get_icon "DiagnosticInfo" },
}
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end
astronvim.lsp.diagnostics = {
  off = {
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  },
  on = astronvim.user_plugin_opts("diagnostics", {
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
  }),
}
vim.diagnostic.config(astronvim.lsp.diagnostics[vim.g.diagnostics_enabled and "on" or "off"])
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
-- setup language servers once AstroNvim loads
vim.schedule(function() vim.tbl_map(astronvim.lsp.setup, astronvim.user_plugin_opts "lsp.servers") end)
