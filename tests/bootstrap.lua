local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"

local function run(command, opts)
  local result = vim.system(command, vim.tbl_extend("force", { text = true }, opts or {})):wait()
  if result.code ~= 0 then
    error(("Command failed (%d): %s\n%s"):format(result.code, table.concat(command, " "), result.stderr), 0)
  end
  return result
end

local function copy_directory(source, destination)
  vim.fn.delete(destination, "rf")
  vim.fn.mkdir(vim.fs.dirname(destination), "p")
  run { "cp", "-R", source, destination }
end

local function read_bytes(path)
  local file = assert(io.open(path, "rb"))
  local contents = assert(file:read "*a")
  file:close()
  return contents
end

local function write_bytes(path, contents)
  local file = assert(io.open(path, "wb"))
  assert(file:write(contents))
  file:close()
end

local function ensure_lazy()
  if vim.uv.fs_stat(config.lazy_path) then
    config.assert_pinned_lazy_checkout()
    return
  end

  vim.fn.mkdir(config.test_root, "p")
  local temporary_path = config.test_root .. "/.lazy.nvim.bootstrap"
  vim.fn.delete(temporary_path, "rf")
  run { "git", "clone", "--filter=blob:none", "--no-checkout", "https://github.com/folke/lazy.nvim.git", temporary_path }
  run { "git", "-C", temporary_path, "fetch", "--depth=1", "origin", config.lazy_commit }
  run { "git", "-C", temporary_path, "checkout", "--detach", config.lazy_commit }
  if vim.fn.rename(temporary_path, config.lazy_path) ~= 0 then
    error(("Failed to install lazy.nvim at %s"):format(config.lazy_path), 0)
  end
  if not vim.uv.fs_stat(config.lazy_path) then
    error(("lazy.nvim installation is missing: %s"):format(config.lazy_path), 0)
  end
  config.assert_pinned_lazy_checkout()
end

local update = vim.tbl_contains(vim.v.argv, "--update")
if not update and not vim.uv.fs_stat(config.lockfile) then
  error(("Missing committed dependency lockfile: %s"):format(config.lockfile), 0)
end

local original_lockfile = update and nil or read_bytes(config.lockfile)
local original_lock = original_lockfile and vim.json.decode(original_lockfile) or nil
local working_lockfile = original_lockfile and vim.fn.tempname() or nil
if working_lockfile then write_bytes(working_lockfile, original_lockfile) end

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

local function assert_locked_plugins(lock)
  local plugins = require("lazy.core.config").plugins
  local failures = {}

  for name, entry in pairs(lock) do
    local plugin = plugins[name]
    if not plugin then
      table.insert(failures, name .. " is missing from the managed plugin specification")
    elseif not plugin._.installed then
      table.insert(failures, name .. " is not installed")
    else
      local result = run { "git", "-C", plugin.dir, "rev-parse", "HEAD" }
      if vim.trim(result.stdout) ~= entry.commit then
        table.insert(failures, ("%s is at %s, expected %s"):format(name, vim.trim(result.stdout), entry.commit))
      end
    end
  end

  for name, plugin in pairs(plugins) do
    if plugin.url and not plugin._.is_local and not lock[name] then
      table.insert(failures, name .. " is managed without a lock entry")
    end
  end

  table.sort(failures)
  if #failures > 0 then error("Locked plugin verification failed: " .. table.concat(failures, "; "), 0) end
end

ensure_lazy()
for _, path in ipairs { config.shared_data_dir, config.state_dir, config.cache_dir, config.test_lua_dir } do
  vim.fn.mkdir(path, "p")
end
vim.o.loadplugins = true
vim.env.LAZY = config.lazy_path
vim.opt.rtp:prepend(config.lazy_path)

local ok, err = xpcall(function()
  require("lazy").setup {
    root = config.plugin_root,
    lockfile = working_lockfile or config.lockfile,
    local_spec = false,
    spec = {
      {
        dir = config.root,
        name = "AstroNvim",
        lazy = false,
        priority = 10000,
        opts = { icons_enabled = false, pin_plugins = false, update_notification = false },
      },
      { import = "astronvim.plugins" },
      { "echasnovski/mini.test" },
      { "lunarmodules/luassert" },
      { "Olivine-Labs/say" },
    },
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    pkg = { cache = config.state_dir .. "/lazy/pkg-cache.lua" },
    rocks = { enabled = false },
    readme = { root = config.state_dir .. "/lazy/readme" },
    state = config.state_dir .. "/lazy/state.json",
    headless = { process = true, log = true, task = true, colors = false },
    git = { cooldown = 0 },
    performance = { cache = { enabled = false } },
  }

  local lazy = require "lazy"
  if update then
    lazy.sync { wait = true, show = false }
    assert_lazy_task_success "sync"
  else
    lazy.restore { wait = true, show = false, lockfile = true }
    assert_lazy_task_success "restore"
    write_bytes(working_lockfile, original_lockfile)
    lazy.install { wait = true, show = false, lockfile = true }
    assert_lazy_task_success "install"
    assert_locked_plugins(original_lock)
  end
end, debug.traceback)

local cleanup_error
if working_lockfile then
  vim.fn.delete(working_lockfile)
  if vim.uv.fs_stat(working_lockfile) then cleanup_error = "Failed to delete temporary dependency lockfile" end
end
if original_lockfile and read_bytes(config.lockfile) ~= original_lockfile then
  cleanup_error = (cleanup_error and cleanup_error .. "\n" or "")
    .. "Normal dependency preparation changed tests/lazy-lock.json"
end

if not ok then
  if cleanup_error then error(err .. "\n" .. cleanup_error, 0) end
  error(err, 0)
end
if cleanup_error then error(cleanup_error, 0) end

copy_directory(config.plugin_root .. "/luassert/src", config.test_lua_dir .. "/luassert")
copy_directory(config.plugin_root .. "/say/src/say", config.test_lua_dir .. "/say")
