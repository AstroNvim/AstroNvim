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
      cmd(
        "MasonUpdateAll",
        function() require("astronvim.utils.mason").update_all() end,
        { desc = "Update Mason Packages" }
      )
      cmd(
        "MasonUpdate",
        function(options) require("astronvim.utils.mason").update(options.args) end,
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
    config = require "plugins.configs.mason",
  },
}
