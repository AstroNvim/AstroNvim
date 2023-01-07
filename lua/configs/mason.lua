require("mason").setup(astronvim.user_plugin_opts("plugins.mason", {
  ui = {
    icons = {
      package_installed = "✓",
      package_uninstalled = "✗",
      package_pending = "⟳",
    },
  },
}))

local cmd = vim.api.nvim_create_user_command
cmd("MasonUpdateAll", function() astronvim.mason.update_all() end, { desc = "Update Mason Packages" })
cmd("MasonUpdate", function(opts) astronvim.mason.update(opts.args) end, { nargs = 1, desc = "Update Mason Package" })
