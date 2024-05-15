return {
  "brenoprata10/nvim-highlight-colors",
  event = "User AstroFile",
  cmd = "HighlightColors",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>uz"] = { "<Cmd>HighlightColors Toggle<CR>", desc = "Toggle color highlight" }
      end,
    },
  },
  opts = { enable_named_colors = false },
}
