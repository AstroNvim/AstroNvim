local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then return end
toggleterm.setup(astronvim.user_plugin_opts("plugins.toggleterm", {
  size = 10,
  open_mapping = [[<F7>]],
  shading_factor = 2,
  direction = "float",
  float_opts = {
    border = "curved",
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
}))
