return {
  "AstroNvim/astrolsp",
  lazy = true,
  opts_extend = { "servers" },
  opts = function(_, opts)
    return require("astrocore").extend_tbl(opts, {
      features = {
        codelens = true,
        inlay_hints = false,
        semantic_tokens = true,
      },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      ---@diagnostic disable-next-line: missing-fields
      config = { lua_ls = { settings = { Lua = { workspace = { checkThirdParty = false } } } } },
      flags = {},
      formatting = { format_on_save = { enabled = true }, disabled = {} },
      handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
      lsp_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true }),
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          { border = "rounded", silent = true, focusable = false }
        ),
      },
      servers = {},
      on_attach = nil,
    } --[[@as AstroLSPOpts]])
  end,
}
