local MiniTest = require "mini.test"
local config = require "config"

local M = {}
local cases = setmetatable({}, { __mode = "k" })
local xdg_variables = { "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME", "XDG_RUNTIME_DIR" }
local deterministic_environment = {
  LC_ALL = "C",
  LANG = "C",
  TZ = "UTC",
  TERM = "xterm-256color",
  COLORTERM = "truecolor",
}

local function create_directory(path)
  if vim.fn.mkdir(path, "p", 448) ~= 0 or vim.fn.isdirectory(path) == 1 then return end
  error("Failed to create test fixture directory: " .. path, 0)
end

local function copy_directory(source, destination)
  local scanner, scan_error = vim.uv.fs_scandir(source)
  if not scanner then error(("Failed to copy fixture project: %s"):format(scan_error), 0) end

  while true do
    local name, entry_type = vim.uv.fs_scandir_next(scanner)
    if not name then break end
    local source_path = vim.fs.joinpath(source, name)
    local destination_path = vim.fs.joinpath(destination, name)
    if entry_type == "directory" then
      create_directory(destination_path)
      copy_directory(source_path, destination_path)
    else
      local copied, copy_error = vim.uv.fs_copyfile(source_path, destination_path)
      if not copied then error(("Failed to copy fixture project: %s"):format(copy_error), 0) end
    end
  end
end

local function run(command, message, environment)
  local result = vim.system(command, { text = true, env = environment }):wait()
  if result.code ~= 0 then error(("%s: %s"):format(message, result.stderr), 0) end
end

local function fixture_git_environment(case)
  return vim.tbl_extend("force", vim.deepcopy(deterministic_environment), {
    GIT_CONFIG_NOSYSTEM = "1",
    GIT_CONFIG_GLOBAL = case.git_global,
    GIT_CONFIG_COUNT = "1",
    GIT_CONFIG_KEY_0 = "core.hooksPath",
    GIT_CONFIG_VALUE_0 = case.git_hooks,
    GIT_TEMPLATE_DIR = case.git_template,
    GIT_AUTHOR_NAME = "AstroNvim Test",
    GIT_AUTHOR_EMAIL = "test@astronvim.local",
    GIT_COMMITTER_NAME = "AstroNvim Test",
    GIT_COMMITTER_EMAIL = "test@astronvim.local",
    GIT_AUTHOR_DATE = "2000-01-01T00:00:00+00:00",
    GIT_COMMITTER_DATE = "2000-01-01T00:00:00+00:00",
  })
end

local function initialize_fixture_repository(case)
  local path = case.project
  local environment = fixture_git_environment(case)
  run(
    { "git", "init", "--template=" .. case.git_template, "--initial-branch=main", path },
    "Failed to initialize fixture Git repository",
    environment
  )
  run(
    { "git", "-C", path, "config", "user.name", "AstroNvim Test" },
    "Failed to configure fixture Git author name",
    environment
  )
  run(
    { "git", "-C", path, "config", "user.email", "test@astronvim.local" },
    "Failed to configure fixture Git author email",
    environment
  )
  run(
    { "git", "-C", path, "config", "core.hooksPath", case.git_hooks },
    "Failed to disable fixture Git hooks",
    environment
  )
  run(
    { "git", "-C", path, "config", "commit.gpgsign", "false" },
    "Failed to disable fixture commit signing",
    environment
  )
  run({ "git", "-C", path, "config", "tag.gpgSign", "false" }, "Failed to disable fixture tag signing", environment)
  run({ "git", "-C", path, "add", "--force", "--all" }, "Failed to stage fixture files", environment)
  run(
    { "git", "-C", path, "commit", "--no-gpg-sign", "-m", "Initialize test fixture" },
    "Failed to commit fixture files",
    environment
  )
end

local function delete_fixture_root(root)
  if vim.fn.delete(root, "rf") == 0 then return end
  return "Failed to delete test fixture root: " .. root
end

local function cleanup_error_message(err) return type(err) == "string" and err or vim.inspect(err) end

