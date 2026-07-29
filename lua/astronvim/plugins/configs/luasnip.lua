return function(_, opts)
  if opts then require("luasnip").config.setup(opts) end
  for _, loader_type in pairs { "vscode", "snipmate", "lua" } do
    require("luasnip.loaders.from_" .. loader_type).lazy_load()
  end
end
