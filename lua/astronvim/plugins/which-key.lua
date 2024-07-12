return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "disable.ft", "disable.bt" },
  opts = {
    icons = {
      group = vim.g.icons_enabled ~= false and "" or "+",
      rules = false,
      separator = "-",
    },
  },
}
