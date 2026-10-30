local function required_env(name)
  local value = vim.env[name]
  if not value or value == "" then error(("Missing %s"):format(name), 0) end
  return value
end

local root = required_env "ASTRONVIM_TEST_ROOT"
local lazy_path = required_env "ASTRONVIM_TEST_LAZY_PATH"
local plugin_root = required_env "ASTRONVIM_TEST_PLUGIN_ROOT"
local lockfile = required_env "ASTRONVIM_TEST_LOCKFILE"

local events = { lazy_done = false, vim_enter = false }
vim.g.astronvim_test_ready = false
vim.g.astronvim_test_error_notifications = {}
vim.g.astronvim_test_error_notifications_before_ready = {}

local captured_notify
local function capture_error_notifications()
  if vim.notify == captured_notify then return end
  local notify = vim.notify
  vim.notify = function(message, level, opts)
    if (level or vim.log.levels.INFO) >= vim.log.levels.ERROR then
      local notifications = vim.g.astronvim_test_error_notifications
      table.insert(notifications, vim.inspect(message))
      vim.g.astronvim_test_error_notifications = notifications
    end
    return notify(message, level, opts)
  end
  captured_notify = vim.notify
end
capture_error_notifications()

local function set_ready()
  if events.lazy_done and events.vim_enter then
    require("astronvim.notify").restore()
    vim.schedule(function()
      vim.schedule(function()
        vim.g.astronvim_test_error_notifications_before_ready = vim.deepcopy(vim.g.astronvim_test_error_notifications)
        vim.g.astronvim_test_ready = true
      end)
    end)
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    events.vim_enter = true
    set_ready()
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    if vim.notify ~= require("astronvim.notify").notify then capture_error_notifications() end
    events.lazy_done = true
    set_ready()
  end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.env.LAZY = lazy_path
vim.opt.rtp:prepend(lazy_path)

require("lazy").setup {
  root = plugin_root,
  lockfile = lockfile,
  local_spec = false,
  spec = {
    {
      dir = root,
      name = "AstroNvim",
      lazy = false,
      priority = 10000,
      opts = { icons_enabled = false, pin_plugins = false, update_notification = false },
    },
    { import = "astronvim.plugins" },
  },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
  headless = { process = true, log = true, task = true, colors = false },
  performance = { cache = { enabled = false } },
}

vim.o.background = "dark"
vim.o.termguicolors = true
vim.cmd.colorscheme "astrotheme"

local startup_error = vim.env.ASTRONVIM_TEST_STARTUP_ERROR
local astronvim_notify = require "astronvim.notify"
if vim.notify ~= astronvim_notify.notify then capture_error_notifications() end
if startup_error and startup_error ~= "" then astronvim_notify.notify(startup_error, vim.log.levels.ERROR) end
