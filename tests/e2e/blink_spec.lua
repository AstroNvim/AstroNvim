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

T["BLINK-E2E-01 opens a real buffer completion menu"] = function()
  child = helpers.start_ready_child()
  child.lua [[
    vim.cmd.enew()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "astronvim", "" })
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
  ]]
  child.type_keys "i"
  child.type_keys "astr"
  helpers.wait_until(child, "vim.api.nvim_get_mode().mode == 'i'", "Blink insert mode")

  child.type_keys "<C-Space>"
  helpers.wait_until(child, "require('blink.cmp').is_menu_visible()", "Blink completion menu")
  assert.is_true(child.lua_get "require('blink.cmp').is_menu_visible()")
  child.lua [[require("blink.cmp").cancel()]]
end

return T
