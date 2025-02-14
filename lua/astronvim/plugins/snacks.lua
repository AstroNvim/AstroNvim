return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon

    -- configure `vim.ui.input`
    opts.input = {}

    -- configure notifier
    opts.notifier = {}
    opts.notifier.icons = {
      DEBUG = get_icon "Debugger",
      ERROR = get_icon "DiagnosticError",
      INFO = get_icon "DiagnosticInfo",
      TRACE = get_icon "DiagnosticHint",
      WARN = get_icon "DiagnosticWarn",
    }

    -- configure picker and `vim.ui.select`
    opts.picker = { ui_select = true }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings

        -- Snacks.notifier mappings
        maps.n["<Leader>uD"] = { function() require("snacks.notifier").hide() end, desc = "Dismiss notifications" }
      end,
    },
  },
}
