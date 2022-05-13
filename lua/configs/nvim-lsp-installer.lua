local M = {}

function M.config()
  local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
  if status_ok then
    lsp_installer.setup(astronvim.user_plugin_opts("plugins.nvim-lsp-installer", {
      ui = {
        icons = {
          server_installed = "✓",
          server_uninstalled = "✗",
          server_pending = "⟳",
        },
      },
    }))
  end
end

return M
