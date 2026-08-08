local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_notify(notifier, callback, options)
  options = options or {}
  return unit_helpers.with_module("astronvim.notify", {
    fake_uv = options.fake_uv ~= false,
    notify = notifier,
    replace_vim = options.replace_vim,
    vim = options.vim,
  }, callback)
end

local function recorder(calls, fail)
  return function(message, level, opts)
    table.insert(calls, { level = level, message = message, opts = opts })
    if fail then fail(message) end
  end
end

T["NOTIFY-01 pauses notification delivery and records pending state"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify)
    notify.pause()
    vim.notify("queued", vim.log.levels.WARN, { title = "AstroNvim" })

    assert.is_true(notify.is_paused())
    assert.equals(1, #notify.pending())
    assert.equals(0, #calls)
  end)
end

T["NOTIFY-02 resumes queued notifications in order with their arguments"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    vim.notify("first", vim.log.levels.INFO, { title = "One" })
    vim.notify("second", vim.log.levels.WARN, { title = "Two" })
    notify.resume()
    context.drain_scheduled()

    assert.equals(2, #calls)
    assert.equals("first", calls[1].message)
    assert.equals(vim.log.levels.INFO, calls[1].level)
    assert.equals("One", calls[1].opts.title)
    assert.equals("second", calls[2].message)
    assert.equals(vim.log.levels.WARN, calls[2].level)
    assert.equals("Two", calls[2].opts.title)
  end)
end

T["NOTIFY-03 replaces pending notifications for numeric and object IDs"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    local first = vim.notify "first"
    local numeric = vim.notify("numeric replacement", nil, { replace = first.id })
    local object = vim.notify("object replacement", nil, { replace = { id = first.id } })
    notify.resume()
    context.drain_scheduled()

    assert.equals(first.id, numeric.id)
    assert.equals(first.id, object.id)
    assert.equals(1, #calls)
    assert.equals("object replacement", calls[1].message)
  end)
end

T["NOTIFY-04 removes replacement metadata before delivery"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    local first = vim.notify "first"
    vim.notify("replacement", nil, { replace = first.id, title = "Updated" })
    notify.resume()
    context.drain_scheduled()

    assert.equals(1, #calls)
    assert.equals("replacement", calls[1].message)
    assert.equals("Updated", calls[1].opts.title)
    assert.is_nil(calls[1].opts.replace)
  end)
end

T["NOTIFY-05 requeues a failed delivery and pauses before retrying"] = function()
  local calls = {}
  local failures = 1
  with_notify(
    recorder(calls, function(message)
      if message == "first" and failures > 0 then
        failures = failures - 1
        error "delivery failed"
      end
    end),
    function(notify, context)
      notify.pause()
      vim.notify "first"
      vim.notify "second"
      notify.resume()

      local ok, err = pcall(context.drain_scheduled)
      assert.is_false(ok)
      assert.is_true(tostring(err):find("delivery failed", 1, true) ~= nil)
      assert.is_true(notify.is_paused())
      assert.equals(2, #notify.pending())

      notify.resume()
      context.drain_scheduled()

      assert.equals(3, #calls)
      assert.equals("first", calls[1].message)
      assert.equals("first", calls[2].message)
      assert.equals("second", calls[3].message)
    end
  )
end

T["NOTIFY-06 restores the notifier and replays queued messages once"] = function()
  local calls = {}
  local original = recorder(calls)
  with_notify(original, function(notify, context)
    notify.pause()
    vim.notify "queued"
    notify.restore()
    assert.equals(original, vim.notify)
    context.drain_scheduled()
    vim.notify "after restore"

    assert.is_false(notify.is_paused())
    assert.equals(2, #calls)
    assert.equals("queued", calls[1].message)
    assert.equals("after restore", calls[2].message)
  end)
end

T["NOTIFY-07 replaces prior startup deferral handles without replaying twice"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.defer_startup()
    vim.notify "deferred"
    local first_timer = context.latest_timer()
    local first_checker = context.latest_checker()

    notify.defer_startup()
    local second_timer = context.latest_timer()

    assert.is_true(context.is_stopped(first_timer))
    assert.is_true(context.is_closed(first_timer))
    assert.is_true(context.is_stopped(first_checker))
    assert.is_true(context.is_closed(first_checker))
    assert.is_false(context.fire(first_timer))
    assert.is_true(context.fire(second_timer))
    context.drain_scheduled()

    assert.equals(1, #calls)
    assert.equals("deferred", calls[1].message)
  end)
end

T["NOTIFY-08 finishes startup deferral when the notifier changes"] = function()
  local original_calls = {}
  local replacement_calls = {}
  with_notify(recorder(original_calls), function(notify, context)
    notify.defer_startup()
    vim.notify "deferred"
    vim.notify = recorder(replacement_calls)
    assert.is_true(context.fire(context.latest_checker()))
    context.drain_scheduled()

    assert.is_false(notify.is_paused())
    assert.equals(0, #original_calls)
    assert.equals(1, #replacement_calls)
    assert.equals("deferred", replacement_calls[1].message)
  end)
end

T["NOTIFY-08 finishes startup deferral when its timeout expires"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.defer_startup()
    vim.notify "deferred"
    assert.is_true(context.fire(context.latest_timer()))
    context.drain_scheduled()

    assert.is_false(notify.is_paused())
    assert.equals(1, #calls)
    assert.equals("deferred", calls[1].message)
  end)
end

T["NOTIFY-09 passes through directly and pauses over the current notifier"] = function()
  local original_calls = {}
  local replacement_calls = {}
  with_notify(recorder(original_calls), function(notify, context)
    notify.notify "direct"
    vim.notify = recorder(replacement_calls)
    notify.pause()
    vim.notify "queued"
    notify.resume()
    context.drain_scheduled()

    assert.equals(1, #original_calls)
    assert.equals("direct", original_calls[1].message)
    assert.equals(1, #replacement_calls)
    assert.equals("queued", replacement_calls[1].message)
  end)
end

T["NOTIFY-09 handles empty resumes and re-pausing before scheduled delivery"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    notify.resume()
    assert.equals(0, context.scheduled_count())

    notify.pause()
    vim.notify "queued"
    notify.resume()
    notify.pause()
    context.drain_scheduled()

    assert.is_true(notify.is_paused())
    assert.equals(1, #notify.pending())
    assert.equals(0, #calls)

    notify.resume()
    context.drain_scheduled()
    assert.equals("queued", calls[1].message)
  end)
end

T["NOTIFY-09 queues notifications emitted while resuming and avoids ID collisions"] = function()
  local calls = {}
  local nested_id
  local ordinary_id
  with_notify(function(message)
    table.insert(calls, message)
    if message == "first" then
      nested_id = vim.notify("replacement", nil, { replace = 1 }).id
      ordinary_id = vim.notify "ordinary"
    end
  end, function(notify, context)
    notify.pause()
    local first = vim.notify "first"
    notify.resume()
    context.drain_scheduled()

    assert.equals(first.id, nested_id)
    assert.is_true(ordinary_id.id ~= first.id)
    assert.same({ "first", "replacement", "ordinary" }, calls)
    assert.equals(0, #notify.pending())
  end)
end

T["NOTIFY-09 treats nonnumeric replacement values as new notifications"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    local first = vim.notify "first"
    local second = vim.notify("second", nil, { replace = "not an ID" })
    notify.resume()
    context.drain_scheduled()

    assert.is_true(first.id ~= second.id)
    assert.same({ "first", "second" }, { calls[1].message, calls[2].message })
  end)
end

T["NOTIFY-10C makes notifier restoration and competing startup completion idempotent"] = function()
  local calls = {}
  local original = recorder(calls)
  with_notify(original, function(notify, context)
    notify.defer_startup()
    vim.notify "deferred"
    local timer = context.latest_timer()
    local checker = context.latest_checker()

    assert.is_true(context.fire(timer))
    assert.is_false(context.fire(checker))
    for _, handle in ipairs(context.handles) do
      assert.is_true(context.is_stopped(handle))
      assert.is_true(context.is_closed(handle))
    end
    context.drain_scheduled()
    assert.equals(1, #calls)

    notify.pause()
    notify.pause()
    vim.notify "after repeated pause"
    notify.restore()
    notify.restore()
    assert.equals(original, vim.notify)
    assert.is_false(notify.is_paused())
    context.drain_scheduled()
    assert.equals(2, #calls)
    assert.same({ "deferred", "after repeated pause" }, { calls[1].message, calls[2].message })
  end)
end

T["NOTIFY-10A preserves caller options while replacement delivery receives a copy"] = function()
  local calls = {}
  with_notify(recorder(calls), function(notify, context)
    notify.pause()
    local first = vim.notify "first"
    local nested_options = { identity = "preserved" }
    local options = { replace = { id = first.id }, title = "Updated", user_data = nested_options }
    local expected_options = vim.deepcopy(options)
    vim.notify("replacement", nil, options)

    assert.same(expected_options, options)
    notify.resume()
    context.drain_scheduled()

    assert.equals(1, #calls)
    assert.equals("replacement", calls[1].message)
    assert.is_true(calls[1].opts ~= options)
    assert.is_nil(calls[1].opts.replace)
    assert.equals("Updated", calls[1].opts.title)
    assert.is_true(calls[1].opts.user_data == nested_options)

    notify.pause()
    local stale = vim.notify("stale replacement", nil, { replace = { id = first.id } })
    assert.is_true(stale.id ~= first.id)
    notify.resume()
    context.drain_scheduled()
    assert.equals(2, #calls)
    assert.equals("stale replacement", calls[2].message)
  end)
end

T["NOTIFY-10B restores the notifier and cleans up handles when startup allocation fails"] = function()
  for _, failure in ipairs { "timer", "checker" } do
    local handles = {}
    local original = function() end
    local function new_handle()
      local handle = { stopped = false, closed = false }
      function handle:stop() self.stopped = true end
      function handle:close() self.closed = true end
      table.insert(handles, handle)
      return handle
    end

    with_notify(original, function(notify)
      local ok, err = pcall(notify.defer_startup)
      assert.is_false(ok)
      assert.is_true(tostring(err):find("Unable to create startup notification", 1, true) ~= nil)
      assert.equals(original, vim.notify)
      assert.is_false(notify.is_paused())
      for _, handle in ipairs(handles) do
        assert.is_true(handle.stopped)
        assert.is_true(handle.closed)
      end
    end, {
      fake_uv = false,
      replace_vim = { uv = true },
      vim = {
        uv = {
          new_timer = function()
            if failure == "timer" then return end
            return new_handle()
          end,
          new_check = function()
            if failure == "checker" then return end
            return new_handle()
          end,
        },
      },
    })
  end
end

T["NOTIFY-10B preserves an active startup deferral when replacement allocation fails"] = function()
  local calls = {}
  local original = recorder(calls)
  local timers = {}
  local checkers = {}
  local checker_allocations = 0
  local function new_handle(collection)
    local handle = { closed = false, started = false, stopped = false }
    function handle:start(...)
      self.started = true
      self.callback = select(select("#", ...), ...)
      return 0
    end
    function handle:stop() self.stopped = true end
    function handle:close() self.closed = true end
    table.insert(collection, handle)
    return handle
  end

  with_notify(original, function(notify, context)
    notify.defer_startup()
    vim.notify "prior deferred notification"
    local prior_timer = timers[1]
    local prior_checker = checkers[1]

    local ok, err = pcall(notify.defer_startup)
    assert.is_false(ok)
    assert.is_true(tostring(err):find("Unable to create startup notification checker", 1, true) ~= nil)
    assert.equals(notify.notify, vim.notify)
    assert.is_true(notify.is_paused())
    assert.equals(1, #notify.pending())
    assert.is_true(prior_timer.started)
    assert.is_true(prior_checker.started)
    assert.is_false(prior_timer.stopped)
    assert.is_false(prior_timer.closed)
    assert.is_false(prior_checker.stopped)
    assert.is_false(prior_checker.closed)
    assert.is_true(timers[2].stopped)
    assert.is_true(timers[2].closed)

    prior_timer.callback()
    context.drain_scheduled()
    assert.same({ "prior deferred notification" }, { calls[1].message })
    notify.restore()
    assert.equals(original, vim.notify)
  end, {
    fake_uv = false,
    replace_vim = { uv = true },
    vim = {
      uv = {
        new_timer = function() return new_handle(timers) end,
        new_check = function()
          checker_allocations = checker_allocations + 1
          return checker_allocations == 1 and new_handle(checkers) or nil
        end,
      },
    },
  })
end

T["NOTIFY-10B preserves an active startup deferral when replacement handle startup fails"] = function()
  for _, failure in ipairs { "checker", "timer" } do
    local calls = {}
    local original = recorder(calls)
    local timers = {}
    local checkers = {}
    local allocation = 0
    local function new_handle(collection, kind)
      local handle = { closed = false, kind = kind, started = false, stopped = false }
      function handle:start(...)
        self.started = true
        self.callback = select(select("#", ...), ...)
        if allocation == 2 and failure == self.kind then return nil, self.kind .. " start failed" end
        return 0
      end
      function handle:stop() self.stopped = true end
      function handle:close() self.closed = true end
      table.insert(collection, handle)
      return handle
    end

    with_notify(original, function(notify, context)
      allocation = 1
      notify.defer_startup()
      vim.notify "prior deferred notification"
      local prior_timer = timers[1]
      local prior_checker = checkers[1]

      allocation = 2
      local ok, err = pcall(notify.defer_startup)
      assert.is_false(ok)
      assert.is_true(tostring(err):find(failure .. " start failed", 1, true) ~= nil)
      assert.equals(notify.notify, vim.notify)
      assert.is_true(notify.is_paused())
      assert.equals(1, #notify.pending())
      assert.is_false(prior_timer.stopped)
      assert.is_false(prior_timer.closed)
      assert.is_false(prior_checker.stopped)
      assert.is_false(prior_checker.closed)
      assert.is_true(timers[2].stopped)
      assert.is_true(timers[2].closed)
      assert.is_true(checkers[2].stopped)
      assert.is_true(checkers[2].closed)

      prior_timer.callback()
      context.drain_scheduled()
      assert.same({ "prior deferred notification" }, { calls[1].message })
      notify.restore()
      assert.equals(original, vim.notify)
    end, {
      fake_uv = false,
      replace_vim = { uv = true },
      vim = {
        uv = {
          new_timer = function() return new_handle(timers, "timer") end,
          new_check = function() return new_handle(checkers, "checker") end,
        },
      },
    })
  end
end

return T
