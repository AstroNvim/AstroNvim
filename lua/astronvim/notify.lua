---AstroNvim Notify Utilities
---
---This module implements a pausable `vim.notify` in order to defer notifications on startup as well as allow for freely pausing and resuming of notifications
---
---Based on notification lazy loading in LazyVim
---https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
---
---@class astronvim.notify
local M = {}

---@type table[]
local notifications = {}
local notification_ids = {}
local notification_positions = {}
local next_notification_id = 0
local active_notification_id
local paused = false
local resuming = false
local startup_defer

local function reindex_notifications(start)
  for position = start, #notification_ids do
    notification_positions[notification_ids[position]] = position
  end
end

local function new_notification_id()
  repeat
    next_notification_id = next_notification_id + 1
  until not notification_positions[next_notification_id] and next_notification_id ~= active_notification_id
  return next_notification_id
end

local function current_notify() return vim.notify == M.notify and M._original or vim.notify end

--- Check if notifications are paused
---@return boolean # whether or not the notifications are paused
function M.is_paused() return paused end

--- Get the pending notifications
---@return table[] # the pending notifications
function M.pending() return notifications end

--- Pause notifications
function M.pause()
  if vim.notify ~= M.notify then
    M._original, vim.notify = vim.notify, M.notify
  end
  paused = true
end

local function schedule_resume()
  if paused or resuming or #notifications == 0 then return end
  resuming = true
  vim.schedule(function()
    if paused then
      resuming = false
      return
    end
    local notify = current_notify()
    while not paused and #notifications > 0 do
      local notif = table.remove(notifications, 1)
      local id = table.remove(notification_ids, 1)
      notification_positions[id] = nil
      reindex_notifications(1)
      active_notification_id = id
      local ok, err = pcall(notify, vim.F.unpack_len(notif))
      active_notification_id = nil
      if not ok then
        if not notification_positions[id] then
          table.insert(notifications, 1, notif)
          table.insert(notification_ids, 1, id)
          reindex_notifications(1)
        end
        paused = true
        resuming = false
        error(err, 0)
      end
    end
    resuming = false
  end)
end

--- Resume paused notifications
function M.resume()
  paused = false
  schedule_resume()
end

--- A pausable `vim.notify` function
---@param message string|string[] Notification message
---@param level? string|number Log level. See vim.log.levels
---@param opts? table Notification options
function M.notify(message, level, opts)
  if not M.is_paused() and not resuming then return current_notify()(message, level, opts) end

  local id = opts and opts.replace
  if type(id) == "table" and id.id then id = id.id end
  local pos = type(id) == "number" and notification_positions[id] or nil
  if not pos then
    if type(id) ~= "number" or id ~= active_notification_id then id = new_notification_id() end
    pos = #notifications + 1
    notification_ids[pos] = id
    notification_positions[id] = pos
  end
  if opts then
    local queued_opts = {}
    for key, value in pairs(opts) do
      queued_opts[key] = value
    end
    queued_opts.replace = nil
    opts = queued_opts
  end
  notifications[pos] = vim.F.pack_len(message, level, opts)
  return { id = id }
end

--- Remove `astronvim.notify` utilities and restore original `vim.notify`
function M.restore()
  if startup_defer then startup_defer(false) end
  if vim.notify == M.notify then vim.notify = M._original end
  if M.is_paused() then M.resume() end
end

--- Pause notifications for a 500ms delay or until `vim.notify` changes
function M.defer_startup()
  -- defer initially for 500ms or until `vim.notify` changes
  local timer, checker
  local function close_handles()
    for _, handle in ipairs { timer, checker } do
      if handle then
        pcall(handle.stop, handle)
        pcall(handle.close, handle)
      end
    end
  end
  local allocated, err = pcall(function()
    timer = assert(vim.uv.new_timer(), "Unable to create startup notification timer")
    checker = assert(vim.uv.new_check(), "Unable to create startup notification checker")
  end)
  if not allocated then
    close_handles()
    error(err, 0)
  end

  local complete = false

  local function finish(resume)
    if complete then return end
    complete = true
    close_handles()
    if startup_defer == finish then startup_defer = nil end
    if resume then M.resume() end
  end

  local started, start_err = pcall(function()
    -- wait till vim.notify has been replaced
    assert(checker:start(function()
      if vim.notify ~= M.notify then finish(true) end
    end))
    -- or replay after 500ms as a fallback
    assert(timer:start(500, 0, function() finish(true) end))
  end)
  if not started then
    close_handles()
    error(start_err, 0)
  end

  M.pause()
  if startup_defer then startup_defer(false) end
  startup_defer = finish
end

return M
