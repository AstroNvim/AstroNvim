return function(_, opts)
  for _, source in ipairs(opts.sources or {}) do
    if not source.group_index then source.group_index = 1 end
  end
  require("cmp").setup(opts)
end
