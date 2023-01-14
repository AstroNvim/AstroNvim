return {
  {
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
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
}
