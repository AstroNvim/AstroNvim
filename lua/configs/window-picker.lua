local status_ok, window_picker = pcall(require, "window-picker")
if not status_ok then return end
local colors = require "default_theme.colors"
window_picker.setup(astronvim.user_plugin_opts("plugins.window-picker", { other_win_hl_color = colors.grey_4 }))
