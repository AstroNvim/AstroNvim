return {
  "onsails/lspkind.nvim",
  lazy = true,
  enabled = vim.g.icons_enabled ~= false,
  dependencies = {
    {
      "hrsh7th/nvim-cmp",
      opts = function(_, opts)
        if not opts.formatting then opts.formatting = {} end
        opts.formatting.format = require("lspkind").cmp_format(require("astrocore").plugin_opts "lspkind.nvim")
      end,
    },
  },
  opts = {
    mode = "symbol",
    symbol_map = {
      Array = "󰅪",
      Boolean = "⊨",
      Class = "󰌗",
      Constructor = "",
      Key = "󰌆",
      Namespace = "󰅪",
      Null = "NULL",
      Number = "#",
      Object = "󰀚",
      Package = "󰏗",
      Property = "",
      Reference = "",
      Snippet = "",
      String = "󰀬",
      TypeParameter = "󰊄",
      Unit = "",
    },
    menu = {},
  },
  config = function(...) require "astronvim.plugins.configs.lspkind"(...) end,
}
