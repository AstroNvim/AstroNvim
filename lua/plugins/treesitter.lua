return astronvim.plugin {
  "nvim-treesitter/nvim-treesitter",
  init = function() table.insert(astronvim.file_plugins, "nvim-treesitter") end,
  cmd = {
    "TSBufDisable",
    "TSBufEnable",
    "TSBufToggle",
    "TSDisable",
    "TSEnable",
    "TSToggle",
    "TSInstall",
    "TSInstallInfo",
    "TSInstallSync",
    "TSModuleInfo",
    "TSUninstall",
    "TSUpdate",
    "TSUpdateSync",
  },
  dependencies = {
    astronvim.plugin "windwp/nvim-ts-autotag",
    astronvim.plugin "JoosepAlviste/nvim-ts-context-commentstring",
  },
  build = function() require("nvim-treesitter.install").update { with_sync = true }() end,
  opts = {
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
  },
  default_config = function(opts) require("nvim-treesitter.configs").setup(opts) end,
}
