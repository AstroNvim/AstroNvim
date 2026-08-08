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

local function start_ready_child()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")
end

local function editor_state()
  return child.lua_get [[(function()
    local prompt_windows = 0
    for _, window in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(window)].filetype == "snacks_input" then prompt_windows = prompt_windows + 1 end
    end
    local prompt_buffers = 0
    local picker_buffers = 0
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buffer) then
        local filetype = vim.bo[buffer].filetype
        if filetype == "snacks_input" then prompt_buffers = prompt_buffers + 1 end
        if filetype:find("snacks_picker", 1, true) == 1 or filetype == "snacks_layout_box" then
          picker_buffers = picker_buffers + 1
        end
      end
    end
    local picker_windows = 0
    for _, window in ipairs(vim.api.nvim_list_wins()) do
      local filetype = vim.bo[vim.api.nvim_win_get_buf(window)].filetype
      if filetype:find("snacks_picker", 1, true) == 1 or filetype == "snacks_layout_box" then
        picker_windows = picker_windows + 1
      end
    end
    return {
      window = vim.api.nvim_get_current_win(),
      buffer = vim.api.nvim_get_current_buf(),
      cursor = vim.api.nvim_win_get_cursor(0),
      prompt_windows = prompt_windows,
      prompt_buffers = prompt_buffers,
      picker_windows = picker_windows,
      picker_buffers = picker_buffers,
    }
  end)()]]
end

local function assert_input_closed(origin)
  helpers.wait_until(
    child,
    ([[(function()
      if vim.api.nvim_get_current_win() ~= %d or vim.api.nvim_get_current_buf() ~= %d then return false end
      for _, window in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(window)].filetype == "snacks_input" then return false end
      end
      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].filetype == "snacks_input" then return false end
      end
      return true
    end)()]]):format(origin.window, origin.buffer),
    "input prompt cleanup"
  )
  assert.same(origin, editor_state())
end

local function assert_select_closed(origin)
  helpers.wait_until(
    child,
    ([[(function()
      if vim.api.nvim_get_current_win() ~= %d or vim.api.nvim_get_current_buf() ~= %d then return false end
      for _, window in ipairs(vim.api.nvim_list_wins()) do
        local filetype = vim.bo[vim.api.nvim_win_get_buf(window)].filetype
        if filetype:find("snacks_picker", 1, true) == 1 or filetype == "snacks_layout_box" then return false end
      end
      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buffer) then
          local filetype = vim.bo[buffer].filetype
          if filetype:find("snacks_picker", 1, true) == 1 or filetype == "snacks_layout_box" then return false end
        end
      end
      return true
    end)()]]):format(origin.window, origin.buffer),
    "select picker cleanup"
  )
  assert.same(origin, editor_state())
end

T["SNACKS-01 opens the dashboard and closes it through the production home mapping"] = function()
  start_ready_child()
  helpers.wait_until(child, "vim.fn.maparg('<Leader>h', 'n', false, true).desc == 'Home Screen'", "home mapping")

  assert.equals("Home Screen", child.lua_get "vim.fn.maparg('<Leader>h', 'n', false, true).desc")
  assert.is_false(child.lua_get "vim.bo.filetype == 'snacks_dashboard'")

  child.type_keys "<Space>h"
  helpers.wait_until(child, "vim.bo.filetype == 'snacks_dashboard'", "Snacks dashboard")
  assert.is_true(child.lua_get "package.loaded['snacks'] ~= nil")

  child.type_keys "<Space>h"
  helpers.wait_until(child, "vim.bo.filetype ~= 'snacks_dashboard'", "dashboard close mapping")
end

