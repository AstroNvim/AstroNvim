local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function assert_contains(value, expected) assert.is_true(tostring(value):find(expected, 1, true) ~= nil) end

local function with_helpers(options, callback)
  options = options or {}
  local state = {
    child_constructions = 0,
    copied_files = {},
    deleted_roots = {},
    jobs_alive = {},
    jobstop_ids = {},
    jobwait_ids = {},
    list_chans_calls = 0,
    mkdir_paths = {},
    mkdtemp_template = nil,
    start_arguments = nil,
    stop_attempts = 0,
    system_commands = {},
  }
  local root = options.root or "/fixture-root"
  if options.job_id then state.jobs_alive[options.job_id] = true end
  for _, channel in ipairs(options.channels or {}) do
    if options.channel_alive ~= false then state.jobs_alive[channel.id] = true end
  end

  local child = {
    job = options.job_id and { id = options.job_id } or nil,
    start = function(arguments)
      state.start_arguments = arguments
      if options.start_error then error(options.start_error) end
    end,
    is_running = function()
      if options.is_running_error then error(options.is_running_error) end
      return options.child_running ~= false
    end,
    stop = function()
      state.stop_attempts = state.stop_attempts + 1
      if options.stop_error then error(options.stop_error) end
      if options.job_id and not options.stop_leaves_job_alive then state.jobs_alive[options.job_id] = false end
    end,
  }
  state.child = child

  return unit_helpers.with_module("helpers", {
    loaded = {
      config = {
        child_height = 30,
        child_width = 100,
        fixture_init = "/fixture-init.lua",
        fixture_project = "/fixture-project",
        lazy_path = "/lazy.nvim",
        lockfile = "/lazy-lock.json",
        plugin_root = "/plugins",
        root = "/astronvim",
        wait_timeout = 100,
      },
      ["mini.test"] = {
        new_child_neovim = function()
          state.child_constructions = state.child_constructions + 1
          if options.construction_error then error(options.construction_error) end
          return child
        end,
      },
    },
    vim = {
      api = {
        nvim_list_chans = function()
          state.list_chans_calls = state.list_chans_calls + 1
          if state.list_chans_calls == 1 then return options.initial_channels or {} end
          return options.channels or {}
        end,
      },
      fn = {
        delete = function(path)
          table.insert(state.deleted_roots, path)
          return options.delete_result or 0
        end,
        fnameescape = function(path) return path end,
        isdirectory = function(path)
          if options.isdirectory_result then return options.isdirectory_result(path, #state.mkdir_paths) end
          return 1
        end,
        jobstop = function(job_id)
          table.insert(state.jobstop_ids, job_id)
          if not options.jobstop_survives then state.jobs_alive[job_id] = false end
        end,
        jobwait = function(job_ids)
          local result = {}
          for _, job_id in ipairs(job_ids) do
            table.insert(state.jobwait_ids, job_id)
            table.insert(result, state.jobs_alive[job_id] and -1 or 0)
          end
          return result
        end,
        mkdir = function(path)
          table.insert(state.mkdir_paths, path)
          if options.mkdir_result then return options.mkdir_result(path, #state.mkdir_paths) end
          return 1
        end,
        writefile = function() return options.writefile_result or 0 end,
      },
      system = function(command)
        table.insert(state.system_commands, command)
        return {
          wait = function()
            if options.system_result then
              local result = options.system_result(command, #state.system_commands)
              if result then return result end
            end
            return { code = 0, stderr = "" }
          end,
        }
      end,
      uv = {
        fs_copyfile = function(source, destination)
          if options.copy_error then return nil, options.copy_error end
          table.insert(state.copied_files, { source, destination })
          return true
        end,
        fs_mkdtemp = function(template)
          state.mkdtemp_template = template
          return root
        end,
        fs_scandir = function(path) return { path = path, index = 0 } end,
        fs_scandir_next = function(scanner)
          scanner.index = scanner.index + 1
          if scanner.path == "/fixture-project" and scanner.index == 1 then return "plain.txt", "file" end
        end,
        os_getenv = function() return nil end,
        os_tmpdir = function() return "/portable-temp" end,
      },
    },
  }, function(helpers) return callback(helpers, state, root) end)
end

T["PORT-01 creates fixtures under the platform temp directory and copies them through libuv"] = function()
  with_helpers({}, function(helpers, state, root)
    local child = helpers.start_child()
    assert.equals(root .. "/project", helpers.fixture_project(child))
    helpers.stop_child(child)

    assert.equals("/portable-temp/a.XXXXXX", state.mkdtemp_template)
    assert.same({ { "/fixture-project/plain.txt", root .. "/project/plain.txt" } }, state.copied_files)
    for _, command in ipairs(state.system_commands) do
      assert.is_true(command[1] ~= "cp")
    end
    assert.same({ root }, state.deleted_roots)
  end)
end

T["TEST-05 removes the fixture root when directory creation fails"] = function()
  with_helpers({
    isdirectory_result = function() return 0 end,
    mkdir_result = function() return 0 end,
  }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)

    assert.is_false(ok)
    assert_contains(err, "Failed to create test fixture directory: " .. root .. "/config")
    assert.equals(0, state.child_constructions)
    assert.same({ root }, state.deleted_roots)
  end)
end

T["TEST-05 removes the fixture root when copying the fixture fails"] = function()
  with_helpers({ copy_error = "copy failed" }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)

    assert.is_false(ok)
    assert_contains(err, "Failed to copy fixture project: copy failed")
    assert.equals(0, state.child_constructions)
    assert.same({ root }, state.deleted_roots)
  end)
end

T["TEST-05 removes the fixture root when Git initialization fails"] = function()
  with_helpers({
    system_result = function(command)
      if command[1] == "git" and command[2] == "init" then return { code = 1, stderr = "Git initialization failed" } end
    end,
  }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)

    assert.is_false(ok)
    assert_contains(err, "Failed to initialize fixture Git repository: Git initialization failed")
    assert.equals(0, state.child_constructions)
    assert.same({ root }, state.deleted_roots)
  end)
