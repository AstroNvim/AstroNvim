local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

T["TEST-01 and TEST-02 restore isolated state after a failing case"] = function()
  local state_module = "tests.unit_helper_state"
  local target_module = "tests.unit_helper_target"
  local removed_module = "tests.unit_helper_removed"
  local original_state = { original = true }
  local original_target = { original = true }
  local original_target_preload = function() return original_target end
  local original_removed = { original = true }
  local original_removed_preload = function() return original_removed end
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  local original_new_timer = vim.uv.new_timer
  local original_new_check = vim.uv.new_check
  local timer
  local checker
  local scheduled = 0

  package.loaded[state_module] = original_state
  package.loaded[target_module] = original_target
  package.preload[target_module] = original_target_preload
  package.loaded[removed_module] = original_removed
  package.preload[removed_module] = original_removed_preload

  local assertions_ok, assertions_err = xpcall(function()
    local ok, err = pcall(unit_helpers.with_module, target_module, {
      loaded = { [state_module] = { replacement = true }, [removed_module] = unit_helpers.remove },
      notify = function() end,
      preload = {
        [target_module] = function() return {} end,
        [removed_module] = unit_helpers.remove,
      },
      vim = { g = { unit_helper_value = true } },
      fake_uv = true,
    }, function(_, context)
      assert.is_nil(package.loaded[removed_module])
      assert.is_nil(package.preload[removed_module])
      timer = vim.uv.new_timer()
      checker = vim.uv.new_check()
      timer:start(10, 0, function() end)
      checker:start(function() end)
      vim.schedule(function() scheduled = scheduled + 1 end)
      assert.equals(1, context.scheduled_count())
      error "isolated failure"
    end)

    assert.is_false(ok)
    assert.is_true(tostring(err):find("isolated failure", 1, true) ~= nil)
    assert.equals(0, scheduled)
    assert.is_true(timer.stopped)
    assert.is_true(timer.closed)
    assert.is_true(checker.stopped)
    assert.is_true(checker.closed)
    assert.equals(original_state, package.loaded[state_module])
    assert.equals(original_target, package.loaded[target_module])
    assert.equals(original_target_preload, package.preload[target_module])
    assert.equals(original_removed, package.loaded[removed_module])
    assert.equals(original_removed_preload, package.preload[removed_module])
    assert.equals(original_notify, vim.notify)
    assert.equals(original_schedule, vim.schedule)
    assert.equals(original_new_timer, vim.uv.new_timer)
    assert.equals(original_new_check, vim.uv.new_check)
    assert.is_nil(vim.g.unit_helper_value)
  end, debug.traceback)

  package.loaded[state_module] = nil
  package.loaded[target_module] = nil
  package.preload[target_module] = nil
  package.loaded[removed_module] = nil
  package.preload[removed_module] = nil

  if not assertions_ok then error(assertions_err, 0) end
end

T["TEST-02 can replace indexed vim proxy tables without leaking state"] = function()
  local original_buffer_vars = vim.b
  local fake_buffer_vars = { [7] = { value = "before" } }

  unit_helpers.with_module("tests.unit_helper_proxy_target", {
    preload = { ["tests.unit_helper_proxy_target"] = function() return {} end },
    replace_vim = { b = true },
    vim = { b = fake_buffer_vars },
  }, function()
    assert.equals(fake_buffer_vars, vim.b)
    vim.b[7].value = "after"
  end)

  assert.equals("after", fake_buffer_vars[7].value)
  assert.equals(original_buffer_vars, vim.b)
end

T["TEST-02 drains scheduled callbacks in registration order"] = function()
  unit_helpers.with_module("tests.unit_helper_schedule_target", {
    preload = { ["tests.unit_helper_schedule_target"] = function() return {} end },
  }, function(_, context)
    local calls = {}
    vim.schedule(function() table.insert(calls, "first") end)
    vim.schedule(function() table.insert(calls, "second") end)

    context.drain_scheduled()

    assert.equals(2, #calls)
    assert.equals("first", calls[1])
    assert.equals("second", calls[2])
  end)
end

return T