T["INPUT-01 preserves insertion order and cursor position in vim.ui.input"] = function()
  start_ready_child()
  local origin = editor_state()
  child.lua [[
    vim.api.nvim_exec_autocmds("UIEnter", {})
    vim.schedule(function()
      vim.ui.input({ prompt = "Rename: " }, function(value) vim.g.astronvim_test_input_result = value or false end)
    end)
  ]]
  helpers.wait_until(child, "vim.bo.filetype == 'snacks_input'", "Snacks input prompt")

  child.type_keys "a"
  child.lua [[vim.schedule(function() vim.g.astronvim_test_input_flushed = true end)]]
  helpers.wait_until(child, "vim.g.astronvim_test_input_flushed == true", "input scheduler flush")

  local after_first_character = child.lua_get [[{
    line = vim.api.nvim_get_current_line(),
    cursor = vim.api.nvim_win_get_cursor(0),
    mode = vim.api.nvim_get_mode().mode,
    treesitter_enabled = require("astrocore.treesitter").is_enabled(0),
  }]]
  assert.same({
    line = "a",
    cursor = { 1, 1 },
    mode = "i",
    treesitter_enabled = false,
  }, after_first_character)

  child.type_keys "b"
  assert.equals("ab", child.lua_get "vim.api.nvim_get_current_line()")
  assert.same({ 1, 2 }, child.lua_get "vim.api.nvim_win_get_cursor(0)")

  child.type_keys "<CR>"
  helpers.wait_until(child, "vim.g.astronvim_test_input_result ~= nil", "input result")
  assert.equals("ab", child.lua_get "vim.g.astronvim_test_input_result")
  assert_input_closed(origin)
end

T["INPUT-02 restores editor state after cancelling vim.ui.input"] = function()
  start_ready_child()
  local origin = editor_state()
  child.lua [[
    vim.api.nvim_exec_autocmds("UIEnter", {})
    vim.schedule(function()
      vim.ui.input({ prompt = "Cancel: " }, function(value)
        vim.g.astronvim_test_input_cancelled = value == nil
      end)
    end)
  ]]
  helpers.wait_until(child, "vim.bo.filetype == 'snacks_input'", "Snacks input prompt")

  child.type_keys "discarded"
  child.type_keys "<Esc>"
  helpers.wait_until(child, "vim.api.nvim_get_mode().mode == 'n'", "input normal mode")
  child.type_keys "q"
  helpers.wait_until(child, "vim.g.astronvim_test_input_cancelled == true", "input cancellation")
  assert_input_closed(origin)
end

T["SELECT-01 returns the chosen vim.ui.select item and restores editor state"] = function()
  start_ready_child()
  local origin = editor_state()
  child.lua [[
    vim.api.nvim_exec_autocmds("UIEnter", {})
    vim.schedule(function()
      vim.ui.select({ "alpha", "beta" }, { prompt = "Choose:" }, function(item, index)
        vim.g.astronvim_test_select_result = { item = item or false, index = index or false }
      end)
    end)
  ]]
  helpers.wait_until(child, "vim.bo.filetype == 'snacks_picker_input'", "Snacks select picker")

  child.type_keys "<Down><CR>"
  helpers.wait_until(child, "vim.g.astronvim_test_select_result ~= nil", "select result")
  assert.same({ item = "beta", index = 2 }, child.lua_get "vim.g.astronvim_test_select_result")
  assert_select_closed(origin)
end

T["SELECT-02 cancels vim.ui.select without a value and restores editor state"] = function()
  start_ready_child()
  local origin = editor_state()
  child.lua [[
    vim.api.nvim_exec_autocmds("UIEnter", {})
    vim.schedule(function()
      vim.ui.select({ "alpha", "beta" }, { prompt = "Choose:" }, function(item, index)
        vim.g.astronvim_test_select_result = { item = item or false, index = index or false }
      end)
    end)
  ]]
  helpers.wait_until(child, "vim.bo.filetype == 'snacks_picker_input'", "Snacks select picker")

  child.type_keys "<Esc>q"
  helpers.wait_until(child, "vim.g.astronvim_test_select_result ~= nil", "select cancellation")
  assert.same({ item = false, index = false }, child.lua_get "vim.g.astronvim_test_select_result")
  assert_select_closed(origin)
end

T["SNACKS-08 repeats the home mapping without leaving dashboard UI behind"] = function()
  start_ready_child()
  for _ = 1, 2 do
    child.type_keys "<Space>h"
    helpers.wait_until(child, "vim.bo.filetype == 'snacks_dashboard'", "Snacks dashboard")
    child.type_keys "<Space>h"
    helpers.wait_until(
      child,
      [[(function()
      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].filetype == "snacks_dashboard" then return false end
      end
      return true
    end)()]],
      "dashboard UI cleanup"
    )
  end
end

return T
