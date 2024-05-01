return {
  "RRethy/vim-illuminate",
  event = "User AstroFile",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["]r"] = { function() require("illuminate")["goto_next_reference"](false) end, desc = "Next reference" }
        maps.n["[r"] =
          { function() require("illuminate")["goto_prev_reference"](false) end, desc = "Previous reference" }
        maps.n["<Leader>ur"] =
          { function() require("illuminate").toggle_buf() end, desc = "Toggle reference highlighting (buffer)" }
        maps.n["<Leader>uR"] =
          { function() require("illuminate").toggle() end, desc = "Toggle reference highlighting (global)" }
      end,
    },
  },
  opts = function()
    return {
      delay = 200,
      min_count_to_highlight = 2,
      large_file_cutoff = vim.tbl_get(require "astrocore", "config", "features", "large_buf", "lines"),
      large_file_overrides = { providers = { "lsp" } },
      should_enable = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
    }
  end,
  config = function(...) require "astronvim.plugins.configs.vim-illuminate"(...) end,
}
