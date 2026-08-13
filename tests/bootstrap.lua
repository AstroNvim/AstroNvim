local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"
local environment = require "test_environment"

local function filesystem()
  return {
    lstat = vim.uv.fs_lstat,
    mkdir = function(path) return vim.uv.fs_mkdir(path, 448) end,
    rmdir = vim.uv.fs_rmdir,
    unlink = vim.uv.fs_unlink,
    scandir = function(path)
      local scanner, scan_error = vim.uv.fs_scandir(path)
      if not scanner then return nil, scan_error end
      local children = {}
      while true do
        local name = vim.uv.fs_scandir_next(scanner)
        if not name then break end
        table.insert(children, name)
      end
      return children
    end,
    now = vim.uv.hrtime,
    wait = vim.wait,
  }
end

local function run(command)
  local result = vim.system(command, { text = true }):wait()
  if result.code ~= 0 then
    error(("Command failed (%d): %s\n%s"):format(result.code, table.concat(command, " "), result.stderr), 0)
  end
  return result
end

local function read_json(path)
  local file = assert(io.open(path, "rb"))
  local contents = assert(file:read "*a")
  file:close()
  return vim.json.decode(contents)
end

local function unique_sibling(path, label) return path .. "." .. label .. "." .. tostring(vim.uv.hrtime()) end

local function write_json_atomic(path, value)
  local temporary_path = unique_sibling(path, "tmp")
  if vim.uv.fs_lstat(temporary_path) then error("Temporary lifecycle path already exists: " .. temporary_path, 0) end
  local write_result = vim.fn.writefile({ vim.json.encode(value) }, temporary_path)
  if write_result ~= 0 then error("Failed to write " .. temporary_path, 0) end
  if vim.uv.fs_rename(temporary_path, path) == nil then
    vim.uv.fs_unlink(temporary_path)
    error("Failed to atomically publish " .. path, 0)
  end
end

local function require_directory(path, label)
  local entry = vim.uv.fs_lstat(path)
  if not entry or entry.type ~= "directory" then error(label .. " is missing or is not a directory: " .. path, 0) end
end

local function require_file(path, label)
  local entry = vim.uv.fs_lstat(path)
  if not entry or entry.type ~= "file" then error(label .. " is missing or is not a file: " .. path, 0) end
end

local function ensure_directory(path)
  local entry = vim.uv.fs_lstat(path)
  if entry then
    if entry.type ~= "directory" then error("Refusing to use a non-directory path: " .. path, 0) end
    return false
  end
  local created, create_error = vim.uv.fs_mkdir(path, 448)
  if not created then error("Failed to create directory " .. path .. ": " .. tostring(create_error), 0) end
  return true
end

local function copy_directory(source, destination)
  require_directory(source, "Copy source")
  if vim.uv.fs_lstat(destination) then error("Copy destination already exists: " .. destination, 0) end
  ensure_directory(destination)

  local scanner, scan_error = vim.uv.fs_scandir(source)
  if not scanner then error(("Failed to scan directory %s: %s"):format(source, scan_error), 0) end
  while true do
    local name = vim.uv.fs_scandir_next(scanner)
    if not name then break end
    local source_path = vim.fs.joinpath(source, name)
    local destination_path = vim.fs.joinpath(destination, name)
    local source_entry = vim.uv.fs_lstat(source_path)
    if not source_entry or source_entry.type == "link" then
      error("Refusing to copy a symbolic-link or missing source: " .. source_path, 0)
    end
    if source_entry.type == "directory" then
      copy_directory(source_path, destination_path)
    elseif source_entry.type == "file" then
      local copied, copy_error = vim.uv.fs_copyfile(source_path, destination_path)
      if not copied then error(("Failed to copy %s: %s"):format(source_path, copy_error), 0) end
    else
      error("Refusing to copy an unsupported source type: " .. source_path, 0)
    end
  end
end

