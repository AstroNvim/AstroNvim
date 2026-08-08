local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function find_record(records, kind, message)
  for _, record in ipairs(records) do
    if record.kind == kind and record.message == message then return record end
  end
end

local function with_health(options, callback)
  options = options or {}
  local calls = {}

  local function record(kind, message) table.insert(calls, { kind = kind, message = message }) end

  return unit_helpers.with_module("astronvim.health", {
    loaded = {
      astronvim = { version = function() return options.astronvim_version or "v5.0.0" end },
    },
    vim = {
      api = {
        nvim_exec2 = function(command, exec_options)
          calls.exec2 = { command = command, options = exec_options }
          return { output = options.version_output or ("NVIM v" .. (options.neovim_version or "0.11.3") .. "\n") }
        end,
      },
      fn = {
        executable = function(name) return (options.executables or {})[name] or 0 end,
        has = function(feature)
          calls.has = calls.has or {}
          table.insert(calls.has, feature)
          return options.has == nil and 1 or options.has
        end,
      },
      health = {
        start = function(message) record("start", message) end,
        info = function(message) record("info", message) end,
        ok = function(message) record("ok", message) end,
        warn = function(message) record("warn", message) end,
        error = function(message) record("error", message) end,
      },
      version = function()
        calls.version_calls = (calls.version_calls or 0) + 1
        return { prerelease = options.prerelease == true }
      end,
    },
  }, function(health)
    if options.check ~= false then health.check() end
    callback(calls)
  end)
end

local function with_dev(options, callback)
  options = options or {}
  local calls = { commands = {}, writes = {} }
  local commits = options.commits or {}

  return unit_helpers.with_module("astronvim.dev", {
    loaded = {
      astrocore = {
        cmd = function(command, silent)
          table.insert(calls.commands, { command = command, silent = silent })
          return assert(commits[command[3]], "Unexpected Git command")
        end,
        get_plugin = function(name)
          assert.equals("AstroNvim", name)
          return { dev = options.dev == true, dir = options.dir or "/workspace/AstroNvim" }
        end,
        with_file = function(path, mode, write)
          local file = {
            write = function(_, contents)
              if options.write_error then error(options.write_error) end
              table.insert(calls.writes, { path = path, mode = mode, contents = contents })
            end,
          }
          write(file)
        end,
      },
      lazy = { plugins = function() return vim.deepcopy(options.plugins or {}) end },
      ["astronvim.lazy_snapshot"] = vim.deepcopy(options.previous_snapshot or {}),
    },
    vim = {
      F = { if_nil = function(value, fallback) return value == nil and fallback or value end },
      tbl_get = function(value, ...)
        for _, key in ipairs { ... } do
          if value == nil then return nil end
          value = value[key]
        end
        return value
      end,
      trim = function(value) return value:match "^%s*(.-)%s*$" end,
    },
  }, function(dev) callback(dev, calls) end)
end

local function plugin_names(snapshot)
  local names = {}
  for _, plugin in ipairs(snapshot) do
    table.insert(names, plugin[1])
  end
  return names
end

T["HEALTH-01 reports supported nightly and unsupported Neovim branches"] = function()
  local cases = {
    { name = "supported", prerelease = false, has = 1, kind = "ok", message = "Using stable Neovim >= 0.11.0" },
    {
      name = "nightly",
      prerelease = true,
      has = 1,
      kind = "warn",
      message = "Neovim nightly is not officially supported and may have breaking changes",
    },
    { name = "unsupported", prerelease = false, has = 0, kind = "error", message = "Neovim >= 0.11.0 is required" },
  }

  for _, case in ipairs(cases) do
    with_health({ prerelease = case.prerelease, has = case.has }, function(calls)
      assert.equals("Checking requirements", calls[1].message, case.name)
      assert.is_not_nil(find_record(calls, "info", "AstroNvim Version: v5.0.0"), case.name)
      assert.is_not_nil(find_record(calls, "info", "Neovim Version: v0.11.3"), case.name)
      assert.is_not_nil(find_record(calls, case.kind, case.message), case.name)
      assert.same({ command = "version", options = { output = true } }, calls.exec2)
      assert.equals(1, calls.version_calls)
      assert.same(case.prerelease and {} or { "nvim-0.11" }, calls.has or {})
    end)
  end
end

