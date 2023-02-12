return function(_, opts)
  require("mason").setup(opts)
  for _, plugin in ipairs { "mason-lspconfig", "mason-null-ls" } do
    pcall(require, plugin)
  end
end
