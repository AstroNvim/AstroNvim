local mason_lspconfig = require "mason-lspconfig"
mason_lspconfig.setup(astronvim.user_plugin_opts "plugins.mason-lspconfig")
mason_lspconfig.setup_handlers(
  astronvim.user_plugin_opts("mason-lspconfig.setup_handlers", { function(server) astronvim.lsp.setup(server) end })
)
astronvim.event "LspSetup"
