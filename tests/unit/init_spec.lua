local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local default_config = require "astronvim.config"
local T = MiniTest.new_set()

local function run_init(options, callback)
  options = options or {}
  local calls = { deferred = 0, echo = {}, events = options.events or {}, getchar = 0, values = 0 }
  local globals = options.globals or {}
  local plugin = { version = options.version }

  return unit_helpers.with_module("astronvim.init", {
    loaded = {
      ["astronvim.config"] = vim.deepcopy(options.config or default_config),
      ["astronvim.notify"] = {
        defer_startup = function()
          calls.deferred = calls.deferred + 1
          if options.defer_error then error(options.defer_error) end
        end,
      },
      ["lazy.core.config"] = options.lazy_config or { spec = { plugins = { AstroNvim = plugin } } },
      ["lazy.core.plugin"] = {
        values = function()
          calls.values = calls.values + 1
          if options.values_error then error(options.values_error) end
          if options.return_nil_opts then return nil end
          return vim.deepcopy(options.user_opts or {})
        end,
      },
    },
    vim = {
      api = {
        nvim_echo = function(chunks)
          table.insert(calls.events, "echo")
          table.insert(calls.echo, chunks)
        end,
      },
      cmd = {
        quit = options.quit or function() end,
      },
      fn = {
        getchar = function()
          calls.getchar = calls.getchar + 1
          table.insert(calls.events, "getchar")
        end,
        has = function() return options.has == nil and 1 or options.has end,
      },
      g = globals,
      tbl_deep_extend = options.deep_extend or vim.tbl_deep_extend,
    },
  }, function(init) return callback(init, calls, vim.g) end)
end

T["INIT-01 applies the default leader and icon configuration"] = function()
  run_init(nil, function(init, _, globals)
    init.init()

    assert.equals(" ", globals.mapleader)
    assert.equals(",", globals.maplocalleader)
    assert.equals(true, init.config.icons_enabled)
  end)
end

T["INIT-02 gives user options precedence while retaining defaults"] = function()
  run_init({ user_opts = { mapleader = ";", custom_option = true } }, function(init, _, globals)
    init.init()

    assert.equals(";", globals.mapleader)
    assert.equals(",", init.config.maplocalleader)
    assert.equals(true, init.config.icons_enabled)
    assert.equals(true, init.config.custom_option)
  end)
end

T["INIT-03 derives pin_plugins only when it is unset"] = function()
  local cases = {
    { version = "1.0.0", expected = true },
    { expected = false },
    { version = "1.0.0", user_opts = { pin_plugins = false }, expected = false },
  }

  for _, case in ipairs(cases) do
    run_init(case, function(init)
      init.init()
      assert.equals(case.expected, init.config.pin_plugins)
    end)
  end
end

T["INIT-04 preserves existing leaders, supplies missing leaders, and accepts nil configuration"] = function()
  run_init({ globals = { mapleader = "existing", maplocalleader = "local" } }, function(init, _, globals)
    init.init()
    assert.equals("existing", globals.mapleader)
    assert.equals("local", globals.maplocalleader)
  end)

  run_init(nil, function(init, _, globals)
    init.init()
    assert.equals(" ", globals.mapleader)
    assert.equals(",", globals.maplocalleader)
  end)

  local config = vim.deepcopy(default_config)
  config.mapleader = nil
  config.maplocalleader = nil
  run_init({ config = config }, function(init, _, globals)
    init.init()
    assert.is_nil(globals.mapleader)
    assert.is_nil(globals.maplocalleader)
  end)
end

T["INIT-05 applies disabled icons and preserves user icon state otherwise"] = function()
  run_init(
    { config = vim.tbl_extend("force", vim.deepcopy(default_config), { icons_enabled = false }) },
    function(init, _, globals)
      init.init()
      assert.equals(false, globals.icons_enabled)
    end
  )

  run_init({
    config = vim.tbl_extend("force", vim.deepcopy(default_config), { icons_enabled = false }),
    globals = { icons_enabled = "user value" },
  }, function(init, _, globals)
    init.init()
    assert.equals(false, globals.icons_enabled)
  end)

  run_init({ globals = { icons_enabled = "user value" } }, function(init, _, globals)
    init.init()
    assert.equals("user value", globals.icons_enabled)
  end)
