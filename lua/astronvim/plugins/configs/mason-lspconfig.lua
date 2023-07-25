return function(_, opts)
  require("mason-lspconfig").setup(opts)
  require("astrocore.utils").event "MasonLspSetup"
end
