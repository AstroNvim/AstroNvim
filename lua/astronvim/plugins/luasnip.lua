return {
  "L3MON4D3/LuaSnip",
  lazy = true,
  build = vim.fn.has "win32" == 0
      and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
    or nil,
  dependencies = { { "rafamadriz/friendly-snippets", lazy = true } },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
    region_check_events = "CursorMoved",
  },
  specs = {
    { "Saghen/blink.cmp", optional = true, opts = { snippets = { preset = "luasnip" } } },
  },
  config = function(...) require "astronvim.plugins.configs.luasnip"(...) end,
}
