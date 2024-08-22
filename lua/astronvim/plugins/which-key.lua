return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec", "disable.ft", "disable.bt" },
  opts = {
    triggers = { { "<auto>", mode = "nxso" } },
    icons = {
      group = vim.g.icons_enabled ~= false and "" or "+",
      rules = false,
      separator = "-",
    },
  },
}
