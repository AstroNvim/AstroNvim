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

T["SESSION-E2E-01 saves and restores a real Resession session across child restart"] = function()
  child = helpers.start_ready_child { "resession.nvim" }
  local project = helpers.fixture_project(child)
  local plain = vim.fs.joinpath(project, "plain.txt")

  child.lua(([=[
    vim.cmd.edit(%s)
    require("resession").save("E2E Session", { notify = false })
  ]=]):format(vim.inspect(plain)))

  assert.is_true(child.lua_get "vim.tbl_contains(require('resession').list(), 'E2E Session')")
  child.lua "vim.cmd.enew()"
  assert.is_false(child.lua_get(([[vim.api.nvim_buf_get_name(0) == %s]]):format(vim.inspect(plain))))

  child.lua [[require("resession").load("E2E Session", { notify = false })]]
  helpers.wait_until(child, ([[vim.api.nvim_buf_get_name(0) == %s]]):format(vim.inspect(plain)), "session restore")

  helpers.restart_child(child)
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "restart readiness")
  child.lua [[require("lazy").load { plugins = { "resession.nvim" } }]]
  child.lua [[require("resession").load("E2E Session", { notify = false })]]
  helpers.wait_until(
    child,
    ([[vim.api.nvim_buf_get_name(0) == %s]]):format(vim.inspect(plain)),
    "session restore after restart"
  )
end

return T
