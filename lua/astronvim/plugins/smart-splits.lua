return {
  "mrjones2014/smart-splits.nvim",
  lazy = true,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
        maps.n["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
        maps.n["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
        maps.n["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
        maps.n["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
        maps.n["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
        maps.n["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
        maps.n["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
      end,
    },
  },
  opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
}
