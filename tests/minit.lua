#!/usr/bin/env -S nvim -l

local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"
package.path = config.test_lua_dir .. "/?.lua;" .. config.test_lua_dir .. "/?/init.lua;" .. package.path

config.assert_pinned_lazy_checkout()

vim.env.LAZY_OFFLINE = "1"
vim.env.LAZY = config.lazy_path
vim.opt.rtp:prepend(config.lazy_path)

require("lazy.minit").setup {
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
