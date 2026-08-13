local MiniTest = require "mini.test"
local environment = require "test_environment"

local T = MiniTest.new_set()

local function ready_environment()
  local fingerprint = environment.compatibility_fingerprint()
  return {
    marker = {
      schema = environment.schema,
      fingerprint = fingerprint,
      manifest = "manifest.json",
      lockfile = "lazy-lock.json",
    },
    manifest = {
      schema = environment.schema,
      fingerprint = fingerprint,
      lockfile = "lazy-lock.json",
      lazy = { path = "lazy.nvim", commit = "1234567" },
      plugin_root = "data/nvim/lazy",
      test_lua_dir = "lua",
      plugins = {
        ["mini.test"] = { path = "data/nvim/lazy/mini.test", commit = "abcdef0" },
      },
    },
    lock = { ["mini.test"] = { commit = "abcdef0" } },
  }
end

local function ready_paths()
  return {
    ["lazy.nvim"] = "directory",
    ["data/nvim/lazy"] = "directory",
    lua = "directory",
    ["lua/luassert"] = "directory",
    ["lua/luassert/init.lua"] = "file",
    ["lua/say"] = "directory",
    ["lua/say/init.lua"] = "file",
    ["data/nvim/lazy/mini.test"] = "directory",
  }
end

local function legacy_paths()
  local paths = environment.paths "/repository"
  paths.test_lua_dir = paths.test_root .. "/lua"
  return paths
end

T["ENV-00 keeps repository and test environment roots distinct"] = function()
  local paths = environment.paths "/repository"

  assert.equals("/repository", paths.root)
  assert.equals("/repository/.tests", paths.test_root)
  assert.equals("/repository/.tests.bootstrap", paths.staging_root)
  assert.equals("/repository/.tests.prepare.lock", paths.prepare_lock)
  assert.equals("/repository/.tests/lazy.nvim", paths.lazy_path)
  assert.equals("/repository/.tests/data/nvim/lazy", paths.plugin_root)
  assert.equals("/repository/.tests/data/nvim", paths.shared_data_dir)
  assert.equals("/repository/.tests/state", paths.state_dir)
  assert.equals("/repository/.tests/cache", paths.cache_dir)
  assert.equals("/repository/.tests/lua", paths.test_lua_dir)
  assert.equals("/repository/.tests/lazy-lock.json", paths.lockfile)
  assert.equals("/repository/.tests/manifest.json", paths.manifest)
  assert.equals("/repository/.tests/.ready", paths.ready)
end

T["ENV-00 constructs paths for arbitrary test roots"] = function()
  local paths = environment.paths_for_test_root "/temporary/runtime"

  assert.equals("/temporary/runtime", paths.test_root)
  assert.equals("/temporary/runtime/lazy.nvim", paths.lazy_path)
  assert.equals("/temporary/runtime/data/nvim/lazy", paths.plugin_root)
  assert.equals("/temporary/runtime/data/nvim", paths.shared_data_dir)
  assert.equals("/temporary/runtime/state", paths.state_dir)
  assert.equals("/temporary/runtime/cache", paths.cache_dir)
  assert.equals("/temporary/runtime/lua", paths.test_lua_dir)
  assert.equals("/temporary/runtime/lazy-lock.json", paths.lockfile)
  assert.equals("/temporary/runtime/manifest.json", paths.manifest)
  assert.equals("/temporary/runtime/.ready", paths.ready)
end

