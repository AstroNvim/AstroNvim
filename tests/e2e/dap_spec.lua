local MiniTest = require "mini.test"
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
    local path = vim.fs.joinpath(%s, ".vscode", "malformed.json")
    vim.fn.writefile({ "{ malformed" }, path)
    local configurations = vscode.getconfigs(path)
    vim.wait(100)
    local errors = {}
    for _, notification in ipairs(Snacks.notifier.get_history()) do
      if notification.level == "error" then table.insert(errors, notification.msg) end
    end
    return {
      configurations = configurations,
      errors = errors,
    }
  end)()]=]):format(vim.inspect(project)))

  assert.same({}, state.configurations)
  local found_error = false
  for _, message in ipairs(state.errors) do
    if message:find("Error parsing `.vscode/launch.json`", 1, true) then found_error = true end
  end
  assert.is_true(found_error, vim.inspect(state))
  assert.is_true(child.is_running())
end

return T
