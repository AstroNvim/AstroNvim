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
        "astrolsp",
        opts = function(_, opts)
          local maps = opts.mappings
          if vim.fn.exists ":LspInfo" > 0 then
            maps.n["<leader>li"] = { "<cmd>LspInfo<cr>", desc = "LSP information" }
          end
        end,
      },
      {
        "folke/neoconf.nvim",
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
      },
      {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        opts = function(_, opts)
          if not opts.handlers then opts.handlers = {} end
          opts.handlers[1] = function(server) require("astrolsp").lsp_setup(server) end
        end,
        config = require "plugins.configs.mason-lspconfig",
      },
    },
    cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
      if require("lazy.core.config").spec.plugins["neoconf.nvim"] then table.insert(cmds, "Neoconf") end
    end,
    event = "User AstroFile",
    config = require "plugins.configs.lspconfig",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      {
        "astrolsp",
        opts = function(_, opts)
          local maps = opts.mappings
          if vim.fn.exists ":NullLsInfo" > 0 then
            maps.n["<leader>lI"] = { "<cmd>NullLsInfo<cr>", desc = "Null-ls information" }
          end
        end,
      },
      {
        "jay-babu/mason-null-ls.nvim",
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts = { handlers = {} },
      },
    },
    event = "User AstroFile",
    opts = function() return { on_attach = require("astrolsp").on_attach } end,
  },
  {
    "stevearc/aerial.nvim",
    event = "User AstroFile",
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "aerial.nvim" then
            maps.n["<leader>l"] = opts._map_section.l
            maps.n["<leader>lS"] = { function() require("aerial").toggle() end, desc = "Symbols outline" }
          end
        end,
      },
    },
    opts = function()
      local max_file = require("astrocore").config.features.max_file
      return {
        attach_mode = "global",
        backends = { "lsp", "treesitter", "markdown", "man" },
        disable_max_lines = max_file.lines,
        disable_max_size = max_file.size,
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
      }
    end,
  },
}
