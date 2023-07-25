return {
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate", -- AstroNvim extension here as well
      "MasonUpdateAll", -- AstroNvim specific
    },
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "mason.nvim" then
            maps.n["<leader>pm"] = { "<cmd>Mason<cr>", desc = "Mason Installer" }
            maps.n["<leader>pM"] = { "<cmd>MasonUpdateAll<cr>", desc = "Mason Update" }
          end
        end,
      },
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
    build = ":MasonUpdate",
    config = require "astronvim.plugins.configs.mason",
  },
}
