local status_ok, gitsigns = pcall(require, "gitsigns")
if status_ok then
  gitsigns.setup(astronvim.user_plugin_opts("plugins.gitsigns", {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▎" },
      topdelete = { text = "契" },
      changedelete = { text = "▎" },
    },
  }))
end
