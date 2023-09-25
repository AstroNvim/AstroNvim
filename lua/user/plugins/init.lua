return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        opt = {
          list = true,
        },
        show_current_context = true,
        --show_current_context_start = true,
        show_end_of_line = true,
        space_char_blankline = " ",
        --char_highlight_list = {
        --  "IndentBlanklineIndent1",
        --  "IndentBlanklineIndent2",
        --  "IndentBlanklineIndent3",
        --  "IndentBlanklineIndent4",
        --  "IndentBlanklineIndent5",
        --  "IndentBlanklineIndent6",
        --},
    }
    end
  },
  {
    "Shatur/neovim-ayu",
    init = function()
      require('ayu').setup {
          mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
          overrides = {}, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
      }
    end
  }
}