local function make_case()
  local temporary_directory = vim.uv.os_tmpdir() or vim.fn.stdpath "cache"
  local root = assert(vim.uv.fs_mkdtemp(vim.fs.joinpath(temporary_directory, "a.XXXXXX")))
  local paths = {
    root = root,
    config = root .. "/config",
    data = root .. "/data",
    state = root .. "/state",
    cache = root .. "/cache",
    runtime = root .. "/runtime",
    project = root .. "/project",
    git_global = root .. "/gitconfig",
    git_template = root .. "/git-template",
    git_hooks = root .. "/git-hooks",
  }

  local ok, err = xpcall(function()
    for _, path in ipairs {
      paths.config,
      paths.data,
      paths.state,
      paths.cache,
      paths.runtime,
      paths.project,
      paths.git_template,
      paths.git_hooks,
    } do
      create_directory(path)
    end
    if vim.fn.writefile({}, paths.git_global) ~= 0 then
      error("Failed to create test fixture Git configuration: " .. paths.git_global, 0)
    end
    for _, path in ipairs { paths.data .. "/nvim", paths.state .. "/nvim", paths.cache .. "/nvim" } do
      create_directory(path)
    end
    copy_directory(config.fixture_project, paths.project)
    initialize_fixture_repository(paths)
  end, debug.traceback)
  if not ok then
    local cleanup_error = delete_fixture_root(root)
    if cleanup_error then err = err .. "\n" .. cleanup_error end
    error(err, 0)
  end
  return paths
end

local function with_child_environment(case, child_environment, callback)
  local environment = vim.tbl_extend("force", {
    XDG_CONFIG_HOME = case.config,
    XDG_DATA_HOME = case.data,
    XDG_STATE_HOME = case.state,
    XDG_CACHE_HOME = case.cache,
    XDG_RUNTIME_DIR = case.runtime,
    ASTRONVIM_TEST_ROOT = config.root,
    ASTRONVIM_TEST_LAZY_PATH = config.lazy_path,
    ASTRONVIM_TEST_PLUGIN_ROOT = config.plugin_root,
    ASTRONVIM_TEST_LOCKFILE = config.lockfile,
  }, child_environment or {}, deterministic_environment, fixture_git_environment(case))
  local previous = {}

  for name, value in pairs(environment) do
    previous[name] = { value = vim.uv.os_getenv(name) }
    vim.env[name] = value
  end

  local ok, result = xpcall(callback, debug.traceback)
  for name, environment_value in pairs(previous) do
    vim.env[name] = environment_value.value
  end
  if not ok then error(result, 0) end
  return result
end

local function child_job_id(child)
  local job = child and child.job
  return job and (type(job) == "table" and job.id or job) or nil
end

local function job_is_alive(job_id) return type(job_id) == "number" and vim.fn.jobwait({ job_id }, 0)[1] == -1 end

local function parent_job_channels()
  local channels = {}
  for _, channel in ipairs(vim.api.nvim_list_chans()) do
    if job_is_alive(channel.id) then channels[channel.id] = true end
  end
  return channels
end

local function is_fixture_invocation(channel)
  for _, argument in ipairs(channel.argv or {}) do
    if argument == config.fixture_init then return true end
  end
  return false
end

local function stop_jobs(job_ids)
  for _, job_id in ipairs(job_ids) do
    if job_is_alive(job_id) then pcall(vim.fn.jobstop, job_id) end
  end
  for _, job_id in ipairs(job_ids) do
    if job_is_alive(job_id) then pcall(vim.fn.jobwait, { job_id }, 1000) end
  end

  local survivors = {}
  for _, job_id in ipairs(job_ids) do
    if job_is_alive(job_id) then table.insert(survivors, tostring(job_id)) end
  end
  return survivors
end

