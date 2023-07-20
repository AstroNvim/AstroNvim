return {
  "b0o/SchemaStore.nvim",
  {
    "AstroNvim/astrolsp",
    opts = function()
      local schemastore_avail, schemastore = pcall(require, "schemastore")
      return {
        features = {
          autoformat_enabled = true,
          codelens = true,
          diagnostics_mode = 3,
          inlay_hints = false,
          lsp_handlers = true,
          semantic_tokens = true,
        },
        capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
          textDocument = {
            completion = {
              completionItem = {
                documentationFormat = { "markdown", "plaintext" },
                snippetSupport = true,
                preselectSupport = true,
                insertReplaceSupport = true,
                labelDetailsSupport = true,
                deprecatedSupport = true,
                commitCharactersSupport = true,
                tagSupport = { valueSet = { 1 } },
                resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
              },
            },
            foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
          },
        }),
        config = {
          jsonls = {
            settings = {
              json = {
                schemas = schemastore_avail and schemastore.json.schemas() or nil,
                validate = { enable = schemastore_avail },
              },
            },
          },
          yamlls = { settings = { yaml = { schemas = schemastore_avail and schemastore.json.schemas() or nil } } },
          lua_ls = {
            before_init = function(param, config)
              if
                vim.b.neodev_enabled
                and type(astronvim) == "table"
                and type(astronvim.supported_configs) == "table"
              then
                for _, astronvim_config in ipairs(astronvim.supported_configs) do
                  if param.rootPath:match(astronvim_config) then
                    table.insert(config.settings.Lua.workspace.library, astronvim.install.home .. "/lua")
                    break
                  end
                end
              end
            end,
            settings = { Lua = { workspace = { checkThirdParty = false } } },
          },
        },
        diagnostics = {
          virtual_text = true,
          signs = {
            active = {
              { name = "DiagnosticSignError", text = "", texthl = "DiagnosticSignError" },
              { name = "DiagnosticSignHint", text = "󰌵", texthl = "DiagnosticSignHint" },
              { name = "DiagnosticSignInfo", text = "󰋼", texthl = "DiagnosticSignInfo" },
              { name = "DiagnosticSignWarn", text = "", texthl = "DiagnosticSignWarn" },
              { name = "DapBreakpoint", text = "", texthl = "DiagnosticInfo" },
              { name = "DapBreakpointCondition", text = "", texthl = "DiagnosticInfo" },
              { name = "DapBreakpointRejected", text = "", texthl = "DiagnosticError" },
              { name = "DapLogPoint", text = ".>", texthl = "DiagnosticInfo" },
              { name = "DapStopped", text = "󰁕", texthl = "DiagnosticWarn" },
            },
          },
          update_in_insert = true,
          underline = true,
          severity_sort = true,
          float = {
            focused = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        },
        flags = {},
        formatting = { format_on_save = { enabled = true }, disabled = {} },
        mappings = require("astrocore.utils").empty_map_table(),
        servers = {},
        setup_handlers = { function(server, opts) require("lspconfig")[server].setup(opts) end },
        on_attach = nil,
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
      if require("lazy.core.config").spec.plugins["neoconf.nvim"] then table.insert(cmds, "Neoconf") end
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