end

T["INIT-06 initializes once and rolls back initialization after a setup error"] = function()
  run_init(nil, function(init, calls)
    init.init()
    init.init()

    assert.equals(1, calls.deferred)
    assert.equals(1, calls.values)
  end)

  run_init({ values_error = "forced setup failure" }, function(init)
    local ok, err = pcall(init.init)

    assert.is_false(ok)
    assert.is_true(tostring(err):find("forced setup failure", 1, true) ~= nil)
    assert.equals(false, init.did_init)
  end)
end

T["INIT-07 reports unsupported Neovim versions before quitting"] = function()
  local calls = {}
  local events = {}
  run_init({
    events = events,
    has = 0,
    quit = function()
      table.insert(events, "quit")
      table.insert(calls, "quit")
      error "quit requested"
    end,
  }, function(init, state)
    local ok, err = pcall(init.init)

    assert.is_false(ok)
    assert.is_true(tostring(err):find("quit requested", 1, true) ~= nil)
    assert.equals(1, #state.echo)
    assert.is_true(state.echo[1][1][1]:find("requires Neovim", 1, true) ~= nil)
    assert.equals(1, state.getchar)
    assert.same({ "echo", "getchar", "quit" }, state.events)
    assert.equals("quit", calls[1])
    assert.equals(false, init.did_init)
  end)
end

T["INIT-08 reports pinned and development versions without assuming Git is present"] = function()
  local cases = {
    { plugin_version = "1.2.3", expected = "v1.2.3" },
    { git = 1, git_output = "v1.2.3-4-gabcdef\n", expected = "v1.2.3-dev-4-gabcdef" },
    { git = 0, expected = "v1.2.3-dev" },
  }

  for _, case in ipairs(cases) do
    local calls = { notifications = {} }
    unit_helpers.with_module("astronvim.init", {
      loaded = {
        ["astronvim.config"] = vim.deepcopy(default_config),
        astrocore = {
          get_plugin = function() return { dir = "/tmp/AstroNvim", version = case.plugin_version } end,
          read_file = function() return " 1.2.3\n" end,
          cmd = function() return case.git_output end,
          notify = function(message, level) table.insert(calls.notifications, { message = message, level = level }) end,
        },
      },
      vim = {
        fn = { executable = function() return case.git or 0 end },
        trim = function(value) return value:match "^%s*(.-)%s*$" end,
      },
    }, function(init)
      assert.equals(case.expected, init.version())
      assert.equals(0, #calls.notifications)
    end)
  end
end

T["INIT-08 reports an unreadable version file through AstroCore"] = function()
  local calls = {}
  unit_helpers.with_module("astronvim.init", {
    loaded = {
      ["astronvim.config"] = vim.deepcopy(default_config),
      astrocore = {
        get_plugin = function() return { dir = "/tmp/AstroNvim", version = "1.2.3" } end,
        read_file = function() error "missing version" end,
        notify = function(message, level)
          calls.message, calls.level = message, level
        end,
      },
    },
  }, function(init)
    assert.is_nil(init.version())
    assert.equals("Unable to calculate version", calls.message)
    assert.equals(vim.log.levels.ERROR, calls.level)
  end)
end

T["INIT-09 rolls back initialization when startup deferral or option merging fails"] = function()
  for _, case in ipairs {
    { expected = "defer failed", defer_error = "defer failed" },
    { expected = "merge failed", deep_extend = function() error "merge failed" end },
  } do
    run_init(case, function(init)
      local ok, err = pcall(init.init)
      assert.is_false(ok)
      assert.is_true(tostring(err):find(case.expected, 1, true) ~= nil)
      assert.equals(false, init.did_init)
    end)
  end
end

return T
