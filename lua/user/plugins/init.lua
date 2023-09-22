return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        opt = {
          list = true,
        },
        show_current_context = true,
        show_current_context_start = true,
        show_end_of_line = true,
        space_char_blankline = " ",
        char_highlight_list = {
          "IndentBlanklineIndent1",
          "IndentBlanklineIndent2",
          "IndentBlanklineIndent3",
          "IndentBlanklineIndent4",
          "IndentBlanklineIndent5",
          "IndentBlanklineIndent6",
      },
    }
    end
  },
  {
      "sainnhe/sonokai",
      init = function() -- init function runs before the plugin is loaded
        vim.g.sonokai_style = "atlantis"
      end,
    },
    {
      "NLKNguyen/papercolor-theme",
      init = function() -- init function runs before the plugin is loaded
        vim.g.airline_theme = "papercolor"
      end,
    },
    {
      "morhetz/gruvbox",
      init = function()
      end
    },
    {
      "ayu-theme/ayu-vim",
      init = function()
        ayucolor = "mirage"
      end
    }
}
