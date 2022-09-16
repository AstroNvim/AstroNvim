local config = {
  options = {
    g = {
      tokyonight_style = "night",
      tokyonight_transparent = true,
      catppuccin_flavour = "mocha", -- latte(lightmode, gross), frappe, macchiato, mocha,
      transparent_background = true,
    },
  },

  colorscheme = "catppuccin",

  plugins = {
    init = {
      { "folke/tokyonight.nvim" },
      { "catppuccin/nvim", as = "catppuccin", config = function()
        require("catppuccin").setup({
          transparent_background = true,
          term_colors = true,
          compile = {
              enabled = true,
              path = vim.fn.stdpath("cache") .. "/catppuccin",
          },
          styles = {
              comments = { "italic" },
              -- strings = { "italic" },
          },
          integrations = {
              gitsigns = true,
              telescope = true,
              treesitter = true,
              cmp = true,
              nvimtree = {
                  enabled = true,
                  show_root = false,
              },
              dap = {
                  enabled = true,
                  enable_ui = true,
              },
              native_lsp = {
                  enabled = true,
              },
              ts_rainbow = true,
              indent_blankline = {
                  enabled = true,
                  colored_indent_levels = false,
              },
          }, 
        })
      end },
    },

    ["null-ls"] = function()
        local null_ls = require "null-ls"
        return {
          sources = {
            null_ls.builtins.formatting.prettier,
          },
          on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
              vim.api.nvim_create_autocmd("BufWritePre", {
                desc = "Auto format before save",
                pattern = "<buffer>",
                callback = function() vim.lsp.buf.formatting_sync() end,
              })
            end
          end,
        }
      end,
  },
}

return config
