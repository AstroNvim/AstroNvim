local status_ok, aerial = pcall(require, "aerial")
if status_ok then
  aerial.setup(astronvim.user_plugin_opts("plugins.aerial", {
    close_behavior = "global",
    backends = { "lsp", "treesitter", "markdown" },
    min_width = 28,
    show_guides = true,
    filter_kind = false,
    icons = {
      Array = "",
      Boolean = "⊨",
      Class = "",
      Constant = "",
      Constructor = "",
      Key = "",
      Function = "",
      Method = "ƒ",
      Namespace = "",
      Null = "NULL",
      Number = "#",
      Object = "⦿",
      Property = "",
      TypeParameter = "𝙏",
      Variable = "",
      Enum = "ℰ",
      Package = "",
      EnumMember = "",
      File = "",
      Module = "",
      Field = "",
      Interface = "ﰮ",
      String = "𝓐",
      Struct = "𝓢",
      Event = "",
      Operator = "+",
    },
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "Jump backwards in Aerial" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "Jump forwards in Aerial" })
      -- Jump up the tree with '[[' or ']]'
      vim.keymap.set("n", "[[", "<cmd>AerialPrevUp<cr>", { buffer = bufnr, desc = "Jump up and backwards in Aerial" })
      vim.keymap.set("n", "]]", "<cmd>AerialNextUp<cr>", { buffer = bufnr, desc = "Jump up and forwards in Aerial" })
    end,
  }))
end
