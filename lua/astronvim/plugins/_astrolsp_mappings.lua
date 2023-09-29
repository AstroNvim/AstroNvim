return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    local maps = require("astrocore").empty_map_table()
    maps.v["<Leader>l"] = { desc = " LSP" }

    maps.n["<Leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    maps.n["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" }
    maps.n["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" }
    maps.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }

    maps.n["<Leader>la"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "LSP code action",
      cond = "testDocument/codeAction", -- LSP client capability string
    }
    maps.v["<Leader>la"] = maps.n["<Leader>la"]

    maps.n["<Leader>ll"] =
      { function() vim.lsp.codelens.refresh() end, desc = "LSP CodeLens refresh", cond = "textDocument/codeLens" }
    maps.n["<Leader>lL"] =
      { function() vim.lsp.codelens.run() end, desc = "LSP CodeLens run", cond = "textDocument/codeLens" }

    maps.n["gD"] = {
      function() vim.lsp.buf.declaration() end,
      desc = "Declaration of current symbol",
      cond = "textDocument/declaration",
    }
    maps.n["gd"] = {
      function() vim.lsp.buf.definition() end,
      desc = "Show the definition of current symbol",
      cond = "textDocument/definition",
    }

    maps.n["<Leader>lf"] =
      { function() vim.lsp.buf.format(maps.format_opts) end, desc = "Format buffer", cond = "textDocument/formatting" }
    maps.v["<Leader>lf"] = maps.n["<Leader>lf"]
    maps.n["<Leader>uf"] = {
      function() require("astrolsp.toggles").buffer_autoformat() end,
      desc = "Toggle autoformatting (buffer)",
      cond = "textDocument/formatting",
    }
    maps.n["<Leader>uF"] = {
      function() require("astrolsp.toggles").autoformat() end,
      desc = "Toggle autoformatting (global)",
      cond = "textDocument/formatting",
    }

    maps.n["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details", cond = "textDocument/hover" }

    maps.n["gI"] = {
      function() vim.lsp.buf.implementation() end,
      desc = "Implementation of current symbol",
      cond = "textDocument/implementation",
    }

    maps.n["<Leader>uH"] = {
      function() require("astrolsp.toggles").buffer_inlay_hints() end,
      desc = "Toggle LSP inlay hints (buffer)",
      cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
    }

    maps.n["gr"] = {
      function() vim.lsp.buf.references() end,
      desc = "References of current symbol",
      cond = "textDocument/references",
    }
    maps.n["<Leader>lR"] =
      { function() vim.lsp.buf.references() end, desc = "Search references", cond = "textDocument/references" }

    maps.n["<Leader>lr"] =
      { function() vim.lsp.buf.rename() end, desc = "Rename current symbol", cond = "textDocument/rename" }

    maps.n["<Leader>lh"] =
      { function() vim.lsp.buf.signature_help() end, desc = "Signature help", cond = "textDocument/signatureHelp" }

    maps.n["gT"] = {
      function() vim.lsp.buf.type_definition() end,
      desc = "Definition of current type",
      cond = "textDocument/typeDefinition",
    }

    maps.n["<Leader>lG"] =
      { function() vim.lsp.buf.workspace_symbol() end, desc = "Search workspace symbols", cond = "workspace/symbol" }

    maps.n["<Leader>uY"] = {
      function() require("astrolsp.toggles").buffer_semantic_tokens() end,
      desc = "Toggle LSP semantic highlight (buffer)",
      cond = function(client) return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens end,
    }
    opts.mappings = require("astrocore").extend_tbl(opts.mappings, maps)
  end,
}
