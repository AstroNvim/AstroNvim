return function(_, opts)
  local mason_null_ls = require "mason-null-ls"
  mason_null_ls.setup(opts)
  mason_null_ls.setup_handlers {}
end
