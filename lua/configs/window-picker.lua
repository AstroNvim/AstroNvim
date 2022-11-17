local colors = require "default_theme.colors"
require("window-picker").setup(
  astronvim.user_plugin_opts("plugins.window-picker", { use_winbar = "smart", other_win_hl_color = colors.grey_4 })
)
