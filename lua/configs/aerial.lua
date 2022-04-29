local M = {}

function M.config()
  local present, aerial = pcall(require, "aerial")
  if present then
    aerial.setup(require("core.utils").user_plugin_opts("plugins.aerial", {
      close_behavior = "global",
      backends = { "lsp", "treesitter", "markdown" },
      min_width = 35,
      show_guides = true,
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
        "Variable",
      },
      icons = {
        Array = " ",
        Boolean = "⊨ ",
        Class = "𝓒 ",
        Key = "🔐 ",
        Namespace = " ",
        Null = "NULL ",
        Number = "# ",
        Object = "⦿ ",
        Property = " ",
        TypeParameter = "𝙏 ",
        Variable = " ",
      },
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>ArialPrev<cr>", { buffer = bufnr, desc = "Jump backwards in Aerial" })
        vim.keymap.set("n", "}", "<cmd>ArialNext<cr>", { buffer = bufnr, desc = "Jump forwards in Aerial" })
        -- Jump up the tree with '[[' or ']]'
        vim.keymap.set("n", "[[", "<cmd>ArialPrevUp<cr>", { buffer = bufnr, desc = "Jump up and backwards in Aerial" })
        vim.keymap.set("n", "]]", "<cmd>ArialNextUp<cr>", { buffer = bufnr, desc = "Jump up and forwards in Aerial" })
      end,
    }))
  end
end

return M
