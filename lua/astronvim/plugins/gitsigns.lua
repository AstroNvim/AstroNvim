return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable "git" == 1,
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
      on_attach = function(bufnr)
        local astrocore = require "astrocore"
        local prefix, maps = "<Leader>g", astrocore.empty_map_table()
        for _, mode in ipairs { "n", "v" } do
          maps[mode][prefix] = { desc = get_icon("Git", 1, true) .. "Git" }
        end

        maps.n[prefix .. "l"] = { function() require("gitsigns").blame_line() end, desc = "View Git blame" }
        maps.n[prefix .. "L"] =
          { function() require("gitsigns").blame_line { full = true } end, desc = "View full Git blame" }
        maps.n[prefix .. "p"] = { function() require("gitsigns").preview_hunk_inline() end, desc = "Preview Git hunk" }
        maps.n[prefix .. "r"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" }
        maps.v[prefix .. "r"] = {
          function() require("gitsigns").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          desc = "Reset Git hunk",
        }
        maps.n[prefix .. "R"] = { function() require("gitsigns").reset_buffer() end, desc = "Reset Git buffer" }
        maps.n[prefix .. "s"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage Git hunk" }
        maps.v[prefix .. "s"] = {
          function() require("gitsigns").stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          desc = "Stage Git hunk",
        }
        maps.n[prefix .. "S"] = { function() require("gitsigns").stage_buffer() end, desc = "Stage Git buffer" }
        maps.n[prefix .. "u"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Unstage Git hunk" }
        maps.n[prefix .. "d"] = { function() require("gitsigns").diffthis() end, desc = "View Git diff" }

        maps.n["]g"] = { function() require("gitsigns").next_hunk() end, desc = "Next Git hunk" }
        maps.n["[g"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous Git hunk" }
        for _, mode in ipairs { "o", "x" } do
          maps[mode]["ig"] = { ":<C-U>Gitsigns select_hunk<CR>", desc = "inside Git hunk" }
        end

        astrocore.set_mappings(maps, { buffer = bufnr })
      end,
      worktrees = require("astrocore").config.git_worktrees,
    }
  end,
}
