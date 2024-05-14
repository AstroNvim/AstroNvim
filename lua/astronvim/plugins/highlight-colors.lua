return {
  "brenoprata10/nvim-highlight-colors",
  event = { "User AstroFile", "InsertEnter" },
  cmd = "HighlightColors",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>uz"] = { function() vim.cmd.HighlightColors "Toggle" end, desc = "Toggle color highlight" }
      end,
    },
  },
  opts = { enabled_named_colors = false },
}
