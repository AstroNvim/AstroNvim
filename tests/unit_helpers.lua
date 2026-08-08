local M = {}

M.remove = {}

local function restore_package_entries(entries)
  for name, entry in pairs(entries) do
    package.loaded[name] = entry.loaded
    package.preload[name] = entry.preload
  end
end

local function close_handles(handles)
  for _, handle in ipairs(handles) do
    pcall(handle.stop, handle)
    pcall(handle.close, handle)
  end
end

local function fake_handle(handles, kind)
  local handle = { closed = false, kind = kind, started = false, stopped = false }

  function handle:start(...)
    self.started = true
    self.callback = select(select("#", ...), ...)
    return 0
  end

  function handle:stop() self.stopped = true end

  function handle:close() self.closed = true end

  table.insert(handles, handle)
  return handle
end

local function fake_uv(handles)
  return {
    new_check = function() return fake_handle(handles, "check") end,
    new_timer = function() return fake_handle(handles, "timer") end,
  }
end

function M.with_module(module_name, opts, callback)
  opts = opts or {}
  callback = assert(callback, "A module callback is required")
  assert(not (opts.vim and opts.vim.notify), "Use opts.notify instead of opts.vim.notify")
  assert(not (opts.vim and opts.vim.schedule), "Scheduled callbacks are isolated automatically")

  local names = { [module_name] = true }
  for name in pairs(opts.loaded or {}) do
    names[name] = true
  end
  for name in pairs(opts.preload or {}) do
    names[name] = true
  end

  local packages = {}
  for name in pairs(names) do
    packages[name] = { loaded = package.loaded[name], preload = package.preload[name] }
  end

  local vim_fields = {}
  local replace_vim = opts.replace_vim or {}
  local function replace_vim_fields(target, replacements)
    for name, value in pairs(replacements) do
      if
        target == vim
        and name ~= "g"
        and not replace_vim[name]
        and type(value) == "table"
        and type(target[name]) == "table"
      then
        replace_vim_fields(target[name], value)
      else
        table.insert(vim_fields, { target = target, name = name, value = target[name] })
        target[name] = value
      end
    end
  end

  local original_notify = vim.notify
  local scheduled = {}
  local handles = {}
  local context = {
    handles = handles,
    scheduled_count = function() return #scheduled end,
    latest_checker = function()
      for index = #handles, 1, -1 do
        if handles[index].kind == "check" then return handles[index] end
      end
    end,
    latest_timer = function()
      for index = #handles, 1, -1 do
        if handles[index].kind == "timer" then return handles[index] end
      end
    end,
    is_closed = function(handle) return handle.closed end,
    is_stopped = function(handle) return handle.stopped end,
  }

  function context.drain_scheduled()
    while #scheduled > 0 do
      local callbacks = scheduled
      scheduled = {}
      for _, scheduled_callback in ipairs(callbacks) do
        scheduled_callback()
      end
    end
  end

  function context.fire(handle)
    if not handle or handle.closed or not handle.callback then return false end
    handle.callback()
    return true
  end

  local ok, result = xpcall(function()
    for name, value in pairs(opts.loaded or {}) do
      if value == M.remove then
        package.loaded[name] = nil
      else
        package.loaded[name] = value
      end
    end
    for name, value in pairs(opts.preload or {}) do
      if value == M.remove then
        package.preload[name] = nil
      else
        package.preload[name] = value
      end
    end
    package.loaded[module_name] = nil

    replace_vim_fields(vim, opts.vim or {})
    replace_vim_fields(vim, {
      schedule = function(scheduled_callback) table.insert(scheduled, scheduled_callback) end,
    })
    if opts.fake_uv then replace_vim_fields(vim.uv, fake_uv(handles)) end
    if opts.notify then vim.notify = opts.notify end

    return callback(require(module_name), context)
  end, debug.traceback)

  close_handles(handles)
  scheduled = {}
  vim.notify = original_notify
  for index = #vim_fields, 1, -1 do
    local entry = vim_fields[index]
    entry.target[entry.name] = entry.value
  end
  restore_package_entries(packages)

  if not ok then error(result, 0) end
  return result
end

return M
