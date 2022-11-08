require("mason").setup(astronvim.user_plugin_opts("plugins.mason", {
  ui = {
    icons = {
      package_installed = "✓",
      package_uninstalled = "✗",
      package_pending = "⟳",
    },
  },
}))
