return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = { group = vim.g.icons_enabled ~= false and "" or "+", separator = "" },
    disable = { filetypes = { "TelescopePrompt" } },
  },
  config = function(_, opts)
    local wk = require "which-key"
    local show = wk.show
    wk.show = function(keys, opts)
      if vim.o.cmdheight == 1 then return show(keys, opts) end
      vim.o.cmdheight = 1
      vim.cmd.redraw()
      show(keys, opts)
      vim.schedule(function() vim.o.cmdheight = 0 end)
    end
    wk.setup { opts }
  end,
}
