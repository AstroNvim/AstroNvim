local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if status_ok then
  local user_plugin_opts = require("core.utils").user_plugin_opts

  lsp_installer.on_server_ready(function(server)
    local opts = server:get_default_options()
    opts.on_attach = require("configs.lsp.handlers").on_attach
    opts.capabilities = require("configs.lsp.handlers").capabilities

    -- Apply AstroNvim server settings (if available)
    local present, av_overrides = pcall(require, "configs.lsp.server-settings." .. server.name)
    if present then
      opts = vim.tbl_deep_extend("force", av_overrides, opts)
    end

    opts = user_plugin_opts("lsp.server-settings." .. server.name, opts)

    local user_override = user_plugin_opts "lsp.server_registration"
    if user_override ~= nil then
      user_override(server, opts)
    else
      server:setup(opts)
    end
  end)
end
