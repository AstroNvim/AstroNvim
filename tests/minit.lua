#!/usr/bin/env -S nvim -l

local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"

vim.env.LAZY_OFFLINE = "1"
config.assert_ready_environment()

package.path = config.test_lua_dir .. "/?.lua;" .. config.test_lua_dir .. "/?/init.lua;" .. package.path
vim.opt.rtp:prepend(config.root)
vim.env.LAZY = config.lazy_path
vim.opt.rtp:prepend(config.lazy_path)

local lazy_minit = require "lazy.minit"
local original_minitest_run = lazy_minit.minitest.run
lazy_minit.minitest.run = function()
  local MiniTest = require "mini.test"
  local stdout_reporter = MiniTest.gen_reporter.stdout()
  local cases
  local reporter = {
    start = function(all_cases)
      cases = all_cases
      stdout_reporter.start(all_cases)
    end,
    update = stdout_reporter.update,
    finish = function()
      require("ci_results").write(cases, vim.env.ASTRONVIM_TEST_CASE_RESULTS)
      stdout_reporter.finish()
    end,
  }
  MiniTest.config.execute.reporter = reporter
  return original_minitest_run()
end

lazy_minit.setup {
  root = config.plugin_root,
  lockfile = config.lockfile,
  local_spec = false,
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  pkg = { cache = config.state_dir .. "/lazy/pkg-cache.lua" },
  rocks = { enabled = false },
  readme = { root = config.state_dir .. "/lazy/readme" },
  state = config.state_dir .. "/lazy/state.json",
  headless = { process = true, log = true, task = true, colors = false },
  performance = { cache = { enabled = false } },
}
