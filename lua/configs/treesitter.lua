local M = {}

function M.config()
  local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if status_ok then
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
      autopairs = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = false,
      },
      rainbow = {
        enable = true,
        disable = { "html" },
        extended_mode = false,
        max_file_lines = nil,
      },
      autotag = {
        enable = true,
      },
    }))
  end
end

return M
