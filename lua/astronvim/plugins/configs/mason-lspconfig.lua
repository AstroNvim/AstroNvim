local mason_lsp_setup
return function(_, opts)
  local is_available = require("astrocore").is_available
  if is_available "mason-tool-installer.nvim" then opts.ensure_installed = nil end

  if is_available "astrolsp" then
    if opts.automatic_enable ~= false then
      local _ = require "mason-core.functional"
      local registry = require "mason-registry"
      local mappings = require "mason-lspconfig.mappings"
      local lsp_setup = require("astrolsp").lsp_setup

      local enabled_servers = {}
      if not mason_lsp_setup then
        mason_lsp_setup = vim.schedule_wrap(function(mason_pkg)
          if type(mason_pkg) ~= "string" then mason_pkg = mason_pkg.name end
          local lspconfig_name = mappings.get_mason_map().package_to_lspconfig[mason_pkg]
          if not lspconfig_name or enabled_servers[lspconfig_name] then return end

          local ok, config = pcall(require, "mason-lspconfig.lsp." .. lspconfig_name)
          if ok then vim.lsp.config(lspconfig_name, config) end

          lsp_setup(lspconfig_name)
          enabled_servers[lspconfig_name] = true
        end)
      end

      _.each(mason_lsp_setup, registry.get_installed_package_names())
      registry.refresh(vim.schedule_wrap(function(success, updated_registries)
        if success and #updated_registries > 0 then _.each(mason_lsp_setup, registry.get_installed_package_names()) end
      end))
      registry:off("package:install:success", mason_lsp_setup)
      registry:on("package:install:success", mason_lsp_setup)
    end

    opts.automatic_enable = false
  end

  require("mason-lspconfig").setup(opts)
end
