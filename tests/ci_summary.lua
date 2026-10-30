local function read_file(path)
  if not path or path == "" then return nil end
  local file = io.open(path, "rb")
  if not file then return nil end
  local contents = file:read "*a"
  file:close()
  return contents
end

local function write_file(path, contents)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local file = assert(io.open(path, "wb"))
  assert(file:write(contents))
  file:close()
end

local function read_json(path)
  local contents = read_file(path)
  if not contents then return nil end
  local ok, value = pcall(vim.json.decode, contents)
  return ok and value or nil
end

local function copy_file(source, destination)
  local contents = read_file(source)
  if contents then write_file(destination, contents) end
end

local function environment(name, fallback)
  local value = vim.env[name]
  return value and value ~= "" and value or fallback
end

local function runtime_identity()
  local version = vim.version()
  local identity = ("%d.%d.%d"):format(version.major, version.minor, version.patch)
  if version.prerelease then identity = identity .. "-" .. version.prerelease end
  if version.build then identity = identity .. "-" .. version.build end
  return identity
end

local function parse_number(contents, pattern) return tonumber(contents and contents:match(pattern) or "") end

local function strip_ansi(value) return value:gsub("\27%[[0-9;]*m", "") end

local function failure_lines(contents)
  local failures = {}
  for line in (contents or ""):gmatch("[^" .. string.char(10) .. "]+") do
    line = strip_ansi(line)
    if line:find("FAIL in ", 1, true) then table.insert(failures, line) end
  end
  return failures
end

local summary_dir = environment("ASTRONVIM_TEST_SUMMARY_DIR", ".ci-test-summary")
local output_path = environment("ASTRONVIM_TEST_OUTPUT", summary_dir .. "/test-output.log")
local manifest_path = ".tests/manifest.json"
local lockfile_path = ".tests/lazy-lock.json"
local output = read_file(output_path) or ""
local clean_output = strip_ansi(output)
local manifest = read_json(manifest_path) or {}
local lock = read_json(lockfile_path) or {}
local case_results_path = environment("ASTRONVIM_TEST_CASE_RESULTS", "")
local case_results = read_json(case_results_path)
local case_results_complete = vim.islist(case_results)
if not case_results_complete then case_results = {} end
local status_code = tonumber(read_file(environment("ASTRONVIM_TEST_STATUS_FILE", "")) or "")
local cases = parse_number(clean_output, "Total number of cases:%s*(%d+)")
local failed = parse_number(clean_output, "Fails%s*%((%d+)%)")
local notes = parse_number(clean_output, "Notes%s*%((%d+)%)")

local plugins = {}
for name, plugin in pairs(manifest.plugins or {}) do
  local lock_entry = lock[name] or {}
  table.insert(plugins, {
    name = name,
    commit = plugin.commit,
    branch = lock_entry.branch,
    version = lock_entry.version,
  })
end
table.sort(plugins, function(left, right) return left.name < right.name end)

local summary = {
  schema = 1,
  status = status_code == 0 and "passed" or "failed",
  exit_code = status_code,
  suite = environment("ASTRONVIM_TEST_SUITE", "unknown"),
  requested_neovim = environment("ASTRONVIM_TEST_REQUESTED_NEOVIM", "unknown"),
  actual_neovim = runtime_identity(),
  platform = environment("ASTRONVIM_TEST_PLATFORM", vim.uv.os_uname().sysname),
  architecture = environment("ASTRONVIM_TEST_ARCHITECTURE", "unknown"),
  shell = environment("ASTRONVIM_TEST_SHELL", "unknown"),
  repository_commit = environment("GITHUB_SHA", "local"),
  lazy = manifest.lazy or {},
  counts = {
    cases = cases,
    failed = failed,
    passed = cases and failed and cases - failed or nil,
    notes = notes,
    recorded_cases = #case_results,
    case_results_complete = case_results_complete,
    case_count_matches = case_results_complete and cases ~= nil and #case_results == cases,
  },
  plugins = plugins,
  case_results = case_results,
  failures = failure_lines(clean_output),
  artifacts = {
    output = output_path,
    manifest = summary_dir .. "/manifest.json",
    lockfile = summary_dir .. "/lazy-lock.json",
    cases = summary_dir .. "/cases.json",
  },
}

copy_file(manifest_path, summary.artifacts.manifest)
copy_file(lockfile_path, summary.artifacts.lockfile)
copy_file(environment("ASTRONVIM_TEST_CASE_RESULTS", ""), summary.artifacts.cases)
write_file(summary_dir .. "/summary.json", vim.json.encode(summary) .. "\n")

local case_result_status = "not recorded"
if summary.counts.case_results_complete then
  if summary.counts.case_count_matches then
    case_result_status = "complete"
  else
    case_result_status = "count mismatch (" .. tostring(summary.counts.recorded_cases) .. " recorded)"
  end
end

local markdown = {
  "# AstroNvim test summary",
  "",
  "- Status: " .. summary.status,
  "- Suite: " .. summary.suite,
  "- Platform: " .. summary.platform .. " (" .. summary.architecture .. ")",
  "- Shell: " .. summary.shell,
  "- Requested Neovim: " .. summary.requested_neovim,
  "- Actual Neovim: " .. summary.actual_neovim,
  "- Repository commit: " .. summary.repository_commit,
  "- Cases: " .. tostring(cases or "unknown") .. " total, " .. tostring(failed or "unknown") .. " failed",
  "- Case results: " .. case_result_status,
  "- Plugins: " .. tostring(#plugins),
  "",
  "## Plugin revisions",
  "",
  "| Plugin | Commit | Branch | Version |",
  "| --- | --- | --- | --- |",
}
for _, plugin in ipairs(plugins) do
  table.insert(
    markdown,
    ("| `%s` | `%s` | `%s` | `%s` |"):format(
      plugin.name,
      plugin.commit or "",
      plugin.branch or "",
      plugin.version or ""
    )
  )
end
if #case_results > 0 then
  table.insert(markdown, "")
  table.insert(markdown, "## Case results")
  table.insert(markdown, "")
  for _, result in ipairs(case_results) do
    table.insert(markdown, ("- `%s`: %s"):format(result.id, result.status))
  end
end
if #summary.failures > 0 then
  table.insert(markdown, "")
  table.insert(markdown, "## Failure locations")
  table.insert(markdown, "")
  for _, failure in ipairs(summary.failures) do
    table.insert(markdown, "- " .. failure)
  end
end
write_file(summary_dir .. "/summary.md", table.concat(markdown, "\n") .. "\n")

local step_summary = vim.env.GITHUB_STEP_SUMMARY
if step_summary and step_summary ~= "" then
  local file = assert(io.open(step_summary, "ab"))
  assert(file:write(table.concat(markdown, "\n"), "\n"))
  file:close()
end
