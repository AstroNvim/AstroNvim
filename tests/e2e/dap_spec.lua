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

T["DAP-E2E-01 loads fixture launch configuration through nvim-dap"] = function()
  child = helpers.start_ready_child { "nvim-dap" }
  local project = helpers.fixture_project(child)
  local state = child.lua_get(([=[(function()
    local configure = require "astronvim.plugins.configs.nvim-dap"
    configure()
    local vscode = require "dap.ext.vscode"
    local configurations = vscode.getconfigs(vim.fs.joinpath(%s, ".vscode", "launch.json"))
    return {
      count = #configurations,
      name = configurations[1] and configurations[1].name,
      request = configurations[1] and configurations[1].request,
      type = configurations[1] and configurations[1].type,
    }
  end)()]=]):format(vim.inspect(project)))

  assert.same({ count = 1, name = "Fixture", request = "launch", type = "lua" }, state)
end

T["DAP-E2E-02 reports malformed launch configuration without breaking the child"] = function()
  child = helpers.start_ready_child { "nvim-dap" }
  local project = helpers.fixture_project(child)
  local state = child.lua_get(([=[(function()
    local configure = require "astronvim.plugins.configs.nvim-dap"
    configure()
    local vscode = require "dap.ext.vscode"
    local path = vim.fs.joinpath(%s, ".vscode", "launch.json")
    local error_count = 0
    for _, notification in ipairs(Snacks.notifier.get_history()) do
      if notification.level == "error" then error_count = error_count + 1 end
    end
    vim.fn.writefile({ "{ malformed" }, path)
    local configurations = vscode.getconfigs(path)
    return { configurations = configurations, error_count = error_count }
  end)()]=]):format(vim.inspect(project)))

  helpers.wait_until(
    child,
    ([[(function()
      local error_count = 0
      for _, notification in ipairs(Snacks.notifier.get_history()) do
        if notification.level == "error" then error_count = error_count + 1 end
      end
      return error_count > %d
    end)()]]):format(state.error_count),
    "DAP parse error notification"
  )

  local errors = child.lua_get [[(function()
    local messages = {}
    for _, notification in ipairs(Snacks.notifier.get_history()) do
      if notification.level == "error" then table.insert(messages, notification.msg) end
    end
    return messages
  end)()]]
  assert.same({}, state.configurations)
  assert.is_true(vim.tbl_contains(errors, "Error parsing `.vscode/launch.json`."), vim.inspect(errors))
  assert.is_true(child.is_running())
end

T["DAP-E2E-03 runs and terminates a hermetic adapter through AstroNvim mappings"] = function()
  child = helpers.start_ready_child { "nvim-dap", "nvim-dap-ui" }
  local project = helpers.fixture_project(child)
  local adapter = vim.fs.joinpath(config.root, "tests", "fixtures", "dap_adapter.lua")
  local source = vim.fs.joinpath(project, "dap-source.lua")
  local log = vim.fs.joinpath(project, "dap-events.jsonl")

  child.lua(([=[
    local dap = require "dap"
    vim.env.ASTRONVIM_E2E_DAP_LOG = %s
    vim.env.ASTRONVIM_E2E_DAP_SOURCE = %s
    dap.adapters.astronvim_fixture = {
      type = "executable",
      command = vim.v.progpath,
      args = { "-l", %s },
    }
    local source = %s
    local launch_path = vim.fs.joinpath(vim.fs.dirname(source), ".vscode", "launch.json")
    vim.fn.writefile({ vim.json.encode {
      version = "0.2.0",
      configurations = {
        {
          type = "astronvim_fixture",
          request = "launch",
          name = "AstroNvim fixture",
          program = source,
        },
      },
    } }, launch_path)
    vim.fn.writefile({ "return 1" }, source)
    vim.cmd.edit(vim.fn.fnameescape(source))
  ]=]):format(vim.inspect(log), vim.inspect(source), vim.inspect(adapter), vim.inspect(source)))

  local setup = child.lua_get [[{
    filetype = vim.bo.filetype,
    adapter = type(require("dap").adapters.astronvim_fixture),
    launch_file = vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), ".vscode", "launch.json")),
    mapping = (function()
      local mapping = vim.fn.maparg("<Leader>dc", "n", false, true)
      return { rhs = mapping.rhs, desc = mapping.desc, callback = type(mapping.callback) }
    end)(),
  }]]
  assert.equals("lua", setup.filetype)
  assert.equals("table", setup.adapter)
  assert.equals(1, setup.launch_file)
  assert.is_true(setup.mapping.callback == "function" or setup.mapping.rhs ~= "", vim.inspect(setup.mapping))

  child.lua [[
    local mapping = vim.fn.maparg("<Leader>dc", "n", false, true)
    assert(type(mapping.callback) == "function")
    mapping.callback()
  ]]
  helpers.wait_until(child, "require('dap').session() ~= nil", "DAP adapter session")
  helpers.wait_until(
    child,
    ([[(function()
      if vim.fn.filereadable(%s) == 0 then return false end
      local commands = {}
      for _, line in ipairs(vim.fn.readfile(%s)) do
        table.insert(commands, vim.json.decode(line).command)
      end
      return vim.tbl_contains(commands, "initialize")
        and vim.tbl_contains(commands, "launch")
        and vim.tbl_contains(commands, "configurationDone")
    end)()]]):format(vim.inspect(log), vim.inspect(log)),
    "DAP adapter initialization"
  )
  helpers.wait_until(child, "#vim.api.nvim_list_wins() > 1", "DAP UI open")

  local commands = child.lua_get(([[(function()
    local commands = {}
    if vim.fn.filereadable(%s) == 1 then
      for _, line in ipairs(vim.fn.readfile(%s)) do
        table.insert(commands, vim.json.decode(line).command)
      end
    end
    return commands
  end)()]]):format(vim.inspect(log), vim.inspect(log)))
  local expected_commands = { "initialize", "launch", "configurationDone", "threads", "stackTrace" }
  local allowed_commands = {
    initialize = true,
    launch = true,
    configurationDone = true,
    threads = true,
    stackTrace = true,
    scopes = true,
  }
  local expected_index = 1
  for _, command in ipairs(commands) do
    assert.is_true(allowed_commands[command], vim.inspect(commands))
    if command == expected_commands[expected_index] then expected_index = expected_index + 1 end
  end
  assert.equals(#expected_commands + 1, expected_index, vim.inspect(commands))

  child.lua [[
    local mapping = vim.fn.maparg("<Leader>dQ", "n", false, true)
    assert(type(mapping.callback) == "function")
    mapping.callback()
  ]]
  helpers.wait_until(child, "require('dap').session() == nil", "DAP session termination")
  helpers.wait_until(child, "#vim.api.nvim_list_wins() == 1", "DAP UI close")

  commands = child.lua_get(([[(function()
    local commands = {}
    for _, line in ipairs(vim.fn.readfile(%s)) do
      table.insert(commands, vim.json.decode(line).command)
    end
    return commands
  end)()]]):format(vim.inspect(log)))
  assert.equals("terminate", commands[#commands], vim.inspect(commands))
end

return T
