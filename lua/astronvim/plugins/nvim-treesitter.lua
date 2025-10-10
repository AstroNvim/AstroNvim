return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = "VeryLazy",
  lazy = vim.fn.argc(-1) == 0, -- load treesitter immediately when opening a file from the cmdline
  cmd = { "TSInstall", "TSInstallFromGrammar", "TSUninstall", "TSUpdate", "TSLog" },
  build = ":TSUpdate",
  opts = {},
}
