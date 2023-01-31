return function(_, opts)
  local mason_nvim_dap = require "mason-nvim-dap"
  mason_nvim_dap.setup(opts)
  mason_nvim_dap.setup_handlers {}
end
