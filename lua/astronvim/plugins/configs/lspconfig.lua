return function(_, _)
  local setup_servers = function()
    local was_setup, astrolsp = {}, require "astrolsp"
    for _, server in ipairs(astrolsp.config.servers) do
      if not was_setup[server] then
        astrolsp.lsp_setup(server)
        was_setup[server] = true
      end
    end
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