end

T["TEST-05 removes the fixture root when child construction fails"] = function()
  with_helpers({ construction_error = "child construction failed" }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)

    assert.is_false(ok)
    assert_contains(err, "child construction failed")
    assert.equals(1, state.child_constructions)
    assert.same({ root }, state.deleted_roots)
  end)
end

T["TEST-05 stops a child and removes its fixture root after startup fails"] = function()
  with_helpers(
    { job_id = 42, start_error = "child startup failed", stop_leaves_job_alive = true },
    function(helpers, state, root)
      local ok, err = pcall(helpers.start_child)
      local fixture_available = pcall(helpers.fixture_project, state.child)

      assert.is_false(ok)
      assert_contains(err, "child startup failed")
      assert.equals(1, state.stop_attempts)
      assert.same({ 42 }, state.jobstop_ids)
      assert.is_true(#state.jobwait_ids >= 1)
      assert.is_false(state.jobs_alive[42])
      assert.same({ root }, state.deleted_roots)
      assert.is_false(fixture_available)
    end
  )
end

T["TEST-05 discovers and cleans a fixture channel when startup fails before assigning a child job"] = function()
  with_helpers({
    channels = { { id = 43, argv = { "nvim", "-u", "/fixture-init.lua" } } },
    jobstop_survives = true,
    start_error = "child startup failed",
    stop_error = { kind = "channel stop failure" },
  }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)
    local fixture_available = pcall(helpers.fixture_project, state.child)

    assert.is_false(ok)
    assert_contains(err, "child startup failed")
    assert_contains(err, 'kind = "channel stop failure"')
    assert_contains(err, "Child Neovim processes survived shutdown: 43")
    assert.same({ 43 }, state.jobstop_ids)
    assert.is_true(#state.jobwait_ids >= 2)
    assert.is_true(state.jobs_alive[43])
    assert.same({ root }, state.deleted_roots)
    assert.is_false(fixture_available)
  end)
end

T["TEST-05 preserves child stop errors while releasing the fixture"] = function()
  with_helpers({ job_id = 42, stop_error = "child stop failed" }, function(helpers, state, root)
    local child = helpers.start_child()
    local project = helpers.fixture_project(child)
    local ok, err = pcall(helpers.stop_child, child)
    local fixture_available = pcall(helpers.fixture_project, child)

    assert.equals(root .. "/project", project)
    assert.is_false(ok)
    assert_contains(err, "child stop failed")
    assert.equals(1, state.stop_attempts)
    assert.same({ 42 }, state.jobstop_ids)
    assert.is_false(state.jobs_alive[42])
    assert.same({ root }, state.deleted_roots)
    assert.is_false(fixture_available)
  end)
end

T["TEST-05 reports surviving child jobs together with non-string stop errors"] = function()
  with_helpers({
    job_id = 42,
    jobstop_survives = true,
    stop_error = { kind = "stop failure" },
  }, function(helpers, state, root)
    local child = helpers.start_child()
    local ok, err = pcall(helpers.stop_child, child)
    local fixture_available = pcall(helpers.fixture_project, child)

    assert.is_false(ok)
    assert_contains(err, 'kind = "stop failure"')
    assert_contains(err, "Child Neovim process survived shutdown")
    assert.same({ 42 }, state.jobstop_ids)
    assert.is_true(#state.jobwait_ids >= 2)
    assert.is_true(state.jobs_alive[42])
    assert.same({ root }, state.deleted_roots)
    assert.is_false(fixture_available)
  end)
end

T["TEST-05 reports root deletion failures after releasing child state"] = function()
  with_helpers({ delete_result = 1 }, function(helpers, state, root)
    local child = helpers.start_child()
    local ok, err = pcall(helpers.stop_child, child)
    local fixture_available = pcall(helpers.fixture_project, child)

    assert.is_false(ok)
    assert_contains(err, "Failed to delete test fixture root: " .. root)
    assert.same({ root }, state.deleted_roots)
    assert.is_false(fixture_available)
  end)
end

T["TEST-05 aggregates startup and cleanup errors"] = function()
  with_helpers({
    delete_result = 1,
    job_id = 42,
    start_error = "child startup failed",
    stop_error = "child stop failed",
  }, function(helpers, state, root)
    local ok, err = pcall(helpers.start_child)
    local fixture_available = pcall(helpers.fixture_project, state.child)

    assert.is_false(ok)
    assert_contains(err, "child startup failed")
    assert_contains(err, "Failed child cleanup:")
    assert_contains(err, "child stop failed")
    assert_contains(err, "Failed to delete test fixture root: " .. root)
    assert.equals(1, state.stop_attempts)
    assert.same({ root }, state.deleted_roots)
    assert.is_false(fixture_available)
  end)
end

return T
