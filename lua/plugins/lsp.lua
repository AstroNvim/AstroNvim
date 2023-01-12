return {
  "b0o/SchemaStore.nvim",
  {
    "folke/neodev.nvim",
    version = "^1",
    opts = { library = { plugins = false }, lspconfig = false },
    default_config = function(opts) require("neodev").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function() table.insert(astronvim.file_plugins, "nvim-lspconfig") end,
    default_config = function(_)
      if vim.g.lsp_handlers_enabled then
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      end
      local setup_servers = function()
        vim.tbl_map(astronvim.lsp.setup, astronvim.user_opts "lsp.servers")
        vim.api.nvim_exec_autocmds("FileType", {})
      end
      if astronvim.is_available "mason-lspconfig.nvim" then
        vim.api.nvim_create_autocmd("User", { pattern = "AstroLspSetup", once = true, callback = setup_servers })
      else
        setup_servers()
      end
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    init = function() table.insert(astronvim.file_plugins, "null-ls.nvim") end,
    opts = { on_attach = astronvim.lsp.on_attach },
    default_config = function(opts) require("null-ls").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
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
    default_config = function(opts) require("aerial").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
}
