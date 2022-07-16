return {
  on_attach = astronvim.lsp.disable_formatting,
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
    },
  },
  setup = {
    commands = {
      Format = {
        function() vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 }) end,
      },
    },
  },
}
