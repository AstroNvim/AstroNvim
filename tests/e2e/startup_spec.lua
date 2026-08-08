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

T["starts the local AstroNvim distribution with installed locked production plugins"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  local startup = child.lua_get [[(function()
    local Config = require "lazy.core.config"
    local Plugin = require "lazy.core.plugin"
    local plugins = Config.plugins
    local lockfile = assert(io.open(vim.env.ASTRONVIM_TEST_LOCKFILE, "rb"))
    local lock = vim.json.decode(assert(lockfile:read "*a"))
    lockfile:close()
    local errors = {}
    local test_only_locks = { ["mini.test"] = true, luassert = true, say = true }

    for name, plugin in pairs(plugins) do
      if Plugin.has_errors(plugin) then table.insert(errors, "plugin: " .. name) end
    end
    for _, notification in ipairs(Config.spec.notifs) do
      if notification.level >= vim.log.levels.ERROR then table.insert(errors, "spec: " .. notification.msg) end
    end
    for _, notification in ipairs(vim.g.astronvim_test_error_notifications) do
      table.insert(errors, "notification: " .. notification)
    end
    for name, plugin in pairs(plugins) do
      if plugin.url and not plugin._.is_local and plugin._.cond ~= false then
        local entry = lock[name]
        if not entry then
          table.insert(errors, "lock: " .. name .. " has no committed lock entry")
        elseif not plugin._.installed then
          table.insert(errors, "install: " .. name)
        else
          local head = vim.fn.systemlist({ "git", "-C", plugin.dir, "rev-parse", "HEAD" })[1]
          if head ~= entry.commit then table.insert(errors, "lock: " .. name .. " is at " .. tostring(head)) end
        end
      end
    end
    for name in pairs(lock) do
      if not test_only_locks[name] then
        local plugin = plugins[name]
        if not plugin or not plugin.url or plugin._.is_local or plugin._.cond == false then
          table.insert(errors, "lock: " .. name .. " has no production child plugin")
        end
      end
    end
    table.sort(errors)

    return {
      astronvim_dir = vim.fs.normalize(assert(plugins.AstroNvim).dir),
      astronvim_loaded = plugins.AstroNvim._.loaded ~= nil,
      specs = {
        astrocore = plugins.astrocore ~= nil,
        astrolsp = plugins.astrolsp ~= nil,
        astrotheme = plugins.astrotheme ~= nil,
        astroui = plugins.astroui ~= nil,
      },
      errors = errors,
    }
  end)()]]

  assert.equals(vim.fs.normalize(config.root), startup.astronvim_dir)
  assert.is_true(startup.astronvim_loaded)
  assert.is_true(startup.specs.astrocore)
  assert.is_true(startup.specs.astrolsp)
  assert.is_true(startup.specs.astrotheme)
  assert.is_true(startup.specs.astroui)
  assert.same({}, startup.errors)
end

T["replays startup error notifications before reporting readiness"] = function()
  local message = "AstroNvim startup notifier regression"
  local parent_value = vim.uv.os_getenv "ASTRONVIM_TEST_STARTUP_ERROR"
  child = helpers.start_child { ASTRONVIM_TEST_STARTUP_ERROR = message }
  assert.equals(parent_value, vim.uv.os_getenv "ASTRONVIM_TEST_STARTUP_ERROR")
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "startup notification replay")

  local captured = child.lua_get "vim.g.astronvim_test_error_notifications_before_ready"
  assert.is_true(vim.tbl_contains(captured, vim.inspect(message)))
end

return T
