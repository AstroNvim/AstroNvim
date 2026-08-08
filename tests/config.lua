local M = {}

M.root = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))), ":p")
M.tests_dir = M.root .. "/tests"
M.test_root = M.root .. "/.tests"
M.shared_data_dir = M.test_root .. "/data/nvim"
M.state_dir = M.test_root .. "/state"
M.cache_dir = M.test_root .. "/cache"
M.test_lua_dir = M.test_root .. "/lua"
M.plugin_root = M.shared_data_dir .. "/lazy"
M.lazy_path = M.test_root .. "/lazy.nvim"
M.lockfile = M.tests_dir .. "/lazy-lock.json"
M.fixture_init = M.tests_dir .. "/fixtures/init.lua"
M.fixture_project = M.tests_dir .. "/fixtures/project"
M.screenshots_dir = M.tests_dir .. "/screenshots"
M.highlights_dir = M.tests_dir .. "/highlights"
M.lazy_commit = "306a05526ada86a7b30af95c5cc81ffba93fef97"
M.golden_nvim_version = "0.12.4"
M.child_width = 100
M.child_height = 30
M.wait_timeout = 15000

function M.assert_pinned_lazy_checkout()
  if not vim.uv.fs_stat(M.lazy_path) then
    error(("Missing pinned lazy.nvim checkout. Run `make test-prepare`: %s"):format(M.lazy_path), 0)
  end

  local head = vim.system({ "git", "-C", M.lazy_path, "rev-parse", "HEAD" }, { text = true }):wait()
  if head.code ~= 0 or vim.trim(head.stdout) ~= M.lazy_commit then
    error(("lazy.nvim must be checked out at %s"):format(M.lazy_commit), 0)
  end

  local status = vim.system({ "git", "-C", M.lazy_path, "status", "--porcelain" }, { text = true }):wait()
  if status.code ~= 0 or status.stdout ~= "" then error("lazy.nvim checkout must have a clean worktree", 0) end
end

return M
