return function(plugin, opts)
  require(plugin.main).setup(opts)
  local hooks = require "ibl.hooks"
  hooks.register(hooks.type.ACTIVE, function(bufnr) return not vim.b[bufnr].large_buf end)
end
