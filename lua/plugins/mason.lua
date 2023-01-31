return {
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
    init = function()
      local cmd = vim.api.nvim_create_user_command
      cmd("MasonUpdateAll", function() astronvim.mason.update_all() end, { desc = "Update Mason Packages" })
      cmd(
        "MasonUpdate",
        function(options) astronvim.mason.update(options.args) end,
        { nargs = 1, desc = "Update Mason Package" }
      )
    end,
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_uninstalled = "✗",
          package_pending = "⟳",
        },
      },
    },
  },
}
