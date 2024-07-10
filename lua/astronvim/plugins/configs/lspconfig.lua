return function(_, _)
  local astrocore = require "astrocore"
  local setup_servers = function()
    local was_setup, astrolsp = {}, require "astrolsp"
    for _, server in ipairs(astrolsp.config.servers) do
      if not was_setup[server] then
        astrolsp.lsp_setup(server)
        was_setup[server] = true
      end
    end
    astrocore.exec_buffer_autocmds("FileType", { group = "lspconfig" })
    local editorconfig_avail, editorconfig = pcall(require, "editorconfig")
    if editorconfig_avail and vim.F.if_nil(vim.g.editorconfig, true) then -- re-apply editorconfig where necessary
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].editorconfig then editorconfig.config(bufnr) end
      end
    end
    astrocore.event "LspSetup"
  end
  if astrocore.is_available "mason-lspconfig.nvim" then
    astrocore.on_load("mason-lspconfig.nvim", setup_servers)
  else
    setup_servers()
  end
end
