return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable "git" == 1,
  dependencies = {
    {
      "astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local utils = require "astrocore.utils"
        if utils.is_available "gitsigns.nvim" then
          maps.n["<leader>g"] = opts._map_section.g
          maps.n["]g"] = { function() require("gitsigns").next_hunk() end, desc = "Next Git hunk" }
          maps.n["[g"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous Git hunk" }
          maps.n["<leader>gl"] = { function() require("gitsigns").blame_line() end, desc = "View Git blame" }
          maps.n["<leader>gL"] =
            { function() require("gitsigns").blame_line { full = true } end, desc = "View full Git blame" }
          maps.n["<leader>gp"] = { function() require("gitsigns").preview_hunk() end, desc = "Preview Git hunk" }
          maps.n["<leader>gh"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" }
          maps.n["<leader>gr"] = { function() require("gitsigns").reset_buffer() end, desc = "Reset Git buffer" }
          maps.n["<leader>gs"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage Git hunk" }
          maps.n["<leader>gS"] = { function() require("gitsigns").stage_buffer() end, desc = "Stage Git buffer" }
          maps.n["<leader>gu"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Unstage Git hunk" }
          maps.n["<leader>gd"] = { function() require("gitsigns").diffthis() end, desc = "View Git diff" }
        end
      end,
    },
  },
  event = "User AstroGitFile",
  opts = function()
    local get_icon = require("astroui").get_icon
    return {
      signs = {
        add = { text = get_icon "GitSign" },
        change = { text = get_icon "GitSign" },
        delete = { text = get_icon "GitSign" },
        topdelete = { text = get_icon "GitSign" },
        changedelete = { text = get_icon "GitSign" },
        untracked = { text = get_icon "GitSign" },
      },
      worktrees = require("astrocore").config.git_worktrees,
    }
  end,
}
