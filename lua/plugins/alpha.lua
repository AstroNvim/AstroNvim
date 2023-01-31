return {
  "goolord/alpha-nvim",
  cmd = "Alpha",
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

    dashboard.section.buttons.val = {
      astronvim.alpha_button("LDR n", "  New File  "),
      astronvim.alpha_button("LDR f f", "  Find File  "),
      astronvim.alpha_button("LDR f o", "  Recents  "),
      astronvim.alpha_button("LDR f w", "  Find Word  "),
      astronvim.alpha_button("LDR f '", "  Bookmarks  "),
      astronvim.alpha_button("LDR S l", "  Last Session  "),
    }

    dashboard.section.footer.val =
      { " ", " ", " ", "AstroNvim loaded " .. require("lazy").stats().count .. " plugins " }
    dashboard.section.footer.opts.hl = "DashboardFooter"

    dashboard.config.layout[1].val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }
    dashboard.config.layout[3].val = 5
    dashboard.config.opts.noautocmd = true
    return dashboard
  end,
  config = require "plugins.configs.alpha",
}
