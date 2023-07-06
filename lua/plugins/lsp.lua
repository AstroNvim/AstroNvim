return {
  "b0o/SchemaStore.nvim",
  {
    "folke/neodev.nvim",
    opts = {
      override = function(root_dir, library)
        for _, astronvim_config in ipairs(astronvim.supported_configs) do
          if root_dir:match(astronvim_config) then
            library.plugins = true
            break
          end
        end
        vim.b.neodev_enabled = library.enabled
      end,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        opts = function()
          local global_settings, file_found
          local _, depth = vim.fn.stdpath("config"):gsub("/", "")
          for _, dir in ipairs(astronvim.supported_configs) do
            dir = dir .. "/lua/user"
            if vim.fn.isdirectory(dir) == 1 then
              local path = dir .. "/neoconf.json"
              if vim.fn.filereadable(path) == 1 then
                file_found = true
                global_settings = path
              elseif not file_found then
                global_settings = path
              end
            end
          end
          return { global_settings = global_settings and string.rep("../", depth):sub(1, -2) .. global_settings }
        end,
        -- HACK: defer neoconf loading until after lspconfig is loaded but before servers are set up
        config = function() pcall(require, "lspconfig") end, -- actual setup happens in astronvim.utils.lsp
      },
      {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        opts = function(_, opts)
          if not opts.handlers then opts.handlers = {} end
          opts.handlers[1] = function(server) require("astronvim.utils.lsp").setup(server) end
        end,
        config = require "plugins.configs.mason-lspconfig",
      },
    },
    event = "User AstroFile",
    config = require "plugins.configs.lspconfig",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      {
        "jay-babu/mason-null-ls.nvim",
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts = { handlers = {} },
      },
    },
    event = "User AstroFile",
    opts = function() return { on_attach = require("astronvim.utils.lsp").on_attach } end,
  },
  {
    "stevearc/aerial.nvim",
    event = "User AstroFile",
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
