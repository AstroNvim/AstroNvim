return function(_, _)
  local setup_servers = function()
    vim.tbl_map(require("astrolsp").lsp_setup, require("astrolsp").config.servers)
    require("astrocore").exec_buffer_autocmds("FileType", { group = "lspconfig" })

    require("astrocore").event "LspSetup"
  end
  local astrocore = require "astrocore"
  if astrocore.is_available "mason-lspconfig.nvim" then
    astrocore.on_load("mason-lspconfig.nvim", setup_servers)
  else
    setup_servers()
  end
end
