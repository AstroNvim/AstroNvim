return {
  colorscheme = "sonokai",
  plugins = {
    {
      "sainnhe/sonokai",
      init = function() -- init function runs before the plugin is loaded
        vim.g.sonokai_style = "atlantis"
      end,
    },
  },
}
