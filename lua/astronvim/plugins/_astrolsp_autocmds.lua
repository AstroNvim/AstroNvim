return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens",
          callback = function()
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh() end
          end,
        },
      },
      lsp_document_highlight = {
        cond = "textDocument/documentHighlight",
        {
          event = { "CursorHold", "CursorHoldI" },
          desc = "Document Highlighting",
          callback = function() vim.lsp.buf.document_highlight() end,
        },
        {
          event = { "CursorMoved", "CursorMovedI", "BufLeave" },
          desc = "Document Highlighting Clear",
          callback = function() vim.lsp.buf.clear_references() end,
        },
      },
      lsp_auto_format = {
        cond = function(client)
          local config = assert(require("astrolsp").config)
          return client.supports_method "textDocument/formatting"
            and config.formatting.disabled ~= true
            and not vim.tbl_contains(vim.tbl_get(config, "formatting", "disabled"), client.name)
        end,
        {
          event = "BufWritePre",
          desc = "autoformat on save",
          callback = function(_, _, bufnr)
            local astrolsp = require "astrolsp"
            local autoformat = assert(astrolsp.config.formatting.format_on_save)
            local buffer_autoformat = vim.b[bufnr].autoformat
            if buffer_autoformat == nil then buffer_autoformat = autoformat.enabled end
            if buffer_autoformat and ((not autoformat.filter) or autoformat.filter(bufnr)) then
              vim.lsp.buf.format(vim.tbl_deep_extend("force", astrolsp.format_opts, { bufnr = bufnr }))
            end
          end,
        },
      },
    },
  },
}
