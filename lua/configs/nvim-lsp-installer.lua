local M = {}

function M.config()
  local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
  if status_ok then
    lsp_installer.setup(require("core.utils").user_plugin_opts("plugins.nvim-lsp-installer", {}))
  end
end

return M
