local status_ok, _ = pcall(require, "lspconfig")
if status_ok then
  require "configs.lsp.lsp-installer"
  require("configs.lsp.handlers").setup()
end
