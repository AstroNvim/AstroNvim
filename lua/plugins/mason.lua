return {
  astronvim.plugin {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate", -- astronvim command
      "MasonUpdateAll", -- astronvim command
    },
    init = function() table.insert(astronvim.file_plugins, "mason.nvim") end,
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_uninstalled = "✗",
          package_pending = "⟳",
        },
      },
    },
    default_config = function(opts)
      require("mason").setup(opts)

      local cmd = vim.api.nvim_create_user_command
      cmd("MasonUpdateAll", function() astronvim.mason.update_all() end, { desc = "Update Mason Packages" })
      cmd(
        "MasonUpdate",
        function(options) astronvim.mason.update(options.args) end,
        { nargs = 1, desc = "Update Mason Package" }
      )
      for _, module in ipairs { "mason-lspconfig", "mason-null-ls", "mason-nvim-dap" } do
        pcall(require, module)
      end
    end,
  },
  astronvim.plugin {
    "williamboman/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    default_config = function(opts)
      local mason_lspconfig = require "mason-lspconfig"
      mason_lspconfig.setup(opts)
      mason_lspconfig.setup_handlers { function(server) astronvim.lsp.setup(server) end }
      astronvim.event "LspSetup"
    end,
    dependencies = { "nvim-lspconfig" },
  },
  astronvim.plugin {
    "jay-babu/mason-null-ls.nvim",
    cmd = { "NullLsInstall", "NullLsUninstall" },
    opts = { automatic_setup = true },
    default_config = function(opts)
      local mason_null_ls = require "mason-null-ls"
      mason_null_ls.setup(opts)
      mason_null_ls.setup_handlers {}
    end,
    dependencies = { "null-ls.nvim" },
  },
  astronvim.plugin {
    "jay-babu/mason-nvim-dap.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = { automatic_setup = true },
    default_config = function(opts)
      local mason_nvim_dap = require "mason-nvim-dap"
      mason_nvim_dap.setup(opts)
      mason_nvim_dap.setup_handlers {}
    end,
    dependencies = { "nvim-dap" },
  },
}
