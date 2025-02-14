return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    local buf_utils = require "astrocore.buffer"

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

    opts.indent = {
      indent = { char = "▏" },
      scope = { char = "▏" },
      filter = function(bufnr)
        return buf_utils.is_valid(bufnr)
          and not buf_utils.is_large(bufnr)
          and vim.g.snacks_indent ~= false
          and vim.b[bufnr].snacks_indent ~= false
      end,
      animate = { enabled = false },
    }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings

        -- Snacks.indent mappings
        maps.n["<Leader>u|"] =
          { function() require("snacks").toggle.indent():toggle() end, desc = "Toggle indent guides" }

        -- Snacks.notifier mappings
        maps.n["<Leader>uD"] = { function() require("snacks.notifier").hide() end, desc = "Dismiss notifications" }
      end,
    },
  },
}
