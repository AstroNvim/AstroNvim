local config = {

  colorscheme = "onedark",

  plugins = {
    packer = {
      compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
    },
  },

  diagnostics = {
    virtual_text = true,
  },

  one_dark = {
    diagnostics_style = "none",
  },

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
  polish = function() end,

  -- A function called during plugin setup. It takes the entire list of plugins
  -- and provides a user with an opportunity to modify the entire list before
  -- loading plugins.
  polish_plugins = function(plugins)
    return plugins
  end,
}

return config
