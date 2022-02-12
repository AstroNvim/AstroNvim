local config = {

  colorscheme = "onedark",

  plugins = {},

  overrides = {
    treesitter = {},
  },

  virtual_text = true,

  enabled = {
    bufferline = true,
    nvim_tree = true,
    lualine = true,
    lspsaga = true,
    gitsigns = true,
    colorizer = true,
    toggle_term = true,
    comment = true,
    symbols_outline = true,
    indent_blankline = true,
    dashboard = true,
    which_key = true,
    neoscroll = true,
    ts_rainbow = true,
    ts_autotag = true,
  },

  -- A function called after AstroVim is fully set up.
  -- Use it to override settings or run code.
  --
  -- This function takes no input and AstroVim does not expect it to
  -- return anything either.
  polish = function() end
}

return config
