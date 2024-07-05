return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
  event = "User AstroFile",
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if require("astrocore").is_available "telescope.nvim" then
          maps.n["<Leader>fT"] = { "<Cmd>TodoTelescope<CR>", desc = "Find TODOs" }
        end
        maps.n["]T"] = { function() require("todo-comments").jump_next() end, desc = "Next TODO comment" }
        maps.n["[T"] = { function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" }
      end,
    },
  },
  opts = {},
}
