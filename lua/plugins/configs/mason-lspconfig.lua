return function(_, opts)
  local mason_lspconfig = require "mason-lspconfig"
  mason_lspconfig.setup(opts)
  mason_lspconfig.setup_handlers { function(server) require("core.utils.lsp").setup(server) end }
  require("core.utils").event "LspSetup"
end
