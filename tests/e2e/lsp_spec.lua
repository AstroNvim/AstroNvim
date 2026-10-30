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
    local project = %s
    local server = %s
    vim.cmd.edit(vim.fn.fnameescape(project .. "/plain.txt"))
    require("lazy").load { plugins = { "astrolsp" } }
    vim.cmd [[doautocmd User AstroFile]]
    local log_path = vim.fs.joinpath(project, "lsp-events.jsonl")
    vim.env.ASTRONVIM_E2E_LSP_LOG = log_path
    vim.lsp.config("astronvim-e2e-lsp", {
      cmd = { vim.v.progpath, "-l", server },
      root_dir = project,
      filetypes = { "text" },
    })
    local client_id = vim.lsp.start(vim.lsp.config["astronvim-e2e-lsp"])
    return { client_id = client_id, buffer = vim.api.nvim_get_current_buf(), log_path = log_path }
  end)()]=]):format(vim.inspect(project), vim.inspect(server)))

  helpers.wait_until(child, "#vim.lsp.get_clients({ name = 'astronvim-e2e-lsp' }) == 1", "real LSP client")
  helpers.wait_until(
    child,
    "vim.lsp.get_clients({ name = 'astronvim-e2e-lsp' })[1]:supports_method('textDocument/formatting')",
    "real formatter capability"
  )
  local is_neovim_013 = child.lua_get "vim.fn.has('nvim-0.13') == 1"
  if is_neovim_013 then
    helpers.wait_until(
      child,
      "vim.lsp.get_clients({ name = 'astronvim-e2e-lsp' })[1]:supports_method('workspace/didCreateFiles')",
      "dynamic file-operation capability"
    )
  end

  helpers.wait_until(
    child,
    ([[(function()
      if vim.fn.filereadable(%s) == 0 then return false end
      for _, line in ipairs(vim.fn.readfile(%s)) do
        if vim.json.decode(line).method == "initialize" then return true end
      end
      return false
    end)()]]):format(vim.inspect(state.log_path), vim.inspect(state.log_path)),
    "LSP initialize request"
  )
  local file_operations = child.lua_get(([[(function()
    for _, line in ipairs(vim.fn.readfile(%s)) do
      local event = vim.json.decode(line)
      if event.method == "initialize" then return event.file_operations end
    end
  end)()]]):format(vim.inspect(state.log_path)))
  assert.same({
    dynamicRegistration = true,
    didCreate = true,
    didDelete = true,
    didRename = true,
    willCreate = true,
    willDelete = true,
    willRename = true,
  }, file_operations)

  child.lua [[vim.lsp.buf.format({ async = false, timeout_ms = 3000 })]]
  helpers.wait_until(
    child,
    "vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '-- formatted by e2e server'",
    "real formatter response"
  )

  local created_path = vim.fs.joinpath(project, "lsp-created.txt")
  child.lua(([=[
    vim.api.nvim_buf_set_name(0, %s)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "created through AstroLSP" })
    vim.cmd.write()
  ]=]):format(vim.inspect(created_path)))

  if is_neovim_013 then
    helpers.wait_until(
      child,
      ([[(function()
        if vim.fn.filereadable(%s) == 0 then return false end
        local events = {}
        for _, line in ipairs(vim.fn.readfile(%s)) do
          local event = vim.json.decode(line)
          if event.method == "workspace/willCreateFiles" or event.method == "workspace/didCreateFiles" then
            table.insert(events, event)
          end
        end
        return #events >= 2
          and events[1].method == "workspace/willCreateFiles"
          and events[2].method == "workspace/didCreateFiles"
      end)()]]):format(vim.inspect(state.log_path), vim.inspect(state.log_path)),
      "AstroLSP file creation notifications"
    )
    local operations = child.lua_get(([[(function()
      local operations = {}
      for _, line in ipairs(vim.fn.readfile(%s)) do
        local event = vim.json.decode(line)
        if event.method == "workspace/willCreateFiles" or event.method == "workspace/didCreateFiles" then
          table.insert(operations, event)
        end
      end
      return operations
    end)()]]):format(vim.inspect(state.log_path)))
    assert.equals(2, #operations)
    assert.equals("workspace/willCreateFiles", operations[1].method)
    assert.equals("workspace/didCreateFiles", operations[2].method)
    assert.equals("lsp-created.txt", vim.fs.basename(vim.uri_to_fname(operations[1].uri)))
    assert.equals("lsp-created.txt", vim.fs.basename(vim.uri_to_fname(operations[2].uri)))
  else
    local lines = child.lua_get "vim.fn.readfile(vim.api.nvim_buf_get_name(0))"
    assert.is_true(vim.tbl_contains(lines, "created through AstroLSP"), vim.inspect(lines))
  end

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