T["ENV-00 produces a deterministic compatibility fingerprint"] = function()
  local fingerprint = environment.compatibility_fingerprint()

  assert.equals(fingerprint, environment.compatibility_fingerprint())
  assert.equals(64, #fingerprint)
  assert.is_truthy(fingerprint:match "^[a-f0-9]+$" ~= nil)
end

T["ENV-01 classifies marked environments for offline reuse without mutation"] = function()
  local paths = environment.paths "/repository"
  local present = {}
  local calls = 0
  local function lstat(path)
    calls = calls + 1
    return present[path]
  end

  assert.equals("missing", environment.classify(paths, lstat))
  present[paths.test_root] = { type = "directory" }
  assert.equals("legacy", environment.classify(paths, lstat))
  present[paths.ready] = { type = "file" }
  assert.equals("marked", environment.classify(paths, lstat))
  assert.equals(5, calls)
end

T["ENV-02 accepts only canonical clear and staging targets"] = function()
  assert.is_true(environment.is_safe_relative_path "data/nvim/lazy/mini.test")
  assert.is_false(environment.is_safe_relative_path "")
  assert.is_false(environment.is_safe_relative_path "/tmp/.tests")
  assert.is_false(environment.is_safe_relative_path "../.tests")
  assert.is_false(environment.is_safe_relative_path "data//nvim")
  assert.is_false(environment.is_safe_relative_path "C:\\temp\\.tests")
  assert.is_true(environment.is_clear_target("/repository", "/repository/.tests"))
  assert.is_false(environment.is_clear_target("/repository", "/repository/.tests.bootstrap"))
  assert.is_true(environment.is_staging_target("/repository", "/repository/.tests.bootstrap"))
end

T["ENV-03 validates exact path types and concrete module entries"] = function()
  local fixture = ready_environment()
  local paths = ready_paths()

  local fingerprint = environment.compatibility_fingerprint()
  assert.is_true(environment.validate_ready(fixture.marker, fixture.manifest, fixture.lock, paths, fingerprint))
  paths["lua/say/init.lua"] = "directory"
  local valid, error_message =
    environment.validate_ready(fixture.marker, fixture.manifest, fixture.lock, paths, fingerprint)
  assert.is_false(valid)
  assert.is_true(error_message:find("lua/say/init.lua", 1, true) ~= nil)
end

T["ENV-04 rejects incompatible markers and mismatched locks"] = function()
  local fixture = ready_environment()
  local valid, error_message = environment.validate_ready({
    schema = environment.schema + 1,
    fingerprint = environment.compatibility_fingerprint(),
    manifest = "manifest.json",
    lockfile = "lazy-lock.json",
  }, fixture.manifest, fixture.lock, ready_paths())
  assert.is_false(valid)
  assert.is_true(error_message:find("marker schema", 1, true) ~= nil)

  fixture.lock["mini.test"].commit = "7654321"
  valid, error_message = environment.validate_ready(
    fixture.marker,
    fixture.manifest,
    fixture.lock,
    ready_paths(),
    environment.compatibility_fingerprint()
  )
  assert.is_false(valid)
  assert.is_true(error_message:find("does not match mini.test", 1, true) ~= nil)
end

T["ENV-04 rejects marked reuse through symlinked environment path components"] = function()
  local fixture = ready_environment()
  local paths = environment.paths "/repository"
  local entries = {
    [paths.root] = { type = "directory" },
    [paths.test_root] = { type = "directory" },
  }
  for relative_path, entry in pairs(ready_paths()) do
    entries[paths.test_root .. "/" .. relative_path] = { type = entry }
  end
  local function lstat(path) return entries[path] end
  local function path_type(relative_path, expected_type)
    return environment.has_safe_path_type(paths.root, paths.test_root .. "/" .. relative_path, expected_type, lstat)
  end

  entries[paths.test_root] = { type = "link" }
  local valid = environment.validate_ready(fixture.marker, fixture.manifest, fixture.lock, path_type)
  assert.is_false(valid)

  entries[paths.test_root] = { type = "directory" }
  entries[paths.test_root .. "/data"] = { type = "link" }
  valid = environment.validate_ready(fixture.marker, fixture.manifest, fixture.lock, path_type)
  assert.is_false(valid)
end

T["ENV-05 rejects legacy repositories with tracked modifications before adoption"] = function()
  assert.is_true(environment.can_adopt {
    ["mini.test"] = { installed = true, no_tracked_modifications = true, commit = "abcdef0" },
    luassert = { installed = true, no_tracked_modifications = true, commit = "1234567" },
  })

  local adoptable, error_message = environment.can_adopt {
    ["mini.test"] = { installed = true, no_tracked_modifications = false, commit = "abcdef0" },
  }
  assert.is_false(adoptable)
  assert.is_true(error_message:find("tracked modifications", 1, true) ~= nil)
  assert.is_true(error_message:find("mini.test", 1, true) ~= nil)
end

T["ENV-06 rejects partial legacy adoption before mutation"] = function()
  local paths = legacy_paths()
  local entries = {
    [paths.root] = { type = "directory" },
    [paths.test_root] = { type = "directory" },
    [paths.lazy_path] = { type = "directory" },
    [paths.plugin_root] = { type = "directory" },
    [paths.lockfile] = { type = "file" },
  }
  local valid, error_message = environment.validate_legacy_layout(paths, function(path) return entries[path] end)
  assert.is_false(valid)
  assert.is_true(error_message:find("partial lifecycle output", 1, true) ~= nil)

  entries[paths.lockfile] = nil
  entries[paths.test_lua_dir] = { type = "link" }
  valid, error_message = environment.validate_legacy_layout(paths, function(path) return entries[path] end)
  assert.is_false(valid)
  assert.is_true(error_message:find("symbolic-link path", 1, true) ~= nil)

  entries[paths.test_lua_dir] = nil
  entries[paths.test_root] = { type = "link" }
  valid, error_message = environment.validate_legacy_layout(paths, function(path) return entries[path] end)
  assert.is_false(valid)
  assert.is_true(error_message:find("test root", 1, true) ~= nil)

  entries[paths.test_root] = { type = "directory" }
  entries[paths.test_root .. "/data"] = { type = "link" }
  valid, error_message = environment.validate_legacy_layout(paths, function(path) return entries[path] end)
  assert.is_false(valid)
  assert.is_true(error_message:find("symbolic-link path component", 1, true) ~= nil)
end

T["ENV-07 validates fresh atomic publication targets"] = function()
  local entries = { ["/repository/.tests.bootstrap"] = { type = "directory" } }
  local filesystem = { lstat = function(path) return entries[path] end }

  assert.is_true(environment.can_publish_fresh(filesystem, "/repository/.tests.bootstrap", "/repository/.tests"))
  entries["/repository/.tests"] = { type = "link" }
  local publishable, error_message =
    environment.can_publish_fresh(filesystem, "/repository/.tests.bootstrap", "/repository/.tests")
  assert.is_false(publishable)
  assert.is_true(error_message:find("symbolic link", 1, true) ~= nil)

  entries["/repository/.tests"] = { type = "directory" }
  publishable, error_message =
    environment.can_publish_fresh(filesystem, "/repository/.tests.bootstrap", "/repository/.tests")
  assert.is_false(publishable)
  assert.is_true(error_message:find("already exists", 1, true) ~= nil)

  entries["/repository/.tests.bootstrap"] = nil
  entries["/repository/.tests"] = nil
  publishable, error_message =
    environment.can_publish_fresh(filesystem, "/repository/.tests.bootstrap", "/repository/.tests")
  assert.is_false(publishable)
  assert.is_true(error_message:find("missing", 1, true) ~= nil)
end

T["ENV-08 unlinks symbolic-link leaves without traversing them during cleanup"] = function()
  local entries = {
    ["/repository/.tests.bootstrap"] = { type = "directory" },
    ["/repository/.tests.bootstrap/copied.lua"] = { type = "file" },
    ["/repository/.tests.bootstrap/external"] = { type = "link" },
  }
  local removed = {}
  local filesystem = {
    lstat = function(path) return entries[path] end,
    scandir = function() return { "copied.lua", "external" } end,
    unlink = function(path)
      removed[path] = true
      entries[path] = nil
      return true
    end,
    rmdir = function() return true end,
  }

  local success = environment.remove_tree(filesystem, "/repository/.tests.bootstrap")
  assert.is_true(success)
  assert.is_true(removed["/repository/.tests.bootstrap/copied.lua"])
  assert.is_true(removed["/repository/.tests.bootstrap/external"])
end

T["ENV-08 unlinks a symbolic-link cleanup root without scanning its target"] = function()
  local entries = { ["/repository/.tests.bootstrap"] = { type = "link" } }
  local scanned = false
  local filesystem = {
    lstat = function(path) return entries[path] end,
    scandir = function()
      scanned = true
      return { "external" }
    end,
    unlink = function(path)
      entries[path] = nil
      return true
    end,
  }

  assert.is_true(environment.remove_tree(filesystem, "/repository/.tests.bootstrap"))
  assert.is_false(scanned)
  assert.equals(nil, entries["/repository/.tests.bootstrap"])
end

T["ENV-09 retries only explicit lock contention and releases the lock"] = function()
  local attempts = 0
  local waits = 0
  local filesystem = {
    mkdir = function()
      attempts = attempts + 1
      if attempts == 1 then return nil, "EEXIST: file already exists" end
      return true
    end,
    rmdir = function() return true end,
    now = function() return 0 end,
    wait = function() waits = waits + 1 end,
  }

  assert.equals(
    "prepared",
    environment.with_lifecycle_lock(filesystem, "/repository/.tests.prepare.lock", function() return "prepared" end)
  )
  assert.equals(2, attempts)
  assert.equals(1, waits)

  local ok, error_message = pcall(environment.with_lifecycle_lock, {
    mkdir = function() return nil, "EACCES" end,
    rmdir = function() return true end,
    now = function() return 0 end,
    wait = function() end,
  }, "/repository/.tests.prepare.lock", function() end)
  assert.is_false(ok)
  assert.is_true(error_message:find("EACCES", 1, true) ~= nil)
end

T["ENV-10 clears only the canonical environment and treats absence as a no-op"] = function()
  local entries = {
    ["/repository/.tests"] = { type = "directory" },
    ["/repository/.tests/cache"] = { type = "directory" },
    ["/repository/.tests/cache/state"] = { type = "file" },
  }
  local filesystem = {
    lstat = function(path) return entries[path] end,
    mkdir = function(path)
      entries[path] = { type = "directory" }
      return true
    end,
    rmdir = function(path)
      entries[path] = nil
      return true
    end,
    unlink = function(path)
      entries[path] = nil
      return true
    end,
    scandir = function(path)
      local children = {}
      local prefix = path .. "/"
      for candidate in pairs(entries) do
        local name = candidate:match("^" .. prefix .. "([^/]+)$")
        if name then table.insert(children, name) end
      end
      return children
    end,
    now = function() return 0 end,
    wait = function() end,
  }

  assert.is_true(environment.clear_test_environment(filesystem, "/repository"))
  assert.equals(nil, entries["/repository/.tests"])
  assert.equals(nil, entries["/repository/.tests.prepare.lock"])
  assert.is_false(environment.clear_test_environment(filesystem, "/repository"))
  assert.equals(nil, entries["/repository/.tests.prepare.lock"])
end

T["ENV-11 unlinks symbolic-link leaves while clearing the owned tree"] = function()
  local entries = {
    ["/repository/.tests"] = { type = "directory" },
    ["/repository/.tests/external"] = { type = "link" },
  }
  local filesystem = {
    lstat = function(path) return entries[path] end,
    mkdir = function(path)
      entries[path] = { type = "directory" }
      return true
    end,
    rmdir = function(path)
      entries[path] = nil
      return true
    end,
    scandir = function() return { "external" } end,
    unlink = function(path)
      entries[path] = nil
      return true
    end,
    now = function() return 0 end,
    wait = function() end,
  }

  assert.is_true(environment.clear_test_environment(filesystem, "/repository"))
  assert.equals(nil, entries["/repository/.tests/external"])
  assert.equals(nil, entries["/repository/.tests"])
  assert.equals(nil, entries["/repository/.tests.prepare.lock"])
end

T["ENV-12 releases locks after callback failures and aggregates release failures"] = function()
  local entries = {}
  local filesystem = {
    mkdir = function(path)
      entries[path] = { type = "directory" }
      return true
    end,
    rmdir = function(path)
      entries[path] = nil
      return true
    end,
    now = function() return 0 end,
    wait = function() end,
  }

  local lock_path = "/repository/.tests.prepare.lock"
  local ok, error_message = pcall(
    environment.with_lifecycle_lock,
    filesystem,
    lock_path,
    function() error("callback failure", 0) end
  )
  assert.is_false(ok)
  assert.is_true(error_message:find("callback failure", 1, true) ~= nil)
  assert.equals(nil, entries[lock_path])

  ok, error_message = pcall(environment.with_lifecycle_lock, {
    mkdir = function() return true end,
    rmdir = function() return nil, "EACCES" end,
    now = function() return 0 end,
    wait = function() end,
  }, lock_path, function() error("callback failure", 0) end)
  assert.is_false(ok)
  assert.is_true(error_message:find("callback failure", 1, true) ~= nil)
  assert.is_true(error_message:find("Failed to release", 1, true) ~= nil)
end

return T