local function remove_staging(paths)
  config.assert_staging_path(paths.root)
  local removed, remove_error = environment.remove_tree(filesystem(), paths.root)
  if not removed then error("Failed to remove test staging path: " .. remove_error, 0) end
end

local function with_prepare_lock(callback)
  return environment.with_lifecycle_lock(filesystem(), config.prepare_lock, callback)
end

local function test_spec()
  local dependencies = environment.managed_dependencies
  local root_plugin = dependencies.root_plugin
  local spec = {
    {
      dir = config.root,
      name = root_plugin.name,
      lazy = root_plugin.lazy,
      priority = root_plugin.priority,
      opts = root_plugin.options,
    },
    { import = dependencies.import },
  }
  for _, plugin in ipairs(dependencies.plugins) do
    table.insert(spec, { plugin })
  end
  vim.list_extend(spec, dependencies.overrides)
  return spec
end

local function setup_lazy(paths)
  vim.o.loadplugins = true
  vim.env.LAZY = paths.lazy_path
  vim.opt.rtp:prepend(config.root)
  vim.opt.rtp:prepend(paths.lazy_path)
  package.path = config.root .. "/lua/?.lua;" .. config.root .. "/lua/?/init.lua;" .. package.path

  require("lazy").setup {
    root = paths.plugin_root,
    lockfile = paths.lockfile,
    local_spec = false,
    spec = test_spec(),
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    pkg = { cache = paths.state_dir .. "/lazy/pkg-cache.lua" },
    rocks = { enabled = false },
    readme = { root = paths.state_dir .. "/lazy/readme" },
    state = paths.state_dir .. "/lazy/state.json",
    headless = { process = true, log = true, task = true, colors = false },
    git = { cooldown = 0 },
    performance = { cache = { enabled = false } },
  }
end

local function assert_lazy_task_success(stage)
  local Plugin = require "lazy.core.plugin"
  local failures = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    if Plugin.has_errors(plugin) then
      local output = {}
      for _, task in ipairs(plugin._.tasks or {}) do
        if task:has_errors() then table.insert(output, task.name .. ": " .. task:output(vim.log.levels.ERROR)) end
      end
      table.insert(failures, name .. " (" .. table.concat(output, "; ") .. ")")
    end
  end
  table.sort(failures)
  if #failures > 0 then error(("Lazy %s failed: %s"):format(stage, table.concat(failures, ", ")), 0) end
end

local function inspect_repository(path)
  local entry = vim.uv.fs_lstat(path)
  if not entry or entry.type ~= "directory" then return nil, "missing or invalid repository directory" end

  local revision = vim
    .system({ "env", "GIT_OPTIONAL_LOCKS=0", "git", "-C", path, "rev-parse", "HEAD" }, { text = true })
    :wait()
  if revision.code ~= 0 then return nil, "cannot read repository HEAD" end
  local status = vim
    .system(
      { "env", "GIT_OPTIONAL_LOCKS=0", "git", "-C", path, "status", "--porcelain", "--untracked-files=no" },
      { text = true }
    )
    :wait()
  if status.code ~= 0 or status.stdout ~= "" then return nil, "repository has tracked modifications" end
  return vim.trim(revision.stdout)
end

