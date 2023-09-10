return {
  --background = dark,
  --colorscheme = "sonokai",
  --colorscheme = "PaperColor",
  --colorscheme = "gruvbox",
  colorscheme = "ayu",
  plugins = {
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
  },
}
