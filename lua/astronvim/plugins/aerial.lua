return {
  "stevearc/aerial.nvim",
  event = "User AstroFile",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>lS"] = { function() require("aerial").toggle() end, desc = "Symbols outline" }
      end,
    },
  },
  opts = function()
    local opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { min_width = 28 },
      show_guides = true,
      filter_kind = false,
      guides = {
        mid_item = "├ ",
        last_item = "└ ",
        nested_top = "│ ",
        whitespace = "  ",
      },
      keymaps = {
        ["[y"] = "actions.prev",
        ["]y"] = "actions.next",
        ["[Y"] = "actions.prev_up",
        ["]Y"] = "actions.next_up",
        ["{"] = false,
        ["}"] = false,
        ["[["] = false,
        ["]]"] = false,
      },
    }

    local large_buf = vim.tbl_get(require("astrocore").config, "features", "large_buf")
    if large_buf then
      opts.disable_max_lines, opts.disable_max_size = large_buf.lines, large_buf.size
    end

    return opts
  end,
}
