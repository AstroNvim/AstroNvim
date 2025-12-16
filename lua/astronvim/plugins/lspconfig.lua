return {
  "neovim/nvim-lspconfig",
  cmd = vim.fn.exists ":lsp" ~= 2 and { "LspInfo", "LspLog", "LspStart" } or nil,
  event = "User AstroFile",
}
