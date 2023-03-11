return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
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
        null_ls.builtins.formatting.black.with { extra_args = { "--fast" } }, -- Python
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
    return config -- return final config table
  end,
}
