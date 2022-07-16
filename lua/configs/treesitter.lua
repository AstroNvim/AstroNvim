local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end
treesitter.setup(astronvim.user_plugin_opts("plugins.treesitter", {
  ensure_installed = {},
  sync_install = false,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  rainbow = {
    enable = true,
    disable = { "html" },
    extended_mode = false,
    max_file_lines = nil,
  },
  autopairs = { enable = true },
  autotag = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = false },
}))
