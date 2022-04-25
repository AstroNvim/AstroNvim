local status_ok, _ = pcall(require, "lspconfig")
if status_ok then
  require "configs.lsp.lsp-installer"
  local handlers = require "configs.lsp.handlers"
  handlers.setup()
  local lsp_setup = require("core.utils").user_plugin_opts "lsp.setup"
  if type(lsp_setup) == "function" then
    lsp_setup(handlers.on_attach, handlers.capabilities)
  end
end
