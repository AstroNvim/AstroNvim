return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = vim.g.icons_enabled ~= false and { group = "", separator = "" } or { group = "+", separator = "-" },
    disable = { filetypes = { "TelescopePrompt" } },
  },
}
