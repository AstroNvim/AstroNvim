return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = function(_, opts)
    -- configure `vim.ui.input`
    opts.input = {}

    -- configure picker and `vim.ui.select`
    opts.picker = { ui_select = true }
  end,
}
