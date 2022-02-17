local config = {

  colorscheme = "onedark",

  plugins = {},

  overrides = {
    lsp_installer = {
      -- A function used to override how a LSP is registered
      --
      -- Gets the server object and the configuration as input and
      -- will by default just call `server:setup(opts)`.
      --
      -- This function usually does not need to be overriden, only special
      -- LSP integration plugins like `rust-tools.nvim` need this.
      server_registration_override = function(server, opts)
        server:setup(opts)
      end,
    },
    treesitter = {},
    luasnip = {
      -- A set of paths to look up VSCode snippets in
      vscode_snippets_paths = {},
    },
    which_key = {},
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
  polish = function() end,
}

return config
