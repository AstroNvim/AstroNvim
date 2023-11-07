return {
  "AstroNvim/astrolsp",
  lazy = true,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>ud"] = { function() require("astrolsp.toggles").diagnostics() end, desc = "Toggle diagnostics" }
        maps.n["<Leader>uL"] = { function() require("astrolsp.toggles").codelens() end, desc = "Toggle CodeLens" }
      end,
    },
  },
  ---@type AstroLSPOpts
  opts = {
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
  },
}
