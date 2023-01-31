return function(_, opts)
  local mason_lspconfig = require "mason-lspconfig"
  mason_lspconfig.setup(opts)
  mason_lspconfig.setup_handlers { function(server) astronvim.lsp.setup(server) end }
  astronvim.event "LspSetup"
end
