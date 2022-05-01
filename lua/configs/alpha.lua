local M = {}

function M.config()
  local present, alpha = pcall(require, "alpha")
  if present then
    local utils = require "core.utils"
    local plugins_count = vim.fn.len(vim.fn.globpath(vim.fn.stdpath "data" .. "/site/pack/packer/start", "*", 0, 1))
    alpha.setup(utils.user_plugin_opts("plugins.alpha", {
      layout = {
        { type = "padding", val = 2 },
        {
          type = "text",
          val = utils.user_plugin_opts "header",
          opts = {
            position = "center",
            hl = "DashboardHeader",
          },
        },
        { type = "padding", val = 2 },
        {
          type = "group",
          val = {
            utils.alpha_button("SPC f f", "  Find File  "),
            utils.alpha_button("SPC f o", "  Recents  "),
            utils.alpha_button("SPC f w", "  Find Word  "),
            utils.alpha_button("SPC f n", "  New File  "),
            utils.alpha_button("SPC f m", "  Bookmarks  "),
            utils.alpha_button("SPC S l", "  Last Session  "),
          },
          opts = {
            spacing = 1,
          },
        },
        {
          type = "text",
          val = {
            " ",
            " ",
            " ",
            " AstroNvim loaded " .. plugins_count .. " plugins ",
          },
          opts = {
            position = "center",
            hl = "DashboardFooter",
          },
        },
      },
      opts = {},
    }))
  end
end

return M
