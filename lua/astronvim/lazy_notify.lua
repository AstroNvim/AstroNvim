local M = {}
-- Based on notification lazy loading in LazyVim
-- https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125

local notifications = {}
M.original = vim.notify
M.queue = function(...) table.insert(notifications, vim.F.pack_len(...)) end

function M.setup()
  vim.notify = M.queue

  local uv = vim.uv or vim.loop
  local timer, checker = uv.new_timer(), assert(uv.new_check())

  local replay = function()
    timer:stop()
    checker:stop()
    if vim.notify == M.queue then vim.notify = M.original end
    vim.schedule(function()
      for _, notification in ipairs(notifications) do
        vim.notify(vim.F.unpack_len(notification))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  checker:start(function()
    if vim.notify ~= M.queue then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

return M