local function managed_plugins(paths)
  local plugins = require("lazy.core.config").plugins
  local manifest_plugins = {}
  local lock = {}
  local adoption_plugins = {}
  local failures = {}

  local lazy_commit, lazy_error = inspect_repository(paths.lazy_path)
  if not lazy_commit then table.insert(failures, "lazy.nvim " .. lazy_error) end

  for name, plugin in pairs(plugins) do
    if plugin.url and not plugin._.is_local then
      local expected_path = paths.plugin_root .. "/" .. name
      local installed = plugin._.installed and plugin.dir == expected_path
      local commit
      local repository_error
      if installed then
        commit, repository_error = inspect_repository(expected_path)
      end
      adoption_plugins[name] = { installed = installed, no_tracked_modifications = commit ~= nil, commit = commit }
      if not installed then
        table.insert(failures, name .. " is not installed at its expected path")
      elseif not commit then
        table.insert(failures, name .. " " .. repository_error)
      else
        local entry = { commit = commit }
        if type(plugin.branch) == "string" and plugin.branch ~= "" then entry.branch = plugin.branch end
        lock[name] = entry
        manifest_plugins[name] = { path = "data/nvim/lazy/" .. name, commit = commit }
      end
    end
  end

  local adoptable, adoption_error = environment.can_adopt(adoption_plugins)
  if not adoptable then table.insert(failures, adoption_error) end
  table.sort(failures)
  if #failures > 0 then return nil, nil, table.concat(failures, "; ") end

  return {
    schema = environment.schema,
    fingerprint = environment.compatibility_fingerprint(config.root),
    lockfile = "lazy-lock.json",
    lazy = { path = "lazy.nvim", commit = lazy_commit },
    plugin_root = "data/nvim/lazy",
    test_lua_dir = "lua",
    plugins = manifest_plugins,
  },
    lock
end

local function copy_test_libraries(paths, destination_lua_dir)
  local luassert_source = paths.plugin_root .. "/luassert/src"
  local say_source = paths.plugin_root .. "/say/src/say"
  require_file(luassert_source .. "/init.lua", "luassert module entry")
  require_file(say_source .. "/init.lua", "say module entry")
  copy_directory(luassert_source, destination_lua_dir .. "/luassert")
  copy_directory(say_source, destination_lua_dir .. "/say")
end

local function validate_staged_environment(paths, manifest, lock, lua_root)
  local fingerprint = environment.compatibility_fingerprint(config.root)
  local valid, validation_error = environment.validate_ready(
    { schema = environment.schema, fingerprint = fingerprint, manifest = "manifest.json", lockfile = "lazy-lock.json" },
    manifest,
    lock,
    function(relative_path, expected_type)
      local root
      if relative_path:sub(1, 4) == "lua/" or relative_path == "lua" then
        root = lua_root
      else
        root = paths.test_root
      end
      local entry = vim.uv.fs_lstat(root .. "/" .. relative_path)
      return entry and entry.type == expected_type
    end,
    fingerprint
  )
  if not valid then error("Generated test environment is invalid: " .. validation_error, 0) end
end

local function create_fresh_environment()
  local staging = config.paths_for_test_root(config.staging_root)
  remove_staging(staging)
  local publishable, publish_error = environment.can_publish_fresh(filesystem(), staging.root, config.test_root)
  if publishable or publish_error ~= "fresh staging environment is missing" then
    error("Test environment publication is unsafe: " .. tostring(publish_error), 0)
  end

  ensure_directory(staging.root)
  ensure_directory(staging.root .. "/data")
  ensure_directory(staging.shared_data_dir)
  ensure_directory(staging.test_lua_dir)
  ensure_directory(staging.state_dir)
  ensure_directory(staging.cache_dir)

  vim.env.LAZY_OFFLINE = nil
  run {
    "git",
    "clone",
    "--depth=1",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    staging.lazy_path,
  }
  setup_lazy(staging)
  require("lazy").sync { wait = true, show = false }
  assert_lazy_task_success "sync"

  local manifest, _, failure = managed_plugins(staging)
  if failure then error("Managed plugin verification failed: " .. failure, 0) end
  copy_test_libraries(staging, staging.test_lua_dir)
  local generated_lock = read_json(staging.lockfile)
  validate_staged_environment(staging, manifest, generated_lock, staging.root)
  write_json_atomic(staging.manifest, manifest)
  write_json_atomic(staging.ready, {
    schema = environment.schema,
    fingerprint = environment.compatibility_fingerprint(config.root),
    manifest = "manifest.json",
    lockfile = "lazy-lock.json",
  })

  local safe_to_publish, safety_error = environment.can_publish_fresh(filesystem(), staging.root, config.test_root)
  if not safe_to_publish then error("Failed to atomically publish test environment: " .. safety_error, 0) end
  if vim.uv.fs_rename(staging.root, config.test_root) == nil then
    error(("Failed to atomically publish test environment: %s"):format(config.test_root), 0)
  end
