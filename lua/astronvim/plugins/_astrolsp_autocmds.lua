local formatting_enabled = function(client)
  local formatting_disabled = vim.tbl_get(require("astrolsp").config, "formatting", "disabled")
  return client.supports_method "textDocument/formatting"
    and formatting_disabled ~= true
    and not vim.tbl_contains(formatting_disabled, client.name)
end

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    commands = {
      Format = {
        cond = formatting_enabled,
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format file with LSP",
      },
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
      lsp_auto_format = {
        cond = formatting_enabled,
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
