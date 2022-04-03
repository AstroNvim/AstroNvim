local cmp = {
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      local kind_icons = require("user.colorscheme.icons").kind
      vim_item.kind = string.format("%s", kind_icons[vim_item.kind])

      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      -- NOTE: order matters
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        nvim_lua = "[NUA]",
        luasnip = "[SNIP]",
        buffer = "[BUFR]",
        path = "[PATH]",
        -- emoji = "[Emoji]",
      })[entry.source.name]
      return vim_item
    end,
  },
}

return cmp
