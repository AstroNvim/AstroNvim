return {
  "RRethy/vim-illuminate",
  event = "User AstroFile",
  specs = {
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
  opts = {
    delay = 200,
    min_count_to_highlight = 2,
    should_enable = function(bufnr)
      local buf_utils = require "astrocore.buffer"
      return buf_utils.is_valid(bufnr) and not buf_utils.is_large(bufnr)
    end,
  },
  config = function(...) require "astronvim.plugins.configs.vim-illuminate"(...) end,
}
