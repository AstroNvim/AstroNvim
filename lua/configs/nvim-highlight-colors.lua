local status_ok, hl_colors = pcall(require, "nvim-highlight-colors")
if not status_ok then return end
hl_colors.setup(
  astronvim.user_plugin_opts("plugins.nvim-highlight-colors", { render = "background", enable_tailwind = true })
)
