return {
  "b0o/SchemaStore.nvim",
  {
    "folke/neodev.nvim",
    opts = {
      override = function(root_dir, library)
        if root_dir:match(astronvim.install.config) then library.plugins = true end
        vim.b.neodev_enabled = library.enabled
      end,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        config = require "plugins.configs.mason-lspconfig",
      },
    },
    init = function() table.insert(astronvim.file_plugins, "nvim-lspconfig") end,
    config = require "plugins.configs.lspconfig",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      {
        "jay-babu/mason-null-ls.nvim",
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts = { automatic_setup = true },
        config = require "plugins.configs.mason-null-ls",
      },
    },
    init = function() table.insert(astronvim.file_plugins, "null-ls.nvim") end,
    opts = function() return { on_attach = require("core.utils.lsp").on_attach } end,
  },
  {
    "stevearc/aerial.nvim",
    init = function() table.insert(astronvim.file_plugins, "aerial.nvim") end,
    opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { min_width = 28 },
      show_guides = true,
      filter_kind = false,
      guides = {
        mid_item = "├ ",
        last_item = "└ ",
        nested_top = "│ ",
        whitespace = "  ",
      },
      keymaps = {
        ["[y"] = "actions.prev",
        ["]y"] = "actions.next",
        ["[Y"] = "actions.prev_up",
        ["]Y"] = "actions.next_up",
        ["{"] = false,
        ["}"] = false,
        ["[["] = false,
        ["]]"] = false,
      },
    },
  },
}
