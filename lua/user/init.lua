return {
  colorscheme = "duskfox",
  -- Set dashboard header
  header = {
    " ",
    " ",
    " ",
    " ",
    " ",
    "██████ ██████    ███    ██████  ██      ██████  ██████  ██████",
    "██     ██       ██ ██   ██  ██  ██      ██      ██      ██    ",
    "█████  █████   ███████  ██████  ██      █████   ██████  ██████",
    "██     ██      ██   ██  ██ ██   ██      ██          ██      ██",
    "██     ██████  ██   ██  ██  ██  ██████  ██████  ██████  ██████",
    " ",
    "              ███    ██ ██    ██ ██ ███    ███",
    "              ████   ██ ██    ██ ██ ████  ████",
    "              ██ ██  ██ ██    ██ ██ ██ ████ ██",
    "              ██  ██ ██  ██  ██  ██ ██  ██  ██",
    "              ██   ████   ████   ██ ██      ██",
    " ",
    " ",
    " ",
  },
  plugins = {
    init = {
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
    },
    ["null-ls"] = function(config)
      local null_ls = require "null-ls"
      -- Check supported formatters and linters
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
      config.sources = {
        null_ls.builtins.formatting.astyle, -- C/C++
        null_ls.builtins.formatting.erlfmt, -- Erlang
        null_ls.builtins.formatting.stylua, -- Lua
        null_ls.builtins.formatting.shfmt, -- Shell
        null_ls.builtins.formatting.black, -- Python
        null_ls.builtins.formatting.isort, -- Python
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
        null_ls.builtins.diagnostics.rubocop, -- Ruby
        null_ls.builtins.diagnostics.checkmake, -- Makefile
        null_ls.builtins.diagnostics.tsc, -- Typescript
        null_ls.builtins.diagnostics.cppcheck, -- C/C++
        null_ls.builtins.diagnostics.credo, -- Elixir
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
        null_ls.builtins.hover.dictionary
      }
      -- set up null-ls's on_attach function
      return config -- return final config table
    end,
    treesitter = {
      ensure_installed = {
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
        "dockerfile"
      },
    },
    ["nvim-lsp-installer"] = {
      ensure_installed = {
        "sumneko_lua",
        "clangd",
        "dockerls",
        "eslint",
        "elixirls",
        "erlangls",
        "golangci_lint_ls",
        "graphql",
        "html",
        "jsonls",
        "jdtls",
        "intelephense",
        "pyright",
        "solargraph",
        "rust_analyzer"
      },
    },
  },
}
