return function(_, opts)
  astronvim.lspkind = opts
  require("lspkind").init(opts)
end
