return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
  event = "User AstroFile",
  cmd = { "LspInstall", "LspUninstall" },
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {},
  },
  config = function(...) require "astronvim.plugins.configs.mason-lspconfig"(...) end,
}
