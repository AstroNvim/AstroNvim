local M = {}

function M.config()
  local present, alpha = pcall(require, "alpha")
  if present then
    local utils = require "core.utils"
    alpha.setup(utils.user_plugin_opts("plugins.alpha", {
      layout = {
        { type = "padding", val = 2 },
        {
          type = "text",
          val = utils.user_plugin_opts("header", {
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " █████  ███████ ████████ ██████   ██████",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████",
            " ",
            "    ███    ██ ██    ██ ██ ███    ███",
            "    ████   ██ ██    ██ ██ ████  ████",
            "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
            "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
            "    ██   ████   ████   ██ ██      ██",
            " ",
            " ",
            " ",
          }, false),
          opts = {
            position = "center",
            hl = "DashboardHeader",
          },
        },
        { type = "padding", val = 2 },
        {
          type = "group",
          val = {
            utils.alpha_button("LDR f f", "  Find File  "),
            utils.alpha_button("LDR f o", "  Recents  "),
            utils.alpha_button("LDR f w", "  Find Word  "),
            utils.alpha_button("LDR f n", "  New File  "),
            utils.alpha_button("LDR f m", "  Bookmarks  "),
            utils.alpha_button("LDR S l", "  Last Session  "),
          },
          opts = {
            spacing = 1,
          },
        },
      },
      opts = {},
    }))
  end
end

return M