end

local function stage_legacy_artifacts(manifest, lock)
  local staging_root = unique_sibling(config.test_root, "adoption")
  local staging = config.paths_for_test_root(staging_root)
  local ok, result = xpcall(function()
    ensure_directory(staging.root)
    ensure_directory(staging.test_lua_dir)
    copy_test_libraries(config, staging.test_lua_dir)
    write_json_atomic(staging.lockfile, lock)
    write_json_atomic(staging.manifest, manifest)
    write_json_atomic(staging.ready, {
      schema = environment.schema,
      fingerprint = environment.compatibility_fingerprint(config.root),
      manifest = "manifest.json",
      lockfile = "lazy-lock.json",
    })
    validate_staged_environment(config, manifest, lock, staging.root)
  end, debug.traceback)
  if not ok then
    local removed, remove_error = environment.remove_tree(filesystem(), staging.root)
    if not removed then result = result .. "\nFailed adoption staging cleanup: " .. tostring(remove_error) end
    error(result, 0)
  end
  return staging
end

local function remove_generated_file(path)
  local entry = vim.uv.fs_lstat(path)
  if not entry then return true end
  if entry.type ~= "file" then return false, "refusing to remove a non-file generated path: " .. path end
  local removed, remove_error = vim.uv.fs_unlink(path)
  return removed, remove_error
end

local function publish_legacy_artifacts(staging)
  local created_lua
  local backups = {}
  local installed = {}
  local published_files = {}
  local marker_published = false
  local token = tostring(vim.uv.hrtime())

  local function restore_legacy()
    local failures = {}
    for _, path in ipairs(published_files) do
      local removed, remove_error = remove_generated_file(path)
      if not removed then table.insert(failures, tostring(remove_error)) end
    end
    for _, name in ipairs { "say", "luassert" } do
      local target = config.test_lua_dir .. "/" .. name
      if installed[name] then
        local removed, remove_error = environment.remove_tree(filesystem(), target)
        if not removed then table.insert(failures, remove_error) end
      end
      local backup = backups[name]
      if backup and vim.uv.fs_lstat(backup) and vim.uv.fs_rename(backup, target) == nil then
        table.insert(failures, "failed to restore legacy library: " .. name)
      end
    end
    if created_lua then
      local removed = vim.uv.fs_rmdir(config.test_lua_dir)
      if not removed then table.insert(failures, "failed to remove generated lua directory") end
    end
    local removed, remove_error = environment.remove_tree(filesystem(), staging.root)
    if not removed then table.insert(failures, remove_error) end
    return failures
  end

  local ok, result = xpcall(function()
    created_lua = ensure_directory(config.test_lua_dir)
    for _, name in ipairs { "luassert", "say" } do
      local target = config.test_lua_dir .. "/" .. name
      local target_entry = vim.uv.fs_lstat(target)
      if target_entry then
        if target_entry.type ~= "directory" then error("Legacy library target is not a directory: " .. target, 0) end
        local backup = config.test_lua_dir .. "/." .. name .. ".adoption-backup." .. token
        if vim.uv.fs_lstat(backup) or vim.uv.fs_rename(target, backup) == nil then
          error("Failed to preserve legacy library before adoption: " .. target, 0)
        end
        backups[name] = backup
      end
      if vim.uv.fs_rename(staging.test_lua_dir .. "/" .. name, target) == nil then
        error("Failed to atomically publish copied library: " .. target, 0)
      end
      installed[name] = true
    end

    for _, file in ipairs { { staging.lockfile, config.lockfile }, { staging.manifest, config.manifest } } do
      if vim.uv.fs_rename(file[1], file[2]) == nil then error("Failed to atomically publish " .. file[2], 0) end
      table.insert(published_files, file[2])
    end
    if vim.uv.fs_rename(staging.ready, config.ready) == nil then error("Failed to publish .ready marker", 0) end
    table.insert(published_files, config.ready)
    marker_published = true

    local cleanup_failures = {}
    for _, backup in pairs(backups) do
      local removed, remove_error = environment.remove_tree(filesystem(), backup)
      if not removed then table.insert(cleanup_failures, "Failed to remove adoption backup: " .. remove_error) end
    end
    local removed, remove_error = environment.remove_tree(filesystem(), staging.root)
    if not removed then table.insert(cleanup_failures, "Failed to remove adoption staging: " .. remove_error) end
    if #cleanup_failures > 0 then
      vim.notify(
        "Test environment published with cleanup warnings: " .. table.concat(cleanup_failures, "; "),
        vim.log.levels.WARN
      )
    end
  end, debug.traceback)

  if not ok then
    if marker_published then error(result, 0) end
    local cleanup_failures = restore_legacy()
    if #cleanup_failures > 0 then
      result = result .. "\nAdoption cleanup failed: " .. table.concat(cleanup_failures, "; ")
    end
    error(result, 0)
  end
