return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>pm"] = { function() require("mason.ui").open() end, desc = "Mason Installer" }
      end,
    },
  },
  opts_extend = { "registries" },
  opts = function(_, opts)
    if not opts.registries then opts.registries = {} end
    table.insert(opts.registries, "github:mason-org/mason-registry")
    if not opts.ui then opts.ui = {} end
    opts.ui.icons = vim.g.icons_enabled == false
        and {
          package_installed = "O",
          package_uninstalled = "X",
          package_pending = "0",
        }
      or {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      }
  end,
  build = ":MasonUpdate",
}
