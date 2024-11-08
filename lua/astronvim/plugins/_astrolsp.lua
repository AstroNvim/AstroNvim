return {
  "AstroNvim/astrolsp",
  lazy = true,
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    ---@diagnostic disable-next-line: missing-fields
    config = {},
    defaults = {
      hover = {
        border = "rounded",
        silent = true,
      },
      signature_help = {
        border = "rounded",
        silent = true,
        focusable = false,
      },
    },
    flags = {},
    formatting = { format_on_save = { enabled = true }, disabled = {} },
    handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
    servers = {},
    on_attach = nil,
  },
}