T["HEALTH-02 reports required Git errors, optional warnings, and selected alternatives"] = function()
  with_health({
    executables = {
      rundll32 = 1,
      ["gdu-go"] = 1,
      python3 = 1,
    },
  }, function(calls)
    assert.is_not_nil(
      find_record(
        calls,
        "error",
        "`git` is not installed: Used for core functionality such as updater and plugin management"
      )
    )
    assert.is_not_nil(
      find_record(
        calls,
        "ok",
        "`rundll32` is installed: Used for `gx` mapping for opening files with system opener (Optional)"
      )
    )
    assert.is_not_nil(
      find_record(calls, "ok", "`gdu-go` is installed: Used for mappings to pull up disk usage analyzer (Optional)")
    )
    assert.is_not_nil(
      find_record(calls, "ok", "`python3` is installed: Used for mappings to pull up python REPL (Optional)")
    )
    assert.is_not_nil(
      find_record(
        calls,
        "warn",
        "`rg` is not installed: Used for the `live_grep` picker, `<Leader>fw` and `<Leader>fW` by default (Optional)"
      )
    )
    assert.is_not_nil(
      find_record(calls, "warn", "`lazygit` is not installed: Used for mappings to pull up git TUI (Optional)")
    )
    assert.is_not_nil(
      find_record(calls, "warn", "`node` is not installed: Used for mappings to pull up node REPL (Optional)")
    )
    assert.is_not_nil(
      find_record(calls, "warn", "`btm` is not installed: Used for mappings to pull up system monitor (Optional)")
    )
    assert.same({ command = "version", options = { output = true } }, calls.exec2)
    assert.equals(1, calls.version_calls)
    assert.same({ "nvim-0.11" }, calls.has)
  end)
end

