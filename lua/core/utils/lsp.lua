--- ### AstroNvim LSP
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.lsp`
--
-- This module can also be manually loaded with `local updater = require("core.utils").lsp`
--
-- @module core.utils.lsp
-- @see core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

astronvim.lsp = {}
local sign_define = vim.fn.sign_define
local tbl_contains = vim.tbl_contains
local user_plugin_opts = astronvim.user_plugin_opts
local conditional_func = astronvim.conditional_func
local user_registration = user_plugin_opts("lsp.server_registration", nil, false)
local skip_setup = user_plugin_opts "lsp.skip_setup"

local signs = {
  { name = "DiagnosticSignError", text = astronvim.get_icon "DiagnosticError" },
  { name = "DiagnosticSignWarn", text = astronvim.get_icon "DiagnosticWarn" },
  { name = "DiagnosticSignHint", text = astronvim.get_icon "DiagnosticHint" },
  { name = "DiagnosticSignInfo", text = astronvim.get_icon "DiagnosticInfo" },
}
for _, sign in ipairs(signs) do
  sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

astronvim.lsp.formatting = astronvim.user_plugin_opts("lsp.formatting", { format_on_save = true, disabled = {} })

astronvim.lsp.format_opts = vim.deepcopy(astronvim.lsp.formatting)
astronvim.lsp.format_opts.disabled = nil
astronvim.lsp.format_opts.filter = function(client)
  local filter = astronvim.lsp.formatting.filter
  local disabled = astronvim.lsp.formatting.disabled
  -- if client is fully disabled, return false
  if vim.tbl_contains(disabled, client.name) then return false end
  -- if filter function is defined and client is filtered out, return false
  if type(filter) == "function" and not filter(client) then return false end
  -- client has passed all checks, enable it for formatting
  return true
end

astronvim.lsp.diagnostics = {
  off = {
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  },
  on = user_plugin_opts("diagnostics", {
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }),
}

--- Helper function to set up a given server with the Neovim LSP client
-- @param server the name of the server to be setup
astronvim.lsp.setup = function(server)
  if not tbl_contains(skip_setup, server) then
    local opts = astronvim.lsp.server_settings(server)
    if type(user_registration) == "function" then
      user_registration(server, opts)
    else
      require("lspconfig")[server].setup(opts)
    end
  end
end

--- The `on_attach` function used by AstroNvim
-- @param client the LSP client details when attaching
-- @param bufnr the number of the buffer that the LSP client is attaching to
astronvim.lsp.on_attach = function(client, bufnr)
  local capabilities = client.server_capabilities
  local lsp_mappings = {
    n = {
      ["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
      ["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
      ["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
      ["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
    },
    v = {},
  }

  if capabilities.codeActionProvider then
    lsp_mappings.n["<leader>la"] = { function() vim.lsp.buf.code_action() end, desc = "LSP code action" }
    lsp_mappings.v["<leader>la"] = lsp_mappings.n["<leader>la"]
  end

  if capabilities.declarationProvider then
    lsp_mappings.n["gD"] = { function() vim.lsp.buf.declaration() end, desc = "Declaration of current symbol" }
  end

  if capabilities.definitionProvider then
    lsp_mappings.n["gd"] = { function() vim.lsp.buf.definition() end, desc = "Show the definition of current symbol" }
  end

  if capabilities.documentFormattingProvider then
    lsp_mappings.n["<leader>lf"] = {
      function() vim.lsp.buf.format(astronvim.lsp.format_opts) end,
      desc = "Format code",
    }
    lsp_mappings.v["<leader>lf"] = lsp_mappings.n["<leader>lf"]

    vim.api.nvim_buf_create_user_command(
      bufnr,
      "Format",
      function() vim.lsp.buf.format(astronvim.lsp.format_opts) end,
      { desc = "Format file with LSP" }
    )
    if astronvim.lsp.formatting.format_on_save then
      local autocmd_group = "auto_format_" .. bufnr
      vim.api.nvim_create_augroup(autocmd_group, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = autocmd_group,
        buffer = bufnr,
        desc = "Auto format buffer " .. bufnr .. " before save",
        callback = function() vim.lsp.buf.format(astronvim.default_tbl({ bufnr = bufnr }, astronvim.lsp.format_opts)) end,
      })
    end
  end

  if capabilities.documentHighlightProvider then
    local highlight_name = vim.fn.printf("lsp_document_highlight_%d", bufnr)
    vim.api.nvim_create_augroup(highlight_name, {})
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = highlight_name,
      buffer = bufnr,
      callback = function() vim.lsp.buf.document_highlight() end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = highlight_name,
      buffer = bufnr,
      callback = function() vim.lsp.buf.clear_references() end,
    })
  end

  if capabilities.hoverProvider then
    lsp_mappings.n["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details" }
  end

  if capabilities.implementationProvider then
    lsp_mappings.n["gI"] = { function() vim.lsp.buf.implementation() end, desc = "Implementation of current symbol" }
  end

  if capabilities.referencesProvider then
    lsp_mappings.n["gr"] = { function() vim.lsp.buf.references() end, desc = "References of current symbol" }
  end

  if capabilities.renameProvider then
    lsp_mappings.n["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename current symbol" }
  end

  if capabilities.signatureHelpProvider then
    lsp_mappings.n["<leader>lh"] = { function() vim.lsp.buf.signature_help() end, desc = "Signature help" }
  end

  if capabilities.typeDefinitionProvider then
    lsp_mappings.n["gT"] = { function() vim.lsp.buf.type_definition() end, desc = "Definition of current type" }
  end

  astronvim.set_mappings(user_plugin_opts("lsp.mappings", lsp_mappings), { buffer = bufnr })
  if not vim.tbl_isempty(lsp_mappings.v) then
    astronvim.which_key_register({ v = { ["<leader>"] = { l = { name = "LSP" } } } }, { buffer = bufnr })
  end

  local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
  local aerial_avail, aerial = pcall(require, "aerial")
  conditional_func(on_attach_override, true, client, bufnr)
  conditional_func(aerial.on_attach, aerial_avail, client, bufnr)
end

--- The default AstroNvim LSP capabilities
astronvim.lsp.capabilities = vim.lsp.protocol.make_client_capabilities()
astronvim.lsp.capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
astronvim.lsp.capabilities.textDocument.completion.completionItem.snippetSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.preselectSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
astronvim.lsp.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
astronvim.lsp.capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
astronvim.lsp.capabilities = user_plugin_opts("lsp.capabilities", astronvim.lsp.capabilities)
astronvim.lsp.flags = user_plugin_opts "lsp.flags"

--- Get the server settings for a given language server to be provided to the server's `setup()` call
-- @param  server_name the name of the server
-- @return the table of LSP options used when setting up the given language server
function astronvim.lsp.server_settings(server_name)
  local server = require("lspconfig")[server_name]
  local opts = user_plugin_opts( -- get user server-settings
    "lsp.server-settings." .. server_name,
    user_plugin_opts("server-settings." .. server_name, { -- get default server-settings
      capabilities = vim.tbl_deep_extend("force", astronvim.lsp.capabilities, server.capabilities or {}),
      flags = vim.tbl_deep_extend("force", astronvim.lsp.flags, server.flags or {}),
    }, true, "configs")
  )
  local old_on_attach = server.on_attach
  local user_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    conditional_func(old_on_attach, true, client, bufnr)
    astronvim.lsp.on_attach(client, bufnr)
    conditional_func(user_on_attach, true, client, bufnr)
  end
  return opts
end

return astronvim.lsp
