return {
  { "folke/neodev.nvim", lazy = true, opts = {} },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>li"] =
            { "<Cmd>LspInfo<CR>", desc = "LSP information", cond = function() return vim.fn.exists ":LspInfo" > 0 end }
        end,
      },
      { "folke/neoconf.nvim", opts = {} },
      {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
        opts = function(_, opts)
          if not opts.handlers then opts.handlers = {} end
          opts.handlers[1] = function(server) require("astrolsp").lsp_setup(server) end
        end,
      },
    },
    cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
      if require("astrocore").is_available "neoconf.nvim" then table.insert(cmds, "Neoconf") end
      vim.list_extend(cmds, { "LspInfo", "LspLog", "LspStart" }) -- add normal `nvim-lspconfig` commands
    end,
    event = "User AstroFile",
    config = function(...) require "astronvim.plugins.configs.lspconfig"(...) end,
  },
  {
    "nvimtools/none-ls.nvim",
    main = "null-ls",
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>lI"] = {
            "<Cmd>NullLsInfo<CR>",
            desc = "Null-ls information",
            cond = function() return vim.fn.exists ":NullLsInfo" > 0 end,
          }
        end,
      },
      {
        "jay-babu/mason-null-ls.nvim",
        cmd = { "NullLsInstall", "NullLsUninstall" },
        init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
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
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>lS"] = { function() require("aerial").toggle() end, desc = "Symbols outline" }
        end,
      },
    },
    opts = function()
      local max_file = assert(require("astrocore").config.features.max_file)
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