local function cleanup_failed_start(child, case, existing_channels)
  local job_ids = {}
  local child_job = child_job_id(child)
  if child_job then job_ids[child_job] = true end
  for _, channel in ipairs(vim.api.nvim_list_chans()) do
    if not existing_channels[channel.id] and is_fixture_invocation(channel) then job_ids[channel.id] = true end
  end

  local cleanup_errors = {}
  local running, is_running = pcall(child.is_running)
  if running and is_running then
    local stopped, stop_err = pcall(child.stop)
    if not stopped then table.insert(cleanup_errors, cleanup_error_message(stop_err)) end
  end

  local jobs = vim.tbl_keys(job_ids)
  table.sort(jobs)
  local survivors = stop_jobs(jobs)
  if #survivors > 0 then
    table.insert(cleanup_errors, "Child Neovim processes survived shutdown: " .. table.concat(survivors, ", "))
  end

  cases[child] = nil
  local root_cleanup_error = delete_fixture_root(case.root)
  if root_cleanup_error then table.insert(cleanup_errors, root_cleanup_error) end
  return table.concat(cleanup_errors, "\n")
end

function M.start_child(child_environment)
  local case = make_case()
  local child
  local existing_channels
  local ok, err = xpcall(function()
    existing_channels = parent_job_channels()
    child = MiniTest.new_child_neovim()
    cases[child] = case
    with_child_environment(
      case,
      child_environment,
      function()
        child.start {
          "--cmd",
          "set lines=" .. config.child_height .. " columns=" .. config.child_width,
          "--cmd",
          "cd " .. vim.fn.fnameescape(case.project),
          "-u",
          config.fixture_init,
        }
      end
    )
  end, debug.traceback)

  if not ok then
    local cleanup_error
    if child then
      cleanup_error = cleanup_failed_start(child, case, existing_channels or {})
    else
      cleanup_error = delete_fixture_root(case.root) or ""
    end
    if cleanup_error ~= "" then error(err .. "\nFailed child cleanup: " .. cleanup_error, 0) end
    error(err, 0)
  end

  return child
end

function M.wait_until(child, expression, description, timeout)
  local ready = vim.wait(timeout or config.wait_timeout, function()
    local ok, value = pcall(child.lua_get, expression)
    return ok and value == true
  end, 20)
  assert(ready, ("Timed out waiting for %s"):format(description))
end

function M.stop_child(child)
  if not child then return end

  local case = cases[child]
  local job_id = child_job_id(child)
  local cleanup_errors = {}
  local running_ok, running = pcall(child.is_running)
  if running_ok and running then
    local stopped, stop_error = pcall(child.stop)
    if not stopped then table.insert(cleanup_errors, cleanup_error_message(stop_error)) end
  end

  if job_is_alive(job_id) then
    pcall(vim.fn.jobstop, job_id)
    vim.fn.jobwait({ job_id }, 1000)
  end

  if job_is_alive(job_id) then table.insert(cleanup_errors, "Child Neovim process survived shutdown") end
  cases[child] = nil
  if case then
    local root_cleanup_error = delete_fixture_root(case.root)
    if root_cleanup_error then table.insert(cleanup_errors, root_cleanup_error) end
  end
  if #cleanup_errors > 0 then error(table.concat(cleanup_errors, "\n"), 0) end
end

function M.fixture_project(child)
  local case = assert(cases[child], "Child fixture is unavailable")
  return case.project
end

local function golden_update_enabled() return vim.env.ASTRONVIM_TEST_UPDATE_GOLDENS == "1" end

local function assert_golden_path(path, kind)
  if vim.fn.filereadable(path) == 0 and not golden_update_enabled() then
    error(("Missing %s golden: %s. Set ASTRONVIM_TEST_UPDATE_GOLDENS=1 to create it."):format(kind, path), 0)
  end
end

