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

T["HARNESS-01 restores parent XDG variables after spawning a child"] = function()
  local before = helpers.parent_xdg_environment()
  local parent = {
    XDG_CONFIG_HOME = "/tmp/astronvim-parent-config",
    XDG_DATA_HOME = nil,
    XDG_STATE_HOME = "/tmp/astronvim-parent-state",
    XDG_CACHE_HOME = nil,
    XDG_RUNTIME_DIR = "/tmp/astronvim-parent-runtime",
  }

  local ok, err = xpcall(function()
    for name, value in pairs(parent) do
      vim.env[name] = value
    end
    vim.env.XDG_DATA_HOME = nil
    vim.env.XDG_CACHE_HOME = nil
    local expected = helpers.parent_xdg_environment()
    assert.is_nil(expected.XDG_DATA_HOME.value)
    assert.is_nil(expected.XDG_CACHE_HOME.value)
    child = helpers.start_child()
    assert.same(expected, helpers.parent_xdg_environment())
  end, debug.traceback)

  helpers.restore_parent_xdg_environment(before)
  if not ok then error(err, 0) end
end

T["HARNESS-02 uses deterministic child and fixture Git environments"] = function()
  child = helpers.start_child()

  local state = child.lua_get [[(function()
    local function git(args)
      return vim.fn.systemlist(vim.list_extend({ "git" }, args))[1]
    end
    return {
      environment = {
        LC_ALL = vim.env.LC_ALL,
        LANG = vim.env.LANG,
        TZ = vim.env.TZ,
        TERM = vim.env.TERM,
        COLORTERM = vim.env.COLORTERM,
        GIT_CONFIG_NOSYSTEM = vim.env.GIT_CONFIG_NOSYSTEM,
        GIT_CONFIG_GLOBAL = vim.env.GIT_CONFIG_GLOBAL,
        GIT_TEMPLATE_DIR = vim.env.GIT_TEMPLATE_DIR,
        GIT_CONFIG_KEY_0 = vim.env.GIT_CONFIG_KEY_0,
        GIT_CONFIG_VALUE_0 = vim.env.GIT_CONFIG_VALUE_0,
      },
      branch = git({ "branch", "--show-current" }),
      identity = git({ "log", "-1", "--format=%an|%ae|%cn|%ce" }),
      dates = git({ "log", "-1", "--format=%at|%ct" }),
      hooks_path = git({ "config", "--local", "--get", "core.hooksPath" }),
    }
  end)()]]

  assert.same({
    LC_ALL = "C",
    LANG = "C",
    TZ = "UTC",
    TERM = "xterm-256color",
    COLORTERM = "truecolor",
    GIT_CONFIG_NOSYSTEM = "1",
    GIT_CONFIG_GLOBAL = state.environment.GIT_CONFIG_GLOBAL,
    GIT_TEMPLATE_DIR = state.environment.GIT_TEMPLATE_DIR,
    GIT_CONFIG_KEY_0 = "core.hooksPath",
    GIT_CONFIG_VALUE_0 = state.environment.GIT_CONFIG_VALUE_0,
  }, state.environment)
  assert.equals("gitconfig", vim.fs.basename(vim.fs.normalize(state.environment.GIT_CONFIG_GLOBAL)))
  assert.equals("git-template", vim.fs.basename(vim.fs.normalize(state.environment.GIT_TEMPLATE_DIR)))
  assert.equals("git-hooks", vim.fs.basename(vim.fs.normalize(state.environment.GIT_CONFIG_VALUE_0)))
  assert.equals("main", state.branch)
  assert.equals("AstroNvim Test|test@astronvim.local|AstroNvim Test|test@astronvim.local", state.identity)
  assert.equals("946684800|946684800", state.dates)
  assert.equals(state.environment.GIT_CONFIG_VALUE_0, state.hooks_path)
end

return T
