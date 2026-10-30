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

local function start_blink_child()
  child = helpers.start_ready_child()
  child.lua [[require("lazy").load { plugins = { "blink.cmp" } }]]
end

local function open_buffer_completion()
  child.lua [[
    vim.cmd.enew()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "astronvim", "" })
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
  ]]
  child.type_keys "i"
  child.type_keys "astr"
  helpers.wait_until(
    child,
    "vim.api.nvim_get_mode().mode == 'i' and vim.api.nvim_get_current_line() == 'astr'",
    "Blink input"
  )
  child.type_keys "<C-Space>"
  helpers.wait_until(child, "#require('blink.cmp').get_items() > 0", "Blink completion items")
  helpers.wait_until(child, "require('blink.cmp').is_menu_visible()", "Blink completion menu")
end

T["BLINK-E2E-01 accepts a buffer completion through the configured mapping"] = function()
  start_blink_child()
  open_buffer_completion()

  child.lua [[require("blink.cmp").select_next()]]
  helpers.wait_until(child, "require('blink.cmp').get_selected_item_idx() ~= nil", "Blink selected completion")
  child.api.nvim_input "<CR>"
  helpers.wait_until(child, "not require('blink.cmp').is_menu_visible()", "Blink completion acceptance")
  assert.equals("astronvim", child.lua_get "vim.api.nvim_get_current_line()")
end

T["BLINK-E2E-02 hides a completion through the configured mapping"] = function()
  start_blink_child()
  open_buffer_completion()

  child.api.nvim_input "<C-e>"
  helpers.wait_until(child, "not require('blink.cmp').is_menu_visible()", "Blink completion cleanup")
end

return T
