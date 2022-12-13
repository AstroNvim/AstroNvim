return {
  colorscheme = "tokyonight",
  -- Set dashboard header
  header = {
    "           ██████ ██████    ███    ██████  ██      ██████  ██████  ██████            ",
    "           ██     ██       ██ ██   ██  ██  ██      ██      ██      ██                ",
    "           █████  █████   ███████  ██████  ██      █████   ██████  ██████            ",
    "           ██     ██      ██   ██  ██ ██   ██      ██          ██      ██            ",
    "           ██     ██████  ██   ██  ██  ██  ██████  ██████  ██████  ██████            ",
    " ",
    "                                                                                     ",
    "                                                                                     ",
    "                               ▒▒                  ▒▒                                ",
    "                             ▒▒██▒▒              ▒▒██▒▒                              ",
    "                             ▒▒██▒▒              ▒▒██▒▒                              ",
    "                         ▒▒  ▒▒██▒▒              ▒▒██▒▒  ▒▒                          ",
    "                       ▒▒██▒▒▒▒██▒▒              ▒▒██▒▒▒▒██▒▒                        ",
    "                       ▒▒██▒▒▒▒▒▒██▒▒  ▒▒  ▒▒  ▒▒██▒▒▒▒▒▒██▒▒                        ",
    "                         ▒▒██▒▒▒▒██▒▒▒▒██▒▒██▒▒▒▒██▒▒▒▒██▒▒                          ",
    "                         ▒▒██▒▒▒▒██▒▒▒▒██▒▒██▒▒▒▒██▒▒▒▒██▒▒                          ",
    "                         ▒▒██▒▒▒▒▒▒██▒▒██████▒▒██▒▒▒▒▒▒██▒▒                          ",
    "                           ▒▒██▒▒▒▒▒▒██████████▒▒▒▒▒▒██▒▒                            ",
    "                             ▒▒██████████████████████▒▒                              ",
    "                               ▒▒▒▒▒▒██████████▒▒▒▒▒▒                                ",
    "                             ▒▒██████▒▒██████▒▒██████▒▒                              ",
    "                           ▒▒██▒▒▒▒▒▒██████████▒▒▒▒▒▒██▒▒                            ",
    "                         ▒▒██▒▒▒▒▒▒██████████████▒▒▒▒▒▒██▒▒                          ",
    "                         ▒▒██▒▒▒▒██▒▒██████████▒▒██▒▒▒▒██▒▒                          ",
    "                       ▒▒██▒▒▒▒██▒▒████▒▒▒▒▒▒████▒▒██▒▒▒▒██▒▒                        ",
    "                       ▒▒██▒▒▒▒██▒▒██████▒▒██████▒▒██▒▒▒▒██▒▒                        ",
    "                       ▒▒██▒▒▒▒██▒▒██████▒▒██████▒▒██▒▒▒▒██▒▒                        ",
    "                         ▒▒▒▒▒▒██▒▒████▒▒▒▒▒▒████▒▒██▒▒▒▒▒▒                          ",
    "                           ▒▒██▒▒  ▒▒██████████▒▒  ▒▒██▒▒                            ",
    "                           ▒▒██▒▒    ▒▒██████▒▒    ▒▒██▒▒                            ",
    "                           ▒▒██▒▒      ▒▒██▒▒      ▒▒██▒▒                            ",
    "                           ▒▒██▒▒        ▒▒        ▒▒██▒▒                            ",
    "                             ▒▒                      ▒▒                              ",
    "                                                                                     ",
    "            Spiders are the only web developers that enjoy finding bugs.             ",
  },
  lsp = {
    formatting = {
      format_on_save = false, -- enable or disable automatic formatting on save
      timeout_ms = 20000,
    },
    skip_setup = { "clangd" },
    ["server-settings"] = {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
      },
      elixirLS = {
        -- I choose to disable dialyzer for personal reasons, but
        -- I would suggest you also disable it unless you are well
        -- aquainted with dialzyer and know how to use it.
        dialyzerEnabled = false,
        -- I also choose to turn off the auto dep fetching feature.
        -- It often get's into a weird state that requires deleting
        -- the .elixir_ls directory and restarting your editor.
        fetchDeps = false
      }
    },
  },
  plugins = {
    init = {
      {
        "windwp/windline.nvim",
        config = function()
          --require('configs.fearless')
          require "wlsample.airline_anim"
        end,
      },
      {
        "psliwka/vim-smoothie",
      },
      {
        "folke/tokyonight.nvim",
        config = function()
          require("tokyonight").setup {
            style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
            light_style = "day", -- The theme is used when the background is set to light
            transparent = false, -- Enable this to disable setting the background color
            terminal_colors = true,
          }
        end
      },
      {
        "EdenEast/nightfox.nvim",
        config = function()
          require("nightfox").setup {
            -- disable extra plugins that AstroNvim doesn't use (this is optional)
            modules = {
              barbar = false,
              dashboard = false,
              fern = false,
              fidget = false,
              gitgutter = false,
              glyph_palette = false,
              illuminate = false,
              lightspeed = false,
              lsp_saga = false,
              lsp_trouble = false,
              modes = false,
              neogit = false,
              nvimtree = false,
              pounce = false,
              sneak = false,
              symbols_outline = false,
            },
            groups = {
              all = {
                -- add highlight group for AstroNvim's built in URL highlighting
                HighlightURL = { style = "underline" },
              },
            },
          }
        end,
      },
      {
        "mfussenegger/nvim-dap-python",
      },
      -- Rust support
      {
        "simrat39/rust-tools.nvim",
        after = { "mason-lspconfig.nvim" },
        -- Is configured via the server_registration_override installed below!
        config = function()
          require("rust-tools").setup {
            server = astronvim.lsp.server_settings "rust_analyzer",
            tools = {
              inlay_hints = {
                parameter_hints_prefix = "  ",
                other_hints_prefix = "  ",
              },
            },
          }
        end,
      },
      --{
      --  "nvim-neorg/neorg",
      --  after = { "nvim-treesitter" },
      -- Is configured via the server_registration_override installed below!
      --  config = function()
      --    require("neorg").setup {
      --      load = {
      --        ["core.defaults"] = {},
      --        ["core.norg.concealer"] = {},
      --        ["core.keybinds"] = {},
      --        ["core.gtd.base"] = {
      --          config = {
      --            workspace = "work",
      --          }
      --        },
      --        ["core.gtd.ui"] = {},
      --        ["core.gtd.helpers"] = {},
      --        ["core.norg.dirman"] = {
      --          config = {
      --            workspaces = {
      --              work = "~/notes/work",
      --              home = "~/notes/home",
      --            }
      --          }
      --        }
      --      }
      --    }
      --  end,
      --},
    },
    ["null-ls"] = function(config)
      local null_ls = require "null-ls"
      config.default_timeout = 20000
      -- Check supported formatters and linters
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
      config.sources = {
        null_ls.builtins.formatting.astyle, -- C/C++
        null_ls.builtins.formatting.erlfmt, -- Erlang
        null_ls.builtins.formatting.mix.with {
          filetypes = {
            "elixir",
            "ex",
            "exs",
            "heex",
          },
        }, -- Mix
        null_ls.builtins.formatting.stylua, -- Lua
        null_ls.builtins.formatting.shfmt, -- Shell
        null_ls.builtins.formatting.black, -- Python
        null_ls.builtins.formatting.isort, -- Python
        null_ls.builtins.formatting.gofmt, -- GO
        null_ls.builtins.formatting.surface, -- Phoenix
        null_ls.builtins.formatting.prettierd.with {
          filetypes = {
            "javascript",
            "typescript",
            "css",
            "scss",
            "html",
            "yaml",
            "markdown",
            "json",
            "svelte",
            "toml",
          },
        },
        -- Linters
        null_ls.builtins.diagnostics.credo, -- Elixir
        null_ls.builtins.diagnostics.rubocop, -- Ruby
        null_ls.builtins.diagnostics.checkmake, -- Makefile
        null_ls.builtins.diagnostics.tsc, -- Typescript
        null_ls.builtins.diagnostics.cppcheck, -- C/C++
        null_ls.builtins.diagnostics.eslint, -- JavaScript
        null_ls.builtins.diagnostics.flake8, -- Python
        null_ls.builtins.diagnostics.gitlint, -- Git
        null_ls.builtins.diagnostics.golangci_lint, -- Go
        null_ls.builtins.diagnostics.hadolint, -- Dockerfile
        null_ls.builtins.diagnostics.markdownlint, -- Markdown
        null_ls.builtins.diagnostics.stylelint, -- SCSS
        null_ls.builtins.diagnostics.shellcheck.with {
          diagnostics_format = "#{m} [#{c}]",
        },
        null_ls.builtins.diagnostics.luacheck.with {
          extra_args = { "--global vim" },
        },
        null_ls.builtins.diagnostics.write_good, -- English
        -- Code Actions
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.shellcheck,
        -- Hover
        null_ls.builtins.hover.dictionary,
      }
      -- set up null-ls's on_attach function
      return config -- return final config table
    end,
    treesitter = {
      highlight = {
        enable = true,
      },
      ensure_installed = {
        --"norg",
        "bash",
        "haskell",
        "markdown",
        "toml",
        "yaml",
        "lua",
        "python",
        "java",
        "javascript",
        "typescript",
        "c",
        "cpp",
        "rust",
        "scss",
        "swift",
        "ruby",
        "php",
        "make",
        "json",
        "html",
        "graphql",
        "go",
        "erlang",
        "elixir",
        "eex",
        "heex",
        "surface",
        "dockerfile",
      },
    },
    ["mason-lspconfig"] = {
      ensure_installed = {
        "sumneko_lua",
        "clangd",
        "dockerls",
        "eslint",
        "elixirls",
        "erlangls",
        "gopls",
        "graphql",
        "html",
        "jsonls",
        "jdtls",
        "intelephense",
        "pyright",
        "solargraph",
        "rust_analyzer",
      },
    },
    ["mason-null-ls"] = { -- overrides `require("mason-null-ls").setup(...)`
      ensure_installed = {
        "prettier",
        "stylua",
        "clang_format",
        "hadolint",
        "djlint",
        "fixjson",
        "write_good",
        "black",
        "shfmt",
      },
    },
    ["neo-tree"] = {
      window = {
        width = 50,
      },
    },
  },
  mappings = {
    n = {
      -- NeoTest
      ["<leader>T"] = { "Tests" },
      ["<leader>Tn"] = {
        function() require("neotest").run.run() end,
        desc = "Run nearest test",
      },
      ["<leader>Tf"] = {
        function() require("neotest").run.run(vim.fn.expand "%") end,
        desc = "Run tests in current file",
      },
      ["<leader>To"] = {
        function() require("neotest").output.open() end,
        desc = "Display output of tests",
      },
      ["<leader>Ts"] = {
        function() require("neotest").summary.toggle() end,
        desc = "Open the summary window",
      },
    },
  },
  --polish = function ()
  --  vim.lsp.get_client_by_id(1)
  --  vim.opt.laststatus = 2
  --end,
}
