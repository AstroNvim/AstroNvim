return {
  "astrolsp",
  opts = function(_, opts)
    local maps = opts.mappings

    maps.n["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    maps.n["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" }
    maps.n["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" }
    maps.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }

    maps.n["<leader>lD"] = {
      function() require("telescope.builtin").diagnostics() end,
      desc = "Search diagnostics",
      cond = function() return require("astrocore.utils").is_available "telescope.nvim" end,
    }

    maps.n["<leader>la"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "LSP code action",
      cond = "testDocument/codeAction", -- LSP client capability string
    }
    maps.v["<leader>la"] = maps.n["<leader>la"]

    maps.n["<leader>ll"] =
      { function() vim.lsp.codelens.refresh() end, desc = "LSP CodeLens refresh", cond = "textDocument/codeLens" }
    maps.n["<leader>lL"] =
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

    maps.n["<leader>lf"] =
      { function() vim.lsp.buf.format(maps.format_opts) end, desc = "Format buffer", cond = "textDocument/formatting" }
    maps.v["<leader>lf"] = maps.n["<leader>lf"]
    maps.n["<leader>uf"] = {
      function() require("astrolsp.toggles").buffer_autoformat() end,
      desc = "Toggle autoformatting (buffer)",
      cond = "textDocument/formatting",
    }
    maps.n["<leader>uF"] = {
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

    maps.n["<leader>uH"] = {
      function() require("astrolsp.toggles").buffer_inlay_hints() end,
      desc = "Toggle LSP inlay hints (buffer)",
      cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
    }

    maps.n["gr"] = {
      function() vim.lsp.buf.references() end,
      desc = "References of current symbol",
      cond = "textDocument/references",
    }
    maps.n["<leader>lR"] =
      { function() vim.lsp.buf.references() end, desc = "Search references", cond = "textDocument/references" }

    maps.n["<leader>lr"] =
      { function() vim.lsp.buf.rename() end, desc = "Rename current symbol", cond = "textDocument/rename" }

    maps.n["<leader>lh"] =
      { function() vim.lsp.buf.signature_help() end, desc = "Signature help", cond = "textDocument/signatureHelp" }

    maps.n["gT"] = {
      function() vim.lsp.buf.type_definition() end,
      desc = "Definition of current type",
      cond = "textDocument/typeDefinition",
    }

    maps.n["<leader>lG"] =
      { function() vim.lsp.buf.workspace_symbol() end, desc = "Search workspace symbols", cond = "workspace/symbol" }

    maps.n["<leader>uY"] = {
      function() require("astrolsp.toggles").buffer_semantic_tokens() end,
      desc = "Toggle LSP semantic highlight (buffer)",
      cond = function(client) return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens end,
    }

    -- TODO: FIX this
    -- if not vim.tbl_isempty(maps.v) then maps.v["<leader>l"] = { desc = " LSP" } end

    if vim.fn.exists ":LspInfo" > 0 then maps.n["<leader>li"] = { "<cmd>LspInfo<cr>", desc = "LSP information" } end
    --
    if vim.fn.exists ":NullLsInfo" > 0 then
      maps.n["<leader>lI"] = { "<cmd>NullLsInfo<cr>", desc = "Null-ls information" }
    end

    if vim.fn.exists ":Telescope" > 0 or pcall(require, "telescope") then -- setup telescope mappings if available
      maps.n["<leader>lD"] = { function() require("telescope.builtin").diagnostics() end, desc = "Search diagnostics" }
      if maps.n.gd then maps.n.gd[1] = function() require("telescope.builtin").lsp_definitions() end end
      if maps.n.gI then maps.n.gI[1] = function() require("telescope.builtin").lsp_implementations() end end
      if maps.n.gr then maps.n.gr[1] = function() require("telescope.builtin").lsp_references() end end
      if maps.n["<leader>lR"] then
        maps.n["<leader>lR"][1] = function() require("telescope.builtin").lsp_references() end
      end
      if maps.n.gT then maps.n.gT[1] = function() require("telescope.builtin").lsp_type_definitions() end end
      if maps.n["<leader>lG"] then
        maps.n["<leader>lG"][1] = function()
          vim.ui.input({ prompt = "Symbol Query: " }, function(query)
            if query then require("telescope.builtin").lsp_workspace_symbols { query = query } end
          end)
        end
      end
    end
  end,
}
