-- customize mason plugins
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
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
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
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
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      ensure_installed = {
          "python",
         "lua",
         "elixir"
      },
    },
  },
}
