local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

lsp_installer.on_server_ready(function(server)
  local opts = server:get_default_options()
  opts.on_attach = require("configs.lsp.handlers").on_attach
  opts.capabilities = require("configs.lsp.handlers").capabilities

  -- Apply AstroVim server settings (if available)
  local present, av_overrides = pcall(require, "configs.lsp.server-settings." .. server.name)
  if present then
    opts = vim.tbl_deep_extend("force", av_overrides, opts)
  end

  local user, user_overrides = pcall(require, "user.server-settings." .. server.name)
  if user then
    opts = vim.tbl_deep_extend("force", user_overrides, opts)
  end

  require("core.utils").user_settings().overrides.lsp_installer.server_registration_override(server, opts)
end)
