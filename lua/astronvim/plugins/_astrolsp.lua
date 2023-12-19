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
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    ---@type AstroLSPOpts
    local new_opts = {
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
      ---@diagnostic disable-next-line: missing-fields
      config = { lua_ls = { settings = { Lua = { workspace = { checkThirdParty = false } } } } },
      diagnostics = {
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = get_icon "DiagnosticError",
            [vim.diagnostic.severity.HINT] = get_icon "DiagnosticHint",
            [vim.diagnostic.severity.WARN] = get_icon "DiagnosticWarn",
            [vim.diagnostic.severity.INFO] = get_icon "DiagnosticInfo",
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
      signs = {
        { name = "DapBreakpoint", text = get_icon "DapBreakpoint", texthl = "DiagnosticInfo" },
        { name = "DapBreakpointCondition", text = get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
        { name = "DapBreakpointRejected", text = get_icon "DapBreakpointRejected", texthl = "DiagnosticError" },
        { name = "DapLogPoint", text = get_icon "DapLogPoint", texthl = "DiagnosticInfo" },
        { name = "DapStopped", text = get_icon "DapStopped", texthl = "DiagnosticWarn" },
      },
      flags = {},
      formatting = { format_on_save = { enabled = true }, disabled = {} },
      handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
      servers = {},
      on_attach = nil,
    }
    return require("astrocore").extend_tbl(opts, new_opts)
  end,
}
