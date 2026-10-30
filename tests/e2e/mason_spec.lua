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

T["MASON-E2E-01 opens the live Mason UI with the AstroNvim registry"] = function()
  child = helpers.start_ready_child()

  child.lua [[vim.cmd "Mason"]]
  helpers.wait_until(child, "vim.bo.filetype == 'mason'", "Mason UI")

  local state = child.lua_get [[{
    filetype = vim.bo.filetype,
    registry_configured = vim.tbl_contains(
      require("mason.settings").current.registries,
      "github:mason-org/mason-registry"
    ),
    window_count = #vim.api.nvim_list_wins(),
  }]]

  assert.equals("mason", state.filetype)
  assert.is_true(state.registry_configured)
  assert.is_true(state.window_count >= 1)
  child.type_keys "q"
  helpers.wait_until(child, "vim.bo.filetype ~= 'mason'", "Mason UI close")
end

return T