function M.normalize_fixture_root(screenshot, fixture_root)
  local fixture_basename = vim.fs.basename(vim.fs.normalize(fixture_root))
  assert(fixture_basename ~= "", "Fixture root must have a basename")
  local rendered_fixture_root = "[O] " .. vim.fs.normalize(fixture_root)
  assert(
    rendered_fixture_root:sub(-#fixture_basename) == fixture_basename,
    "Rendered fixture root must end with its basename"
  )
  local replacement = "[O] <fixture-root>"
  local replacements = 0

  for row, cells in ipairs(screenshot.text) do
    local line = table.concat(cells)
    local divider = line:find("│", 1, true)
    local start_index = line:find(rendered_fixture_root, 1, true)
    if divider and start_index then
      assert(
        not line:find(rendered_fixture_root, start_index + #rendered_fixture_root, true),
        "Fixture root rendered twice in one row"
      )
      line = line:sub(1, start_index - 1)
        .. replacement
        .. string.rep(" ", divider - 1 - (start_index - 1) - #replacement)
        .. line:sub(divider)
      screenshot.text[row] = vim.fn.split(line, "\\zs")
      replacements = replacements + 1
    end
  end
  assert.equals(1, replacements)
  return screenshot
end

function M.assert_visual_baseline(child)
  local actual = child.lua_get [[(function()
    local version = vim.version()
    return {
      version = ("%d.%d.%d"):format(version.major, version.minor, version.patch),
      background = vim.o.background,
      colorscheme = vim.g.colors_name,
      astrotheme_loaded = package.loaded.astrotheme ~= nil,
      termguicolors = vim.o.termguicolors,
    }
  end)()]]

  assert.equals(config.golden_nvim_version, actual.version)
  assert.equals("dark", actual.background)
  assert.equals("astrodark", actual.colorscheme)
  assert.is_true(actual.astrotheme_loaded)
  assert.is_true(actual.termguicolors)
end

function M.expect_screen(child, name, normalizer)
  M.assert_visual_baseline(child)
  local path = config.screenshots_dir .. "/" .. name
  assert_golden_path(path, "screen")
  local screenshot = child.get_screenshot()
  if normalizer then screenshot = normalizer(screenshot) end
  MiniTest.expect.reference_screenshot(screenshot, path, { force = golden_update_enabled() })
end

function M.expect_text_golden(path, contents)
  assert_golden_path(path, "text")
  if golden_update_enabled() then
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    local file = assert(io.open(path, "wb"))
    assert(file:write(contents))
    file:close()
    return
  end

  local file = assert(io.open(path, "rb"))
  local expected = assert(file:read "*a")
  file:close()
  assert.equals(expected, contents)
end

local highlight_fields = {
  "fg",
  "bg",
  "sp",
  "bold",
  "italic",
  "underline",
  "undercurl",
  "underdouble",
  "underdotted",
  "underdashed",
  "strikethrough",
  "reverse",
  "nocombine",
}
local color_fields = { fg = true, bg = true, sp = true }

function M.normalize_highlights(highlights, groups)
  local lines = {}
  for _, group in ipairs(groups) do
    local highlight = highlights[group]
    if not highlight then error(("Missing highlight group: %s"):format(group), 0) end
    local values = {}
    for _, field in ipairs(highlight_fields) do
      local value = highlight[field]
      if value ~= nil then
        if color_fields[field] then value = string.format("#%06x", value) end
        table.insert(values, ("%s = %s"):format(field, vim.inspect(value)))
      end
    end
    if #values == 0 then error(("Highlight group has no stable fields: %s"):format(group), 0) end
    table.insert(lines, ("%s = { %s }"):format(group, table.concat(values, ", ")))
  end
  return table.concat(lines, "\n") .. "\n"
end

function M.expect_highlight_golden(child, path, highlights, groups)
  M.assert_visual_baseline(child)
  M.expect_text_golden(path, M.normalize_highlights(highlights, groups))
end

function M.parent_xdg_environment()
  local environment = {}
  for _, name in ipairs(xdg_variables) do
    environment[name] = { value = vim.uv.os_getenv(name) }
  end
  return environment
end

function M.restore_parent_xdg_environment(environment)
  for name, snapshot in pairs(environment) do
    vim.env[name] = snapshot.value
  end
end

return M