T["HEALTH-03 reports every documented executable alternative"] = function()
  local alternatives = {
    "git",
    "xdg-open",
    "rundll32",
    "explorer.exe",
    "open",
    "rg",
    "lazygit",
    "node",
    "gdu",
    "gdu-go",
    "gdu_windows_amd64.exe",
    "btm",
    "python",
    "python3",
  }
  for _, executable in ipairs(alternatives) do
    with_health({ executables = { git = 1, [executable] = 1 } }, function(calls)
      local expected = "`" .. executable .. "` is installed:"
      local record
      for _, candidate in ipairs(calls) do
        if candidate.message:sub(1, #expected) == expected then
          record = candidate
          break
        end
      end
      assert.is_not_nil(record, executable)
      assert.equals("ok", record.kind, executable)
    end)
  end
end

T["DEV-01 generates sorted snapshots with exclusions, current commits, preserved versions, and a Treesitter pin"] = function()
  with_dev({
    dev = true,
    commits = {
      ["/plugins/a"] = "a-current\n",
      ["/plugins/astro"] = "astro-current\n",
      ["/plugins/luvit"] = "luvit-current\n",
      ["/plugins/treesitter"] = "treesitter-current\n",
      ["/plugins/z"] = "z-current\n",
    },
    plugins = {
      { "z/plugin", dir = "/plugins/z", version = "^9" },
      { "AstroNvim/AstroNvim", dir = "/plugins/astro" },
      { "Bilal2453/luvit-meta", dir = "/plugins/luvit" },
      { "nvim-treesitter/nvim-treesitter", dir = "/plugins/treesitter" },
      { "a/plugin", dir = "/plugins/a" },
    },
    previous_snapshot = { { "z/plugin", version = "^1" } },
  }, function(dev, calls)
    local snapshot = dev.generate_snapshot(true)

    assert.same({ "a/plugin", "nvim-treesitter/nvim-treesitter", "z/plugin" }, plugin_names(snapshot))
    assert.equals("a-current", snapshot[1].commit)
    assert.equals("treesitter-current", snapshot[2].commit)
    assert.equals("z-current", snapshot[3].commit)
    assert.equals("^1", snapshot[3].version)
    assert.equals(3, #calls.commands)
    local git_calls = {}
    for _, call in ipairs(calls.commands) do
      local directory = call.command[3]
      git_calls[directory] = call
    end
    for _, directory in ipairs { "/plugins/a", "/plugins/treesitter", "/plugins/z" } do
      assert.same({
        command = { "git", "-C", directory, "rev-parse", "HEAD" },
        silent = false,
      }, git_calls[directory])
    end
    assert.equals(1, #calls.writes)

    local contents = calls.writes[1].contents
    assert.is_nil(contents:find("AstroNvim/AstroNvim", 1, true))
    assert.is_nil(contents:find("Bilal2453/luvit-meta", 1, true))
    assert.is_true(contents:find('"a/plugin"', 1, true) < contents:find('"nvim-treesitter/nvim-treesitter"', 1, true))
    assert.is_true(contents:find('"nvim-treesitter/nvim-treesitter"', 1, true) < contents:find('"z/plugin"', 1, true))
    assert.is_not_nil(contents:find('version = "^1"', 1, true))
    assert.is_not_nil(contents:find('commit = vim.fn.has "nvim-0.12" ~= 1 and ', 1, true))
    assert.is_not_nil(contents:find('or "treesitter-current"', 1, true))
  end)
end

T["DEV-02 writes snapshots only for development installs unless writing is disabled"] = function()
  for _, case in ipairs {
    { name = "non-development install", dev = false, write = nil, expected_writes = 0 },
    { name = "development install", dev = true, write = nil, expected_writes = 1 },
    { name = "explicitly disabled write", dev = true, write = false, expected_writes = 0 },
  } do
    with_dev({
      dev = case.dev,
      dir = "/workspace/AstroNvim",
      commits = { ["/plugins/example"] = "example-current\n" },
      plugins = { { "example/plugin", dir = "/plugins/example" } },
    }, function(dev, calls)
      dev.generate_snapshot(case.write)
      assert.equals(case.expected_writes, #calls.writes, case.name)
      if case.expected_writes == 1 then
        assert.equals("/workspace/AstroNvim/lua/astronvim/lazy_snapshot.lua", calls.writes[1].path)
        assert.equals("w+", calls.writes[1].mode)
      end
    end)
  end
end

T["DEV-03 preserves current pins empty snapshots and write errors"] = function()
  with_dev({
    dev = true,
    commits = { ["/plugins/version"] = "version-current\n", ["/plugins/commit"] = "commit-current\n" },
    plugins = {
      { "version/plugin", dir = "/plugins/version", version = "^7" },
      { "commit/plugin", dir = "/plugins/commit" },
    },
  }, function(dev, calls)
    local snapshot = dev.generate_snapshot()
    assert.equals("^7", snapshot[2].version)
    assert.equals("version-current", snapshot[2].commit)
    assert.is_nil(snapshot[1].version)
    assert.equals("commit-current", snapshot[1].commit)
    local contents = calls.writes[1].contents
    assert.is_not_nil(contents:find('version = "^7"', 1, true))
    assert.is_not_nil(contents:find('commit = "commit-current"', 1, true))
  end)

  with_dev({ dev = true, plugins = {} }, function(dev, calls)
    assert.same({}, dev.generate_snapshot())
    assert.equals(0, #calls.commands)
    assert.equals("return {\n}\n", calls.writes[1].contents)
  end)

  with_dev({
    dev = true,
    write_error = "write failed",
    commits = { ["/plugins/example"] = "example-current\n" },
    plugins = { { "example/plugin", dir = "/plugins/example" } },
  }, function(dev, calls)
    local ok, write_error = pcall(function() dev.generate_snapshot() end)
    assert.is_false(ok)
    assert.is_not_nil(tostring(write_error):find("write failed", 1, true))
    assert.same({}, calls.writes)
  end)
end

T["SNAPSHOT-01 keeps the explicit older-Neovim Treesitter release contract"] = function()
  for _, case in ipairs {
    { has_012 = 0, expected_treesitter_commit = "90cd6580e720caedacb91fdd587b747a6e77d61f" },
    { has_012 = 1, expected_treesitter_commit = "61df84986b4b4ec469ee745a182e433d49f8c27e" },
  } do
    local has_calls = {}
    unit_helpers.with_module("astronvim.lazy_snapshot", {
      vim = {
        fn = {
          has = function(feature)
            table.insert(has_calls, feature)
            return case.has_012
          end,
        },
      },
    }, function(snapshot)
      local names = {}
      local treesitter
      for _, plugin in ipairs(snapshot) do
        assert.is_nil(names[plugin[1]], "Duplicate snapshot plugin: " .. plugin[1])
        names[plugin[1]] = true
        assert.equals(true, plugin.optional, plugin[1])
        assert.is_true((plugin.commit ~= nil) ~= (plugin.version ~= nil), "Expected one pin for " .. plugin[1])
        if plugin[1] == "nvim-treesitter/nvim-treesitter" then treesitter = plugin end
      end
      assert.is_not_nil(treesitter)
      assert.equals(case.expected_treesitter_commit, treesitter.commit)
      assert.same({ "nvim-0.12" }, has_calls)
    end)
  end
end

return T
