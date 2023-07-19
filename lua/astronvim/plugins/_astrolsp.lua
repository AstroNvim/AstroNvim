return {
  "AstroNvim/astrolsp",
  lazy = true,
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    local schemastore_avail, schemastore = pcall(require, "schemastore")
    ---@type AstroLSPOpts
    local extension = {
      features = {
        autoformat = true,
        codelens = true,
        diagnostics_mode = 3,
        inlay_hints = false,
        lsp_handlers = true,
        semantic_tokens = true,
      },
      capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
        textDocument = {
          completion = {
            completionItem = {
              documentationFormat = { "markdown", "plaintext" },
              snippetSupport = true,
              preselectSupport = true,
              insertReplaceSupport = true,
              labelDetailsSupport = true,
              deprecatedSupport = true,
              commitCharactersSupport = true,
              tagSupport = { valueSet = { 1 } },
              resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
            },
          },
          foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
        },
      }),
      config = {
        jsonls = {
          settings = {
            json = {
              schemas = schemastore_avail and schemastore.json.schemas() or nil,
              validate = { enable = schemastore_avail },
            },
          },
        },
        yamlls = { settings = { yaml = { schemas = schemastore_avail and schemastore.json.schemas() or nil } } },
        lua_ls = { settings = { Lua = { workspace = { checkThirdParty = false } } } },
      },
      diagnostics = {
        virtual_text = true,
        signs = {
          active = {
            { name = "DiagnosticSignError", text = "", texthl = "DiagnosticSignError" },
            { name = "DiagnosticSignHint", text = "󰌵", texthl = "DiagnosticSignHint" },
            { name = "DiagnosticSignInfo", text = "󰋼", texthl = "DiagnosticSignInfo" },
            { name = "DiagnosticSignWarn", text = "", texthl = "DiagnosticSignWarn" },
            { name = "DapBreakpoint", text = "", texthl = "DiagnosticInfo" },
            { name = "DapBreakpointCondition", text = "", texthl = "DiagnosticInfo" },
            { name = "DapBreakpointRejected", text = "", texthl = "DiagnosticError" },
            { name = "DapLogPoint", text = ".>", texthl = "DiagnosticInfo" },
            { name = "DapStopped", text = "󰁕", texthl = "DiagnosticWarn" },
          },
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focused = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      },
      flags = {},
      formatting = { format_on_save = { enabled = true }, disabled = {} },
      handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
      servers = {},
      on_attach = nil,
    }
    return require("astrocore").extend_tbl(opts, extension)
  end,
}
