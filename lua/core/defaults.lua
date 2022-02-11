local config = {

  colorscheme = "onedark",

  plugins = {},

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
  which_key = {
    ignore_missing = true,
    enable_operator_preset = false,
  }

}

return config
