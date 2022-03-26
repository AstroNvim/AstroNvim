local config = {

  colorscheme = "default_theme",

  plugins = {
    packer = {
      compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
    },
  },

  diagnostics = {
    virtual_text = true,
  },

  default_theme = {
    diagnostics_style = "none",
  },

  enabled = {
    bufferline = true,
    nvim_tree = true,
    lualine = true,
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
}

return config
