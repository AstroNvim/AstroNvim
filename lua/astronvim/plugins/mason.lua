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
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore").is_available "mason.nvim" then
            maps.n["<Leader>pm"] = { function() require("mason.ui").open() end, desc = "Mason Installer" }
            maps.n["<Leader>pM"] = { function() require("astrocore.mason").update_all() end, desc = "Mason Update" }
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
    config = function(...) require "astronvim.plugins.configs.mason"(...) end,
  },
}
