local MiniTest = require "mini.test"
local helpers = require "helpers"
local config = require "config"

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

T["STARTUP-01 starts the local AstroNvim distribution with the generated dependency graph"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  local startup = child.lua_get [[(function()
    local manifest_file = assert(io.open(vim.env.ASTRONVIM_TEST_ROOT .. "/.tests/manifest.json", "rb"))
    local manifest = vim.json.decode(assert(manifest_file:read "*a"))
    manifest_file:close()
    local errors = {}
    local plugin_count = 0

    for name, plugin in pairs(manifest.plugins or {}) do
      plugin_count = plugin_count + 1
      local path = vim.fs.joinpath(vim.env.ASTRONVIM_TEST_ROOT, ".tests", plugin.path)
      local head = vim.fn.systemlist({ "git", "-C", path, "rev-parse", "HEAD" })[1]
      if vim.fn.isdirectory(path) ~= 1 then
        table.insert(errors, "missing: " .. name)
      elseif head ~= plugin.commit then
        table.insert(errors, "commit: " .. name .. " is at " .. tostring(head))
      end
    end
    for _, notification in ipairs(vim.g.astronvim_test_error_notifications) do
      table.insert(errors, "notification: " .. notification)
    end
    table.sort(errors)

    local required = {}
    for _, name in ipairs { "astrocore", "astrolsp", "astrotheme", "astroui" } do
      required[name] = pcall(require, name)
    end
    return {
      astronvim_dir = vim.fs.normalize(vim.env.ASTRONVIM_TEST_ROOT),
      plugin_count = plugin_count,
      required = required,
      ready = vim.g.astronvim_test_ready,
      errors = errors,
    }
  end)()]]

  assert.equals(vim.fs.normalize(config.root), startup.astronvim_dir)
  assert.is_true(startup.ready)
  assert.is_true(startup.plugin_count > 0)
  assert.is_true(startup.required.astrocore)
  assert.is_true(startup.required.astrolsp)
  assert.is_true(startup.required.astrotheme)
  assert.is_true(startup.required.astroui)
  assert.same({}, startup.errors)
end

T["STARTUP-02 replays startup error notifications before reporting readiness"] = function()
  local message = "AstroNvim startup notifier regression"
  local parent_value = vim.uv.os_getenv "ASTRONVIM_TEST_STARTUP_ERROR"
  child = helpers.start_child { ASTRONVIM_TEST_STARTUP_ERROR = message }
  assert.equals(parent_value, vim.uv.os_getenv "ASTRONVIM_TEST_STARTUP_ERROR")
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "startup notification replay")

  local captured = child.lua_get "vim.g.astronvim_test_error_notifications_before_ready"
  assert.is_true(vim.tbl_contains(captured, vim.inspect(message)))

  helpers.wait_until(
    child,
    ([[(function()
      local matches = 0
      for _, notification in ipairs(Snacks.notifier.get_history()) do
        if notification.msg == %s and notification.level == "error" then matches = matches + 1 end
      end
      return matches == 1 and #require("astronvim.notify").pending() == 0
    end)()]]):format(vim.inspect(message)),
    "startup notification delivery"
  )
  local delivery = child.lua_get(([[(function()
    local matches = 0
    for _, notification in ipairs(Snacks.notifier.get_history()) do
      if notification.msg == %s and notification.level == "error" then matches = matches + 1 end
    end
    return {
      matches = matches,
      pending = #require("astronvim.notify").pending(),
      paused = require("astronvim.notify").is_paused(),
    }
  end)()]]):format(vim.inspect(message)))
  assert.same({ matches = 1, pending = 0, paused = false }, delivery)
end

return T
