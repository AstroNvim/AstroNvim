return function(_, _)
  local lsp = require "astronvim.utils.lsp"
  local get_icon = require("astronvim.utils").get_icon
  local signs = {
    { name = "DiagnosticSignError", text = get_icon "DiagnosticError", texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn", text = get_icon "DiagnosticWarn", texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignHint", text = get_icon "DiagnosticHint", texthl = "DiagnosticSignHint" },
    { name = "DiagnosticSignInfo", text = get_icon "DiagnosticInfo", texthl = "DiagnosticSignInfo" },
    { name = "DapStopped", text = get_icon "DapStopped", texthl = "DiagnosticWarn" },
    { name = "DapBreakpoint", text = get_icon "DapBreakpoint", texthl = "DiagnosticInfo" },
    { name = "DapBreakpointRejected", text = get_icon "DapBreakpointRejected", texthl = "DiagnosticError" },
    { name = "DapBreakpointCondition", text = get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
    { name = "DapLogPoint", text = get_icon "DapLogPoint", texthl = "DiagnosticInfo" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end
  lsp.setup_diagnostics(signs)

  if vim.g.lsp_handlers_enabled then
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true })
    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })
  end
  local setup_servers = function()
    vim.tbl_map(require("astronvim.utils.lsp").setup, astronvim.user_opts "lsp.servers")
    vim.api.nvim_exec_autocmds("FileType", {})
    require("astronvim.utils").event "LspSetup"
  end
  if require("astronvim.utils").is_available "mason-lspconfig.nvim" then
    vim.api.nvim_create_autocmd("User", { pattern = "AstroMasonLspSetup", once = true, callback = setup_servers })
  else
    setup_servers()
  end
end