end

local function legacy_runtime_paths()
  local runtime = config.paths_for_test_root(vim.fn.tempname())
  ensure_directory(runtime.root)
  ensure_directory(runtime.root .. "/data")
  ensure_directory(runtime.shared_data_dir)
  ensure_directory(runtime.state_dir)
  ensure_directory(runtime.cache_dir)
  runtime.lazy_path = config.lazy_path
  runtime.plugin_root = config.plugin_root
  return runtime
end

local function adopt_legacy_environment()
  local valid_layout, layout_error = environment.validate_legacy_layout(config, vim.uv.fs_lstat)
  if not valid_layout then
    error(
      ("Legacy test environment cannot be adopted safely. Run `make test-clear` then retry: %s"):format(layout_error),
      0
    )
  end

  vim.env.LAZY_OFFLINE = "1"
  local runtime = legacy_runtime_paths()
  local setup_ok, setup_error = pcall(setup_lazy, runtime)
  local manifest, lock, failure
  if setup_ok then
    manifest, lock, failure = managed_plugins(config)
  end
  local removed, remove_error = environment.remove_tree(filesystem(), runtime.root)
  if not removed then error(("Failed to remove temporary legacy validation state: %s"):format(remove_error), 0) end
  if not setup_ok then
    error(
      ("Legacy test environment cannot be adopted offline. Run `make test-clear` then retry: %s"):format(setup_error),
      0
    )
  end
  if failure then
    error(
      ("Legacy test environment cannot be adopted offline. Run `make test-clear` then retry: %s"):format(failure),
      0
    )
  end

  local staging = stage_legacy_artifacts(manifest, lock)
  publish_legacy_artifacts(staging)
end

with_prepare_lock(function()
  local state = config.classify_environment()
  if state == "marked" then
    vim.env.LAZY_OFFLINE = "1"
    local valid, validation_error = config.validate_ready_environment()
    if not valid then
      error(
        ("Test environment is incomplete or incompatible. Run `make test-clear` then retry: %s"):format(
          validation_error
        ),
        0
      )
    end
    return
  end
  if state == "legacy" then
    adopt_legacy_environment()
    return
  end

  local ok, err = xpcall(create_fresh_environment, debug.traceback)
  if not ok then
    local staging = config.paths_for_test_root(config.staging_root)
    local cleanup_ok, cleanup_error = pcall(remove_staging, staging)
    if not cleanup_ok then err = err .. "\nFailed staging cleanup: " .. tostring(cleanup_error) end
    error(err, 0)
  end
end)
