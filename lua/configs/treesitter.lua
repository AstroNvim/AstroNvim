require("nvim-treesitter.configs").setup(astronvim.user_plugin_opts("plugins.treesitter", {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  autotag = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = false },
}))
