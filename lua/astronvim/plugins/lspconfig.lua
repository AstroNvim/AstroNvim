return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "AstroNvim/astrolsp", optional = true },
  },
  cmd = { "LspInfo", "LspLog", "LspStart" },
  event = "User AstroFile",
}
