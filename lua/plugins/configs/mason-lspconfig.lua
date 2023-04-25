return function(_, opts)
  require("mason-lspconfig").setup(opts)
  require("astronvim.utils").event "MasonLspSetup"
end
