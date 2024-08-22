return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts_extend = { "library" },
  opts = function(_, opts)
    opts.library = {
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      { path = "lazy.nvim", words = { "Lazy" } },
      { path = "astrocore", words = { "AstroCore" } },
      { path = "astrolsp", words = { "AstroLSP" } },
      { path = "astroui", words = { "AstroUI" } },
      { path = "astrotheme", words = { "AstroTheme" } },
    }
    if vim.fn.has "nvim-0.10" ~= 1 then
      require("lazydev.config").have_0_10 = true -- force lazydev in 0.9
      table.insert(opts.library, { "neodev.nvim/types/stable" })
    end
  end,
  specs = {
    -- TODO: remove neodev when dropping 0.9 support
    { "folke/neodev.nvim", enabled = vim.fn.has "nvim-0.10" ~= 1, lazy = true, config = function() end },
    { "Bilal2453/luvit-meta", lazy = true },
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      opts = function(_, opts) table.insert(opts.sources, { name = "lazydev", group_index = 0 }) end,
    },
  },
}
