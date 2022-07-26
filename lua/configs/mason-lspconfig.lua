local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then return end
-- TODO: v2 deprecate nvim-lsp-installer
mason_lspconfig.setup(
  astronvim.user_plugin_opts("plugins.mason-lspconfig", astronvim.user_plugin_opts "plugins.nvim-lsp-installer")
)
