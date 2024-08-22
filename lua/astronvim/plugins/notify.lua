return {
  "rcarriga/nvim-notify",
  lazy = true,
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>uD"] = {
          function() require("notify").dismiss { pending = true, silent = true } end,
          desc = "Dismiss notifications",
        }
      end,
    },
  },
  init = function() require("astrocore").load_plugin_with_func("nvim-notify", vim, "notify") end,
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    opts.icons = {
      DEBUG = get_icon "Debugger",
      ERROR = get_icon "DiagnosticError",
      INFO = get_icon "DiagnosticInfo",
      TRACE = get_icon "DiagnosticHint",
      WARN = get_icon "DiagnosticWarn",
    }
    opts.max_height = function() return math.floor(vim.o.lines * 0.75) end
    opts.max_width = function() return math.floor(vim.o.columns * 0.75) end
    opts.on_open = function(win)
      local astrocore = require "astrocore"
      vim.api.nvim_win_set_config(win, { zindex = 175 })
      if not astrocore.config.features.notifications then
        vim.api.nvim_win_close(win, true)
        return
      end
      if astrocore.is_available "nvim-treesitter" then require("lazy").load { plugins = { "nvim-treesitter" } } end
      vim.wo[win].conceallevel = 3
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, "markdown") then vim.bo[buf].syntax = "markdown" end
      vim.wo[win].spell = false
    end
  end,
  config = function(...) require "astronvim.plugins.configs.notify"(...) end,
}
