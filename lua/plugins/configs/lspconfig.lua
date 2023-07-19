return function(_, _)
  local setup_servers = function()
    vim.tbl_map(require("astrolsp").lsp_setup, require("astrolsp").options.servers)
    vim.api.nvim_exec_autocmds("FileType", {})
    require("astronvim.utils").event "LspSetup"
  end
  if require("astronvim.utils").is_available "mason-lspconfig.nvim" then
    vim.api.nvim_create_autocmd("User", {
      desc = "set up LSP servers after mason-lspconfig",
      pattern = "AstroMasonLspSetup",
      once = true,
      callback = setup_servers,
    })
  else
    setup_servers()
  end
end
