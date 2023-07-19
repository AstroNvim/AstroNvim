return {
  "b0o/SchemaStore.nvim",
  {
    "AstroNvim/astrolsp",
    opts = function()
      local user_opts = astronvim.user_opts
      return { -- TODO: remove variables and `user_opts` here with AstroNvim v4
        features = {
          autoformat_enabled = vim.g.autoformat_enabled,
          codelens = vim.g.codelens_enabled,
          diagnostics_mode = vim.g.diagnostics_mode,
          inlay_hints = vim.g.inlay_hints_enabled,
          lsp_handlers = vim.g.lsp_handlers_enabled,
          semantic_tokens = vim.g.semantic_tokens_enabled,
        },
        capabilities = function(default) return user_opts("lsp.capabilities", default) end,
        diagnostics = function(default) return user_opts("diagnostics", default) end,
        flags = function(default) return user_opts("lsp.flags", default) end,
        formatting = function(default) return user_opts("lsp.formatting", default) end,
        mappings = function(default) return user_opts("lsp.mappings", default) end,
        servers = function(default) return user_opts("lsp.servers", default) end,
        setup_handlers = function(default) return user_opts("lsp.setup_handlers", default) end,
        on_attach = user_opts("lsp.on_attach", nil, false),
      }
    end,
  },
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
      if require("astronvim.utils").is_available "neoconf.nvim" then table.insert(cmds, "Neoconf") end
    end,
    event = "User AstroFile",
    config = require "plugins.configs.lspconfig",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "jay-babu/mason-null-ls.nvim",
      cmd = { "NullLsInstall", "NullLsUninstall" },
      opts = { handlers = {} },
    },
    event = "User AstroFile",
    opts = function() return { on_attach = require("astrolsp").on_attach } end,
  },
  {
    "stevearc/aerial.nvim",
    event = "User AstroFile",
    opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      disable_max_lines = vim.g.max_file.lines,
      disable_max_size = vim.g.max_file.size,
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
