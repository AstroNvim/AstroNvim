local M = {}

M.schema = 2
M.managed_layout = {
  lazy_path = "lazy.nvim",
  plugin_root = "data/nvim/lazy",
  test_lua_dir = "lua",
  lockfile = "lazy-lock.json",
  manifest = "manifest.json",
  ready = ".ready",
  copied_libraries = { "luassert:src", "say:src/say" },
}
M.dependency_spec_paths = { "lua/astronvim/plugins" }
M.managed_dependencies = {
  root_plugin = {
    name = "AstroNvim",
    lazy = false,
    priority = 10000,
    options = { icons_enabled = false, pin_plugins = false, update_notification = false },
  },
  import = "astronvim.plugins",
  plugins = { "echasnovski/mini.test", "lunarmodules/luassert", "Olivine-Labs/say" },
  overrides = { { "mason-org/mason.nvim", build = false } },
}

local function is_table(value) return type(value) == "table" end

local function is_commit(value) return type(value) == "string" and value:match "^[0-9a-f]+$" ~= nil and #value >= 7 end

local function entry_type(entry)
  if type(entry) == "string" then return entry end
  return is_table(entry) and entry.type or nil
end

local function has_expected_type(path_metadata, path, expected_type)
  if type(path_metadata) == "function" then return path_metadata(path, expected_type) == true end
  return entry_type(path_metadata and path_metadata[path]) == expected_type
end

function M.is_safe_relative_path(path)
  if type(path) ~= "string" or path == "" then return false end
  if path:sub(1, 1) == "/" or path:match "^[A-Za-z]:" or path:find("\\", 1, true) then return false end
  for segment in path:gmatch "[^/]+" do
    if segment == "." or segment == ".." then return false end
  end
  return not path:find("//", 1, true) and path:sub(-1) ~= "/"
end

