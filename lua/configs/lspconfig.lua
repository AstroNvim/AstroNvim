if vim.g.lsp_handlers_enabled then
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
end
local setup_servers = function()
  vim.tbl_map(astronvim.lsp.setup, astronvim.user_plugin_opts "lsp.servers")
  vim.cmd "silent! do FileType"
end
if astronvim.is_available "mason-lspconfig.nvim" then
  vim.api.nvim_create_autocmd("User", { pattern = "AstroLspSetup", once = true, callback = setup_servers })
else
  setup_servers()
end
