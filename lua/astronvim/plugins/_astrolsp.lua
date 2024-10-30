return {
  "AstroNvim/astrolsp",
  lazy = true,
  opts = function(_, opts)
    local lsp_handlers
    if vim.fn.has "nvim-0.11" == 0 then
      lsp_handlers = {
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          { border = "rounded", silent = true, focusable = false }
        ),
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true }),
      }
    end

    return require("astrocore").extend_tbl(opts, {
      features = {
        codelens = true,
        inlay_hints = false,
        semantic_tokens = true,
      },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      ---@diagnostic disable-next-line: missing-fields
      config = {},
      flags = {},
      formatting = { format_on_save = { enabled = true }, disabled = {} },
      handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
      lsp_handlers = lsp_handlers,
      servers = {},
      on_attach = nil,
    } --[[@as AstroLSPOpts]])
  end,
}
