local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then return end
require "configs.lsp.handlers"
local insert = table.insert
local tbl_contains = vim.tbl_contains
local sign_define = vim.fn.sign_define
local user_plugin_opts = astronvim.user_plugin_opts
local user_registration = user_plugin_opts("lsp.server_registration", nil, false)

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
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}))
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

local servers = user_plugin_opts "lsp.servers"
local skip_setup = user_plugin_opts "lsp.skip_setup"
local installer_avail, lsp_installer = pcall(require, "nvim-lsp-installer")
if installer_avail then
  for _, server in ipairs(lsp_installer.get_installed_servers()) do
    insert(servers, server.name)
  end
end
for _, server in ipairs(servers) do
  if not tbl_contains(skip_setup, server) then
    local opts = astronvim.lsp.server_settings(server)
    if type(user_registration) == "function" then
      user_registration(server, opts)
    else
      lspconfig[server].setup(opts)
    end
  end
end
