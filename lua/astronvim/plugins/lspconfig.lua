return {
  "neovim/nvim-lspconfig",
  specs = {
    {
      "AstroNvim/astrolsp",
      optional = true,
      dependencies = { "neovim/nvim-lspconfig" },
    },
  },
  cmd = { "LspInfo", "LspLog", "LspStart" },
  event = "User AstroFile",
}
