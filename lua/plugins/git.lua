return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable "git" == 1,
  ft = "gitcommit",
  init = function() table.insert(astronvim.git_plugins, "gitsigns.nvim") end,
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▎" },
      topdelete = { text = "契" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
  },
  default_config = function(opts) require("gitsigns").setup(opts) end,
  config = function(plugin, opts) plugin.default_config(opts) end,
}
