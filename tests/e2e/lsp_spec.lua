local MiniTest = require "mini.test"
local config = require "config"
local helpers = require "helpers"

local child
local T = MiniTest.new_set {
  hooks = {
    pre_case = function() child = nil end,
    post_case = function()
      helpers.stop_child(child)
      child = nil
    end,
  },
}

T["LSP-E2E-01 attaches a real local server, registers a capability, and formats"] = function()
  child = helpers.start_ready_child()
  local project = helpers.fixture_project(child)
  local server = vim.fs.joinpath(config.root, "tests", "fixtures", "lsp_server.lua")

  local state = child.lua_get(([=[(function()
    vim.cmd.edit(vim.fn.fnameescape(%s .. "/plain.txt"))
    vim.cmd [[doautocmd User AstroFile]]
    require("lazy").load { plugins = { "astrolsp" } }
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.fileOperations = {
      didCreate = { dynamicRegistration = true },
      didDelete = { dynamicRegistration = true },
      didRename = { dynamicRegistration = true },
      willCreate = { dynamicRegistration = true },
      willDelete = { dynamicRegistration = true },
      willRename = { dynamicRegistration = true },
    }
    local client_id = vim.lsp.start {
      name = "astronvim-e2e-lsp",
      cmd = { vim.v.progpath, "-l", %s },
      root_dir = %s,
      capabilities = capabilities,
    }
    return { client_id = client_id, buffer = vim.api.nvim_get_current_buf() }
  end)()]=]):format(vim.inspect(project), vim.inspect(server), vim.inspect(project)))

  helpers.wait_until(child, "#vim.lsp.get_clients({ name = 'astronvim-e2e-lsp' }) == 1", "real LSP client")
  local is_neovim_013 = child.lua_get "vim.fn.has('nvim-0.13') == 1"
  if is_neovim_013 then
    helpers.wait_until(
      child,
      "vim.lsp.get_clients({ name = 'astronvim-e2e-lsp' })[1]:supports_method('workspace/didCreateFiles')",
      "dynamic file-operation capability"
    )
  end

  child.lua [[vim.lsp.buf.format({ async = false, timeout_ms = 3000 })]]
  helpers.wait_until(
    child,
    "vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '-- formatted by e2e server'",
    "real formatter response"
  )

  local attached = child.lua_get [[(function()
    local clients = vim.lsp.get_clients({ name = "astronvim-e2e-lsp" })
    return {
      client_id = clients[1] and clients[1].id,
      buffer = vim.api.nvim_get_current_buf(),
      supports_formatting = clients[1] and clients[1]:supports_method("textDocument/formatting"),
      supports_file_operations = clients[1] and clients[1]:supports_method("workspace/didCreateFiles"),
    }
  end)()]]
  assert.equals(state.client_id, attached.client_id)
  assert.equals(state.buffer, attached.buffer)
  assert.is_true(attached.supports_formatting)
  if is_neovim_013 then assert.is_true(attached.supports_file_operations) end
end

return T
