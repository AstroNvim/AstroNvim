return function(_, opts)
  require("mason").setup(opts)
  vim.tbl_map(function(mod) pcall(require, mod) end, { "mason-lspconfig", "mason-null-ls", "mason-nvim-dap" })
end
