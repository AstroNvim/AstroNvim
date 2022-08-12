local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then return end
local sign_define = vim.fn.sign_define
local user_plugin_opts = astronvim.user_plugin_opts

local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}
for _, sign in ipairs(signs) do
  sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end
vim.diagnostic.config(user_plugin_opts("diagnostics", {
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
}))
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

require "configs.lsp.handlers"
require "configs.mason-lspconfig"

for _, server in ipairs(user_plugin_opts "lsp.servers") do
  astronvim.lsp.setup(server)
end
