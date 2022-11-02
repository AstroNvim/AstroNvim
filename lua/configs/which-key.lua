local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end
which_key.setup(astronvim.user_plugin_opts("plugins.which-key", {
  plugins = {
    spelling = { enabled = true },
    presets = { operators = false },
  },
  window = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
  disable = {
    filetypes = { "TelescopePrompt", "neo-tree" },
  },
}))