function M.find_symlink_component(root, path, lstat)
  if type(root) ~= "string" or type(path) ~= "string" or type(lstat) ~= "function" then return path end
  local prefix = root .. "/"
  if path ~= root and path:sub(1, #prefix) ~= prefix then return path end

  if entry_type(lstat(root)) == "link" then return root end
  local current = root
  for segment in path:sub(#prefix + 1):gmatch "[^/]+" do
    current = current .. "/" .. segment
    if entry_type(lstat(current)) == "link" then return current end
  end
end

function M.has_safe_path_type(root, path, expected_type, lstat)
  return M.find_symlink_component(root, path, lstat) == nil and entry_type(lstat(path)) == expected_type
end

function M.paths_for_test_root(test_root)
  local layout = M.managed_layout
  return {
    test_root = test_root,
    lazy_path = test_root .. "/" .. layout.lazy_path,
    plugin_root = test_root .. "/" .. layout.plugin_root,
    test_lua_dir = test_root .. "/" .. layout.test_lua_dir,
    lockfile = test_root .. "/" .. layout.lockfile,
    manifest = test_root .. "/" .. layout.manifest,
    ready = test_root .. "/" .. layout.ready,
    shared_data_dir = test_root .. "/data/nvim",
    state_dir = test_root .. "/state",
    cache_dir = test_root .. "/cache",
  }
end

local function normalize_path(path) return path:gsub("\\", "/") end

local function collect_dependency_spec_files(root)
  local files = {}
  local function collect(relative_path)
    local absolute_path = vim.fs.joinpath(root, relative_path)
    local entry = vim.uv.fs_lstat(absolute_path)
    if not entry then error("Missing managed dependency specification path: " .. relative_path, 0) end
    if entry.type == "file" then
      table.insert(files, normalize_path(relative_path))
      return
    end
    if entry.type ~= "directory" then
      error("Unsupported managed dependency specification path: " .. relative_path, 0)
    end

    local scanner = assert(vim.uv.fs_scandir(absolute_path))
    while true do
      local name, child_type = vim.uv.fs_scandir_next(scanner)
      if not name then break end
      local child = normalize_path(vim.fs.joinpath(relative_path, name))
      if child_type == "directory" then
        collect(child)
      elseif child_type == "file" and name:sub(-4) == ".lua" then
        table.insert(files, child)
      end
    end
  end

  for _, path in ipairs(M.dependency_spec_paths) do
    collect(path)
  end
  table.sort(files)
  return files
end

local function dependency_spec_digest(root)
  local chunks = {}
  for _, path in ipairs(collect_dependency_spec_files(root)) do
    local file = assert(io.open(vim.fs.joinpath(root, path), "rb"))
    local contents = assert(file:read "*a")
    file:close()
    table.insert(chunks, path .. "\0" .. contents)
  end
  return vim.fn.sha256(table.concat(chunks, "\0"))
end

function M.compatibility_fingerprint(root)
  root = root or vim.fn.getcwd()
  local dependencies = M.managed_dependencies
  local layout = M.managed_layout
  local root_plugin = dependencies.root_plugin
  return vim.fn.sha256(table.concat({
    "schema=" .. M.schema,
    "layout="
      .. table.concat(
        { layout.lazy_path, layout.plugin_root, layout.test_lua_dir, layout.lockfile, layout.manifest, layout.ready },
        "|"
      ),
    "copied_libraries=" .. table.concat(layout.copied_libraries, "|"),
    "root_plugin=" .. table.concat({
      root_plugin.name,
      tostring(root_plugin.lazy),
      tostring(root_plugin.priority),
      tostring(root_plugin.options.icons_enabled),
      tostring(root_plugin.options.pin_plugins),
      tostring(root_plugin.options.update_notification),
    }, "|"),
    "import=" .. dependencies.import,
    "plugins=" .. table.concat(dependencies.plugins, "|"),
    "overrides=mason-org/mason.nvim:build=false",
    "dependency_spec=" .. dependency_spec_digest(root),
  }, "\n"))
end

function M.paths(root)
  local paths = {
    root = root,
    test_root = root .. "/.tests",
    staging_root = root .. "/.tests.bootstrap",
    prepare_lock = root .. "/.tests.prepare.lock",
  }
  for name, value in pairs(M.paths_for_test_root(paths.test_root)) do
    paths[name] = value
  end
  return paths
end

function M.classify(paths, lstat)
  if not lstat(paths.test_root) then return "missing" end
  if lstat(paths.ready) then return "marked" end
  return "legacy"
end

function M.is_clear_target(root, target) return target == root .. "/.tests" end

function M.is_staging_target(root, target) return target == root .. "/.tests.bootstrap" end

function M.required_paths(manifest)
  local paths = {
    { path = manifest.lazy.path, type = "directory" },
    { path = manifest.plugin_root, type = "directory" },
    { path = manifest.test_lua_dir, type = "directory" },
    { path = "lua/luassert", type = "directory" },
    { path = "lua/luassert/init.lua", type = "file" },
    { path = "lua/say", type = "directory" },
    { path = "lua/say/init.lua", type = "file" },
  }
  for _, plugin in pairs(manifest.plugins) do
    table.insert(paths, { path = plugin.path, type = "directory" })
  end
  return paths
end

function M.validate_ready(marker, manifest, lock, path_metadata, fingerprint)
  if not is_table(marker) or marker.schema ~= M.schema then return false, "the .ready marker schema is incompatible" end
  if fingerprint and marker.fingerprint ~= fingerprint then
    return false, "the .ready marker fingerprint is incompatible"
  end
  if marker.manifest ~= "manifest.json" or marker.lockfile ~= "lazy-lock.json" then
    return false, "the .ready marker references unexpected files"
  end
  if not is_table(manifest) or manifest.schema ~= M.schema then return false, "the manifest schema is incompatible" end
  if fingerprint and manifest.fingerprint ~= fingerprint then
    return false, "the manifest fingerprint is incompatible"
  end
  if manifest.lockfile ~= "lazy-lock.json" then return false, "the manifest references an unexpected lockfile" end
  if not is_table(manifest.lazy) or manifest.lazy.path ~= "lazy.nvim" or not is_commit(manifest.lazy.commit) then
    return false, "the lazy.nvim manifest entry is invalid"
  end
  if manifest.plugin_root ~= "data/nvim/lazy" or manifest.test_lua_dir ~= "lua" then
    return false, "the manifest contains unexpected required paths"
  end
  if not is_table(manifest.plugins) or not is_table(lock) then
    return false, "the manifest or generated lockfile is invalid"
  end

  local plugin_count = 0
  for name, plugin in pairs(manifest.plugins) do
    plugin_count = plugin_count + 1
    if type(name) ~= "string" or name == "" or not is_table(plugin) then
      return false, "the manifest contains an invalid plugin entry"
    end
    if
      not M.is_safe_relative_path(plugin.path)
      or plugin.path:sub(1, #manifest.plugin_root + 1) ~= manifest.plugin_root .. "/"
    then
      return false, "the manifest contains an unsafe plugin path for " .. name
    end
    if not is_commit(plugin.commit) then return false, "the managed plugin is missing or invalid: " .. name end
    if not is_table(lock[name]) or lock[name].commit ~= plugin.commit then
      return false, "the generated lockfile does not match " .. name
    end
  end
  if plugin_count == 0 then return false, "the manifest does not list managed plugins" end

  for _, required in ipairs(M.required_paths(manifest)) do
    if
      not M.is_safe_relative_path(required.path) or not has_expected_type(path_metadata, required.path, required.type)
    then
      return false, ("a required environment path is missing, unsafe, or has the wrong type: %s"):format(required.path)
    end
  end

  for name, entry in pairs(lock) do
    if not is_table(manifest.plugins[name]) or not is_table(entry) or not is_commit(entry.commit) then
      return false, "the generated lockfile contains an unmanaged or invalid entry: " .. tostring(name)
    end
  end

  return true, manifest
end

function M.can_adopt(plugins)
  if not is_table(plugins) then return false, "resolved plugins are unavailable" end
  local count = 0
  for name, plugin in pairs(plugins) do
    count = count + 1
    if
      type(name) ~= "string"
      or not is_table(plugin)
      or not plugin.installed
      or not plugin.no_tracked_modifications
      or not is_commit(plugin.commit)
    then
      return false, "the managed plugin is unavailable, changed, or has tracked modifications: " .. tostring(name)
    end
  end
  if count == 0 then return false, "resolved plugins are unavailable" end
  return true
end

function M.lock_error_is_retryable(lock_error)
  return lock_error == "EEXIST"
    or (
      type(lock_error) == "string"
      and (lock_error:match "^EEXIST" ~= nil or lock_error:find("already exists", 1, true) ~= nil)
    )
end

function M.with_lifecycle_lock(filesystem, lock_path, callback, options)
  options = options or {}
  local timeout_ns = options.timeout_ns or 300000000000
  local deadline = filesystem.now() + timeout_ns

  while true do
    local created, lock_error = filesystem.mkdir(lock_path)
    if created then break end
    if not M.lock_error_is_retryable(lock_error) then
      error("Failed to acquire the test environment lock: " .. tostring(lock_error), 0)
    end
    local lock_entry = filesystem.lstat and filesystem.lstat(lock_path)
    if entry_type(lock_entry) == "link" then error("Test environment lock is a symbolic link: " .. lock_path, 0) end
    if lock_entry and entry_type(lock_entry) ~= "directory" then
      error("Test environment lock is not a directory: " .. lock_path, 0)
    end
    if filesystem.now() >= deadline then error("Timed out waiting for the test environment lock: " .. lock_path, 0) end
    filesystem.wait(options.retry_delay_ms or 100)
  end

  local ok, result = xpcall(callback, debug.traceback)
  local released, release_error = filesystem.rmdir(lock_path)
  if not released then
    local message = "Failed to release the test environment lock: " .. tostring(release_error)
    if ok then error(message, 0) end
    result = result .. "\n" .. message
  end
  if not ok then error(result, 0) end
  return result
end

function M.clear_test_environment(filesystem, root, target)
  local paths = M.paths(root)
  target = target or paths.test_root
  if not M.is_clear_target(root, target) then
    error("Refusing to clear a non-canonical test environment path: " .. target, 0)
  end

  return M.with_lifecycle_lock(filesystem, paths.prepare_lock, function()
    local entry = filesystem.lstat(target)
    if not entry then return false end
    if entry_type(entry) == "link" then error("Refusing to clear symbolic-link test environment: " .. target, 0) end
    if entry_type(entry) ~= "directory" then
      error("Refusing to clear a non-directory test environment: " .. target, 0)
    end

    local removed, remove_error = M.remove_tree(filesystem, target)
    if not removed then error("Failed to clear test environment: " .. tostring(remove_error), 0) end
    return true
  end)
end

function M.remove_tree(filesystem, path)
  local function inspect_tree(current_path)
    local entry = filesystem.lstat(current_path)
    if not entry then return true, false end
    if entry_type(entry) == "link" then return true, true end
    if entry_type(entry) ~= "directory" then
      return false, "refusing to recursively remove a non-directory path: " .. current_path
    end

    local children, scan_error = filesystem.scandir(current_path)
    if not children then return false, "failed to scan " .. current_path .. ": " .. tostring(scan_error) end
    for _, name in ipairs(children) do
      local child = current_path .. "/" .. name
      local child_entry = filesystem.lstat(child)
      if not child_entry then return false, "failed to inspect " .. child end
      if entry_type(child_entry) == "directory" then
        local safe, safety_error = inspect_tree(child)
        if not safe then return false, safety_error end
      end
    end
    return true, true
  end

  local safe, exists_or_error = inspect_tree(path)
  if not safe then return false, exists_or_error end
  if not exists_or_error then return true end
  if entry_type(filesystem.lstat(path)) == "link" then
    local removed, remove_error = filesystem.unlink(path)
    if not removed then return false, "failed to remove " .. path .. ": " .. tostring(remove_error) end
    return true
  end

  local function remove_directory(current_path)
    local children, scan_error = filesystem.scandir(current_path)
    if not children then return false, "failed to scan " .. current_path .. ": " .. tostring(scan_error) end
    for _, name in ipairs(children) do
      local child = current_path .. "/" .. name
      local child_entry = filesystem.lstat(child)
      if not child_entry then return false, "failed to inspect " .. child end
      if entry_type(child_entry) == "directory" then
        local removed, remove_error = remove_directory(child)
        if not removed then return false, remove_error end
      else
        local removed, remove_error = filesystem.unlink(child)
        if not removed then return false, "failed to remove " .. child .. ": " .. tostring(remove_error) end
      end
    end
    local removed, remove_error = filesystem.rmdir(current_path)
    if not removed then return false, "failed to remove " .. current_path .. ": " .. tostring(remove_error) end
    return true
  end

  return remove_directory(path)
end

function M.validate_legacy_layout(paths, lstat)
  local function require_directory(path, label)
    local symlink = M.find_symlink_component(paths.root, path, lstat)
    if symlink then return false, "legacy " .. label .. " contains a symbolic-link path component: " .. symlink end
    if entry_type(lstat(path)) ~= "directory" then
      return false, "legacy " .. label .. " is missing or is not a directory"
    end
    return true
  end

  for _, item in ipairs {
    { paths.test_root, "test root" },
    { paths.lazy_path, "lazy.nvim" },
    { paths.plugin_root, "plugin root" },
  } do
    local valid, message = require_directory(item[1], item[2])
    if not valid then return false, message end
  end

  for _, path in ipairs { paths.lockfile, paths.manifest, paths.ready } do
    local symlink = M.find_symlink_component(paths.root, path, lstat)
    if symlink then return false, "legacy lifecycle path contains a symbolic-link component: " .. symlink end
    if lstat(path) then return false, "legacy environment contains partial lifecycle output: " .. path end
  end

  for _, path in ipairs { paths.test_lua_dir, paths.test_lua_dir .. "/luassert", paths.test_lua_dir .. "/say" } do
    local symlink = M.find_symlink_component(paths.root, path, lstat)
    if symlink then return false, "legacy adoption would mutate a symbolic-link path component: " .. symlink end
    local entry = lstat(path)
    if entry and entry_type(entry) ~= "directory" then
      return false, "legacy adoption target is not a directory: " .. path
    end
  end

  return true
end

function M.can_publish_fresh(filesystem, staging_root, test_root)
  local staging = filesystem.lstat(staging_root)
  if entry_type(staging) == "link" then return false, "fresh staging environment is a symbolic link" end
  if entry_type(staging) ~= "directory" then return false, "fresh staging environment is missing" end
  local target = filesystem.lstat(test_root)
  if target then
    if entry_type(target) == "link" then return false, "test environment target is a symbolic link" end
    return false, "test environment target already exists"
  end
  return true
end

return M
