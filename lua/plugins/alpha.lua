return {
  "goolord/alpha-nvim",
  cmd = "Alpha",
  dependencies = {
    {
      "astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if require("astrocore.utils").is_available "alpha-nvim" then
          maps.n["<leader>h"] = {
            function()
              local wins = vim.api.nvim_tabpage_list_wins(0)
              if #wins > 1 and vim.api.nvim_get_option_value("filetype", { win = wins[1] }) == "neo-tree" then
                vim.fn.win_gotoid(wins[2]) -- go to non-neo-tree window to toggle alpha
              end
              require("alpha").start(false, require("alpha").default_config)
            end,
            desc = "Home Screen",
          }
        end
      end,
    },
  },
  opts = function()
    local dashboard = require "alpha.themes.dashboard"
    dashboard.section.header.val = {
      " █████  ███████ ████████ ██████   ██████",
      "██   ██ ██         ██    ██   ██ ██    ██",
      "███████ ███████    ██    ██████  ██    ██",
      "██   ██      ██    ██    ██   ██ ██    ██",
      "██   ██ ███████    ██    ██   ██  ██████",
      " ",
      "    ███    ██ ██    ██ ██ ███    ███",
      "    ████   ██ ██    ██ ██ ████  ████",
      "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
      "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
      "    ██   ████   ████   ██ ██      ██",
    }
    dashboard.section.header.opts.hl = "DashboardHeader"

    local button = require("astrocore.utils").alpha_button
    local get_icon = require("astrocore.utils").get_icon
    dashboard.section.buttons.val = {
      button("LDR n  ", get_icon("FileNew", 2, true) .. "New File  "),
      button("LDR f f", get_icon("Search", 2, true) .. "Find File  "),
      button("LDR f o", get_icon("DefaultFile", 2, true) .. "Recents  "),
      button("LDR f w", get_icon("WordFile", 2, true) .. "Find Word  "),
      button("LDR f '", get_icon("Bookmarks", 2, true) .. "Bookmarks  "),
      button("LDR S l", get_icon("Refresh", 2, true) .. "Last Session  "),
    }

    dashboard.config.layout[1].val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }
    dashboard.config.layout[3].val = 5
    dashboard.config.opts.noautocmd = true
    return dashboard
  end,
  config = require "plugins.configs.alpha",
}
