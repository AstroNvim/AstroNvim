return function(_, _)
  local astrocore = require "astrocore"
  local function setup_servers()
    local was_setup, astrolsp = {}, require "astrolsp"
    for _, server in ipairs(astrolsp.config.servers) do
      if not was_setup[server] then
        astrolsp.lsp_setup(server)
        was_setup[server] = true
      end
    end
    astrocore.exec_buffer_autocmds("FileType", { group = "lspconfig" })
    astrocore.event "LspSetup"
  end
  if astrocore.is_available "mason-lspconfig.nvim" then
    astrocore.on_load("mason-lspconfig.nvim", setup_servers)
  else
    setup_servers()
  end
end
