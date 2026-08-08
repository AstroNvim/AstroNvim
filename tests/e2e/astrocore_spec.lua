local MiniTest = require "mini.test"
local config = require "config"
local helpers = require "helpers"

local child
local T = MiniTest.new_set {
  hooks = {
    pre_case = function() child = nil end,
    post_case = function()
      helpers.stop_child(child)
      child = nil
    end,
  },
}

local function start_ready_child()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")
end

T["MAP-04 forwards buffer mapping arguments through registered mappings"] = function()
  start_ready_child()

  child.lua [[
    local buffer = require "astrocore.buffer"
    local methods = { "close", "nav", "move", "close_all", "close_left", "prev", "close_right", "sort" }
    _G.astronvim_test_buffer_calls = {}

    for _, method in ipairs(methods) do
      buffer[method] = function(...)
        table.insert(_G.astronvim_test_buffer_calls, { method = method, args = { ... } })
      end
    end
  ]]

  local inputs = {
    "<Space>c",
    "<Space>C",
    "3]b",
    "2[b",
    "4>b",
    "2<lt>b",
    "<Space>bc",
    "<Space>bC",
    "<Space>bl",
    "<Space>bp",
    "<Space>br",
    "<Space>bse",
    "<Space>bsr",
    "<Space>bsp",
    "<Space>bsi",
    "<Space>bsm",
  }

  for index, input in ipairs(inputs) do
    child.type_keys(input)
    helpers.wait_until(child, "#_G.astronvim_test_buffer_calls == " .. index, "buffer mapping " .. input)
  end

  assert.same({
    { method = "close", args = {} },
    { method = "close", args = { 0, true } },
    { method = "nav", args = { 3 } },
    { method = "nav", args = { -2 } },
    { method = "move", args = { 4 } },
    { method = "move", args = { -2 } },
    { method = "close_all", args = { true } },
    { method = "close_all", args = {} },
    { method = "close_left", args = {} },
    { method = "prev", args = {} },
    { method = "close_right", args = {} },
    { method = "sort", args = { "extension" } },
    { method = "sort", args = { "unique_path" } },
    { method = "sort", args = { "full_path" } },
    { method = "sort", args = { "bufnr" } },
    { method = "sort", args = { "modified" } },
  }, child.lua_get "_G.astronvim_test_buffer_calls")
end

T["MAP-05 dispatches diagnostic float and jump mappings with counts and severities"] = function()
  start_ready_child()

  child.lua [[
    _G.astronvim_test_diagnostic_calls = {}
    vim.diagnostic.open_float = function(...)
      table.insert(_G.astronvim_test_diagnostic_calls, { method = "open_float", args = { ... } })
    end
    vim.diagnostic.jump = function(options)
      table.insert(_G.astronvim_test_diagnostic_calls, {
        method = "jump",
        count = options.count,
        severity = options.severity,
      })
    end
  ]]

  local inputs = { "<Space>ld", "gl", "2[e", "3]e", "4[w", "5]w" }
  for index, input in ipairs(inputs) do
    child.type_keys(input)
    helpers.wait_until(child, "#_G.astronvim_test_diagnostic_calls == " .. index, "diagnostic mapping " .. input)
  end

  assert.same({
    { method = "open_float", args = {} },
    { method = "open_float", args = {} },
    { method = "jump", count = -2, severity = vim.diagnostic.severity.ERROR },
    { method = "jump", count = 3, severity = vim.diagnostic.severity.ERROR },
    { method = "jump", count = -4, severity = vim.diagnostic.severity.WARN },
    { method = "jump", count = 5, severity = vim.diagnostic.severity.WARN },
  }, child.lua_get "_G.astronvim_test_diagnostic_calls")
end

T["AUTOCMD-02 keeps ordinary windows open and closes a sidebar-only secondary tab"] = function()
  start_ready_child()

  child.lua [[
    vim.cmd "enew"
    vim.bo.filetype = "text"
    vim.cmd "vsplit"
    local sidebar = vim.api.nvim_create_buf(true, false)
    vim.bo[sidebar].filetype = "neo-tree"
    vim.api.nvim_win_set_buf(0, sidebar)
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = vim.api.nvim_get_current_buf() })
  ]]
  assert.equals(1, child.lua_get "#vim.api.nvim_list_tabpages()")
  assert.equals(2, child.lua_get "#vim.api.nvim_tabpage_list_wins(0)")
  assert.is_true(child.is_running())

  child.lua [[
    local eventignore = vim.o.eventignore
    vim.o.eventignore = eventignore == "" and "BufEnter" or eventignore .. ",BufEnter"

    vim.cmd "tabnew"
    local aerial = vim.api.nvim_create_buf(true, false)
    vim.bo[aerial].filetype = "aerial"
    vim.api.nvim_win_set_buf(0, aerial)
    vim.cmd "vsplit"
    local neo_tree = vim.api.nvim_create_buf(true, false)
    vim.bo[neo_tree].filetype = "neo-tree"
    vim.api.nvim_win_set_buf(0, neo_tree)

    vim.o.eventignore = eventignore
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = neo_tree })
  ]]

  helpers.wait_until(child, "#vim.api.nvim_list_tabpages() == 1", "sidebar-only secondary tab close")
  assert.is_true(child.is_running())
end

T["AUTOCMD-02 terminates a disposable child when its final tab contains only sidebars"] = function()
  start_ready_child()

  local job = child.job
  local job_id = type(job) == "table" and job.id or job
  local _, err = pcall(
    child.lua,
    [[
    local eventignore = vim.o.eventignore
    vim.o.eventignore = eventignore == "" and "BufEnter" or eventignore .. ",BufEnter"

    local aerial = vim.api.nvim_create_buf(true, false)
    vim.bo[aerial].filetype = "aerial"
    vim.api.nvim_win_set_buf(0, aerial)
    vim.cmd "vsplit"
    local neo_tree = vim.api.nvim_create_buf(true, false)
    vim.bo[neo_tree].filetype = "neo-tree"
    vim.api.nvim_win_set_buf(0, neo_tree)

    vim.o.eventignore = eventignore
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = neo_tree })
  ]]
  )

  local exit_status = vim.fn.jobwait({ job_id }, config.wait_timeout)[1]
  assert.equals("number", type(job_id))
  assert.equals(0, exit_status, err)
end

T["AUTOCMD-03 tracks valid unique buffers across tabs deletion and terminal close"] = function()
  start_ready_child()

  child.lua [[
    local astro = require "astrocore"
    local buffer = require "astrocore.buffer"
    local redrawtabline = vim.cmd.redrawtabline

    _G.astronvim_test_buffer_events = {}
    _G.astronvim_test_redraws = 0
    astro.event = function(name) table.insert(_G.astronvim_test_buffer_events, name) end
    vim.cmd.redrawtabline = function(...)
      _G.astronvim_test_redraws = _G.astronvim_test_redraws + 1
      return redrawtabline(...)
    end

    buffer.current_buf = nil
    buffer.last_buf = nil
    vim.t.bufs = {}

    local function count(buffers, target)
      local matches = 0
      for _, bufnr in ipairs(buffers or {}) do
        if bufnr == target then matches = matches + 1 end
      end
      return matches
    end

    local first_tab = vim.api.nvim_get_current_tabpage()
    local first = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(first, "tracked-first.txt")
    vim.api.nvim_win_set_buf(0, first)

    local second = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(second, "tracked-second.txt")
    vim.api.nvim_win_set_buf(0, second)
    _G.astronvim_test_after_enter = { current = buffer.current_buf, last = buffer.last_buf }
    _G.astronvim_test_first_tab_before_delete = {
      first = count(vim.t[first_tab].bufs, first),
      second = count(vim.t[first_tab].bufs, second),
    }

    vim.cmd "tabnew"
    local second_tab = vim.api.nvim_get_current_tabpage()
    local third = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(third, "tracked-third.txt")
    vim.api.nvim_win_set_buf(0, third)
    _G.astronvim_test_second_tab_after_add = { third = count(vim.t[second_tab].bufs, third) }

    vim.api.nvim_set_current_tabpage(first_tab)
    vim.api.nvim_win_set_buf(0, second)
    _G.astronvim_test_after_tab = { current = buffer.current_buf, last = buffer.last_buf }

    local delete_events = #_G.astronvim_test_buffer_events
    local delete_redraws = _G.astronvim_test_redraws
    vim.api.nvim_buf_delete(first, { force = true })
    _G.astronvim_test_delete_delta = {
      events = #_G.astronvim_test_buffer_events - delete_events,
      redraws = _G.astronvim_test_redraws - delete_redraws,
    }

    local stale = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_delete(stale, { force = true })
    vim.t.bufs = { second, stale }
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = second })

    vim.cmd "botright new"
    vim.cmd "terminal sleep 10"
    local terminal = vim.api.nvim_get_current_buf()
    vim.g.astronvim_test_terminal_closed = false
    _G.astronvim_test_terminal_before_close = { count = count(vim.t.bufs, terminal) }
    _G.astronvim_test_terminal_event_start = #_G.astronvim_test_buffer_events
    _G.astronvim_test_terminal_redraw_start = _G.astronvim_test_redraws
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = terminal,
      once = true,
      callback = function() vim.g.astronvim_test_terminal_closed = true end,
    })
    vim.fn.jobstop(vim.b[terminal].terminal_job_id)

    _G.astronvim_test_tracking = {
      first = first,
      first_tab = first_tab,
      second = second,
      second_tab = second_tab,
      third = third,
      stale = stale,
      terminal = terminal,
    }
  ]]

  helpers.wait_until(child, "vim.g.astronvim_test_terminal_closed == true", "terminal close")

  local state = child.lua_get [[(function()
    local tracking = _G.astronvim_test_tracking
    local function contains(buffers, target)
      for _, bufnr in ipairs(buffers) do
        if bufnr == target then return true end
      end
      return false
    end
    local function count(buffers, target)
      local matches = 0
      for _, bufnr in ipairs(buffers) do
        if bufnr == target then matches = matches + 1 end
      end
      return matches
    end
    local function valid_unique(buffers)
      local seen = {}
      for _, bufnr in ipairs(buffers) do
        if seen[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then return false end
        seen[bufnr] = true
      end
      return true
    end

    local tabs = {}
    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
      local buffers = vim.deepcopy(vim.t[tabpage].bufs or {})
      table.insert(tabs, {
        tabpage = tabpage,
        buffers = buffers,
        valid_unique = valid_unique(buffers),
        has_first = contains(buffers, tracking.first),
        has_stale = contains(buffers, tracking.stale),
        has_terminal = contains(buffers, tracking.terminal),
        second_count = count(buffers, tracking.second),
        third_count = count(buffers, tracking.third),
      })
    end

    return {
      tracking = tracking,
      after_enter = _G.astronvim_test_after_enter,
      after_tab = _G.astronvim_test_after_tab,
      first_tab_before_delete = _G.astronvim_test_first_tab_before_delete,
      second_tab_after_add = _G.astronvim_test_second_tab_after_add,
      terminal_before_close = _G.astronvim_test_terminal_before_close,
      delete_delta = _G.astronvim_test_delete_delta,
      terminal_delta = {
        events = #_G.astronvim_test_buffer_events - _G.astronvim_test_terminal_event_start,
        redraws = _G.astronvim_test_redraws - _G.astronvim_test_terminal_redraw_start,
      },
      tabs = tabs,
      events = _G.astronvim_test_buffer_events,
      redraws = _G.astronvim_test_redraws,
      first_valid = vim.api.nvim_buf_is_valid(tracking.first),
      second_valid = vim.api.nvim_buf_is_valid(tracking.second),
      third_valid = vim.api.nvim_buf_is_valid(tracking.third),
    }
  end)()]]

  assert.same(state.tracking.second, state.after_enter.current)
  assert.same(state.tracking.first, state.after_enter.last)
  assert.same(state.tracking.second, state.after_tab.current)
  assert.same(state.tracking.third, state.after_tab.last)
  assert.equals(1, state.first_tab_before_delete.first)
  assert.equals(1, state.first_tab_before_delete.second)
  assert.equals(1, state.second_tab_after_add.third)
  assert.equals(1, state.terminal_before_close.count)
  assert.is_true(state.delete_delta.events >= 1)
  assert.is_true(state.delete_delta.redraws >= 1)
  assert.is_true(state.terminal_delta.events >= 1)
  assert.is_true(state.terminal_delta.redraws >= 1)
  assert.is_true(state.first_valid == false)
  assert.is_true(state.second_valid)
  assert.is_true(state.third_valid)
  assert.is_true(#state.tabs >= 2)
  assert.is_true(vim.tbl_contains(state.events, "BufsUpdated"))
  assert.is_true(state.redraws >= 2)

  local found_first_tab = false
  local found_second_tab = false
  for _, tab in ipairs(state.tabs) do
    assert.is_true(tab.valid_unique)
    assert.is_false(tab.has_first)
    assert.is_false(tab.has_stale)
    assert.is_false(tab.has_terminal)
    if tab.tabpage == state.tracking.first_tab then
      found_first_tab = true
      assert.equals(1, tab.second_count)
    end
    if tab.tabpage == state.tracking.second_tab then
      found_second_tab = true
      assert.equals(1, tab.third_count)
    end
  end
  assert.is_true(found_first_tab)
  assert.is_true(found_second_tab)
end

T["MAP-02 drives count-sensitive movement and safe file commands through mappings"] = function()
  start_ready_child()

  child.lua [[
    vim.wo.wrap = true
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      string.rep("wrapped ", 40),
      "second line",
      "third line",
      "fourth line",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  ]]
  child.type_keys "j"
  local zero_j_line = child.lua_get "vim.api.nvim_win_get_cursor(0)[1]"

  child.lua "vim.api.nvim_win_set_cursor(0, { 1, 0 })"
  child.type_keys "2j"
  local counted_j_line = child.lua_get "vim.api.nvim_win_get_cursor(0)[1]"

  child.lua "vim.api.nvim_win_set_cursor(0, { 1, 80 })"
  child.type_keys "k"
  local zero_k_line = child.lua_get "vim.api.nvim_win_get_cursor(0)[1]"

  child.lua "vim.api.nvim_win_set_cursor(0, { 4, 0 })"
  child.type_keys "2k"
  local counted_k_line = child.lua_get "vim.api.nvim_win_get_cursor(0)[1]"

  assert.equals(1, zero_j_line)
  assert.equals(3, counted_j_line)
  assert.equals(1, zero_k_line)
  assert.equals(2, counted_k_line)

  local path = helpers.fixture_project(child) .. "/mapping-commands.txt"
  child.lua(([=[
    vim.cmd "enew!"
    vim.api.nvim_buf_set_name(0, %s)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "saved by mapping" })
  ]=]):format(vim.inspect(path)))
  child.type_keys "<Space>w"
  helpers.wait_until(child, ("vim.fn.filereadable(%s) == 1"):format(vim.inspect(path)), "save mapping")

  child.lua "vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'force written by mapping' })"
  child.type_keys "<C-S>"
  helpers.wait_until(
    child,
    ("vim.fn.readfile(%s)[1] == 'force written by mapping'"):format(vim.inspect(path)),
    "force write mapping"
  )

  child.lua "vim.cmd.vsplit()"
  child.type_keys "<Space>q"
  helpers.wait_until(child, "#vim.api.nvim_list_wins() == 1", "quit window mapping")

  child.lua [[
    vim.cmd.vsplit()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "discarded by force quit" })
  ]]
  child.type_keys "<C-Q>"
  helpers.wait_until(child, "#vim.api.nvim_list_wins() == 1", "force quit window mapping")
end

T["MAP-06 navigates and resizes real split windows through mappings"] = function()
  start_ready_child()

  child.lua [[
    vim.cmd "vsplit"
    vim.cmd "wincmd h"
    vim.cmd "split"
    vim.cmd "wincmd l"
    vim.cmd "split"

    local positions = {}
    local top
    local left
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      local position = vim.api.nvim_win_get_position(winid)
      positions[winid] = position
      top = math.min(top or position[1], position[1])
      left = math.min(left or position[2], position[2])
    end
    for winid, position in pairs(positions) do
      local label = (position[1] == top and "top" or "bottom") .. (position[2] == left and "left" or "right")
      vim.api.nvim_win_set_var(winid, "astronvim_test_split_label", label)
    end
    vim.cmd "wincmd l"
    vim.cmd "wincmd j"
    vim.g.astronvim_test_split_size = {
      height = vim.api.nvim_win_get_height(0),
      width = vim.api.nvim_win_get_width(0),
    }
  ]]

  for _, case in ipairs {
    { input = "<C-h>", expected = "bottomleft" },
    { input = "<C-k>", expected = "topleft" },
    { input = "<C-l>", expected = "topright" },
    { input = "<C-j>", expected = "bottomright" },
  } do
    child.type_keys(case.input)
    helpers.wait_until(
      child,
      ("vim.w.astronvim_test_split_label == %s"):format(vim.inspect(case.expected)),
      "split navigation " .. case.input
    )
  end

  local size = child.lua_get "vim.g.astronvim_test_split_size"
  child.type_keys "<C-Up>"
  helpers.wait_until(child, ("vim.api.nvim_win_get_height(0) > %d"):format(size.height), "resize split up")
  child.type_keys "<C-Down>"
  helpers.wait_until(child, ("vim.api.nvim_win_get_height(0) == %d"):format(size.height), "resize split down")
  child.type_keys "<C-Left>"
  helpers.wait_until(child, ("vim.api.nvim_win_get_width(0) > %d"):format(size.width), "resize split left")
  child.type_keys "<C-Right>"
  helpers.wait_until(child, ("vim.api.nvim_win_get_width(0) == %d"):format(size.width), "resize split right")
end

T["MAP-07 opens lists and preserves visual selections while indenting"] = function()
  start_ready_child()

  child.lua [[
    vim.fn.setqflist { { filename = "plain.txt", lnum = 1, text = "quickfix entry" } }
  ]]
  child.type_keys "<Space>xq"
  helpers.wait_until(child, "vim.bo.buftype == 'quickfix'", "quickfix mapping")
  child.type_keys "q"
  helpers.wait_until(child, "vim.bo.buftype ~= 'quickfix'", "quickfix close mapping")

  child.lua [[
    vim.fn.setloclist(0, {}, " ", { items = { { filename = "plain.txt", lnum = 1, text = "location entry" } } })
  ]]
  child.type_keys "<Space>xl"
  helpers.wait_until(child, "vim.bo.buftype == 'quickfix'", "location list mapping")
  child.type_keys "q"
  helpers.wait_until(child, "vim.bo.buftype ~= 'quickfix'", "location list close mapping")

  child.lua [[
    vim.cmd "enew!"
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "third" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  ]]
  child.type_keys "Vj"
  child.type_keys "<Tab>"
  local indented = child.lua_get "{ mode = vim.fn.mode(), lines = vim.api.nvim_buf_get_lines(0, 0, 2, false) }"
  child.type_keys "<S-Tab>"
  local unindented = child.lua_get "{ mode = vim.fn.mode(), lines = vim.api.nvim_buf_get_lines(0, 0, 2, false) }"

  assert.same({ mode = "V", lines = { "  first", "  second" } }, indented)
  assert.same({ mode = "V", lines = { "first", "second" } }, unindented)
end

T["MAP-08 uses terminal navigation mappings in ordinary and floating terminal windows"] = function()
  start_ready_child()

  child.lua [[
    vim.cmd "vsplit"
    vim.cmd "wincmd l"
    vim.g.astronvim_test_terminal_left = vim.fn.win_getid(vim.fn.winnr "h")
    vim.cmd "terminal sleep 10"
  ]]
  child.type_keys "i"
  child.type_keys "<C-h>"
  helpers.wait_until(
    child,
    "vim.api.nvim_get_current_win() == vim.g.astronvim_test_terminal_left",
    "ordinary terminal window navigation"
  )

  child.lua [[
    local buffer = vim.api.nvim_create_buf(false, true)
    local window = vim.api.nvim_open_win(buffer, true, {
      relative = "editor",
      width = 40,
      height = 5,
      row = 1,
      col = 1,
      style = "minimal",
      zindex = 50,
    })
    vim.g.astronvim_test_floating_terminal = window
    vim.cmd "terminal sleep 10"
  ]]
  child.type_keys "i"
  child.type_keys "<C-h>"
  assert.equals(child.lua_get "vim.g.astronvim_test_floating_terminal", child.lua_get "vim.api.nvim_get_current_win()")
  assert.equals(50, child.lua_get "vim.api.nvim_win_get_config(0).zindex")
end

T["AUTOCMD-13 covers sidebar exit and buffer tracking edge boundaries"] = function()
  start_ready_child()

  child.lua [[
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = vim.api.nvim_get_current_buf() })
  ]]
  assert.equals(1, child.lua_get "#vim.api.nvim_list_tabpages()")
  assert.is_true(child.is_running())

  child.lua [[
    local astro = require "astrocore"
    local buffer = require "astrocore.buffer"
    local first_tab = vim.api.nvim_get_current_tabpage()
    local current = vim.api.nvim_get_current_buf()
    local invalid = vim.api.nvim_create_buf(false, true)
    local absent = vim.api.nvim_create_buf(true, false)

    vim.cmd "tabnew"
    local tab_without_buffers = vim.api.nvim_get_current_tabpage()
    vim.t[tab_without_buffers].bufs = nil
    vim.api.nvim_set_current_tabpage(first_tab)
    vim.t[first_tab].bufs = { current }
    buffer.current_buf = current
    buffer.last_buf = nil

    _G.astronvim_test_tracking_events = {}
    astro.event = function(name) table.insert(_G.astronvim_test_tracking_events, name) end
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = current })
    vim.api.nvim_exec_autocmds("BufAdd", { buffer = invalid })
    vim.api.nvim_exec_autocmds("BufDelete", { buffer = absent })

    _G.astronvim_test_tracking_edges = {
      current = buffer.current_buf,
      last = buffer.last_buf,
      buffers = vim.deepcopy(vim.t[first_tab].bufs),
      invalid_listed = vim.bo[invalid].buflisted,
      events = _G.astronvim_test_tracking_events,
    }
  ]]

  local state = child.lua_get "_G.astronvim_test_tracking_edges"
  local current = child.lua_get "vim.api.nvim_get_current_buf()"
  assert.same(current, state.current)
  assert.is_true(state.last == nil or state.last == vim.NIL)
  assert.same({ current }, state.buffers)
  assert.is_false(state.invalid_listed)
  assert.same({ "BufsUpdated" }, state.events)
end

T["AUTOCMD-02 closes a child with a single Aerial sidebar"] = function()
  start_ready_child()

  local job = child.job
  local job_id = type(job) == "table" and job.id or job
  local _, err = pcall(
    child.lua,
    [[
      local eventignore = vim.o.eventignore
      vim.o.eventignore = eventignore == "" and "BufEnter" or eventignore .. ",BufEnter"
      local aerial = vim.api.nvim_create_buf(true, false)
      vim.bo[aerial].filetype = "aerial"
      vim.api.nvim_win_set_buf(0, aerial)
      vim.o.eventignore = eventignore
      vim.api.nvim_exec_autocmds("BufEnter", { buffer = aerial })
    ]]
  )

  local exit_status = vim.fn.jobwait({ job_id }, config.wait_timeout)[1]
  assert.equals(0, exit_status, err)
end

T["AUTOCMD-05 creates local parent directories and skips URI write targets"] = function()
  start_ready_child()

  local path = helpers.fixture_project(child) .. "/autocmd-create-dir/fallback/file.txt"
  child.lua(([=[
    local path = %s
    local mkdir = vim.fn.mkdir
    _G.astronvim_test_mkdir_calls = {}
    vim.fn.mkdir = function(...)
      table.insert(_G.astronvim_test_mkdir_calls, { ... })
      return mkdir(...)
    end

    vim.cmd "enew!"
    vim.api.nvim_buf_set_name(0, path)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "created by autocmd" })
    vim.cmd.write()

    vim.cmd "enew!"
    vim.api.nvim_buf_set_name(0, "https://example.invalid/uri-write-target/file.txt")
    vim.api.nvim_exec_autocmds("BufWritePre", { buffer = 0 })
    vim.fn.mkdir = mkdir
  ]=]):format(vim.inspect(path)))

  local state = child.lua_get(([=[
    {
      calls = _G.astronvim_test_mkdir_calls,
      directory_exists = vim.fn.isdirectory(%s) == 1,
      file_exists = vim.fn.filereadable(%s) == 1,
      contents = vim.fn.readfile(%s),
    }
  ]=]):format(vim.inspect(vim.fs.dirname(path)), vim.inspect(path), vim.inspect(path)))
  assert.equals(1, #state.calls)
  assert.is_true(state.directory_exists)
  assert.is_true(state.file_exists)
  assert.same({ "created by autocmd" }, state.contents)
end

T["AUTOCMD-10 keeps unrelated buffers unchanged and manages q-close mappings"] = function()
  start_ready_child()

  child.lua 'vim.cmd "help help"'
  local help_mapping = child.lua_get "vim.fn.maparg('q', 'n', false, true)"
  assert.equals("<Cmd>close<CR>", help_mapping.rhs)
  child.type_keys "q"
  helpers.wait_until(child, "#vim.api.nvim_list_wins() == 1", "help close mapping")

  child.lua [[
    local target = vim.api.nvim_get_current_buf()
    vim.wo.list = true
    vim.b.autoformat = true
    vim.b.completion = true
    vim.api.nvim_exec_autocmds("User", { pattern = "AstroLargeBuf" })

    local untouched = vim.api.nvim_create_buf(true, false)
    vim.cmd "vsplit"
    vim.api.nvim_win_set_buf(0, untouched)
    vim.wo.list = true
    vim.b.autoformat = true
    vim.b.completion = true
    _G.astronvim_test_large_buffer = {
      target = target,
      untouched = {
        list = vim.wo.list,
        autoformat = vim.b.autoformat,
        completion = vim.b.completion,
      },
    }

    local nofile = vim.api.nvim_create_buf(false, true)
    vim.bo[nofile].buftype = "nofile"
    vim.keymap.set("n", "q", "<Cmd>let g:astronvim_test_q_preserved = true<CR>", { buffer = nofile })
    vim.api.nvim_win_set_buf(0, nofile)
    vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = nofile })
    _G.astronvim_test_nofile = {
      bufnr = nofile,
      mapping = vim.fn.maparg("q", "n", false, true),
    }
    vim.api.nvim_buf_delete(nofile, { force = true })

    vim.fn.setqflist { { filename = "plain.txt", lnum = 1, text = "quickfix entry" } }
    vim.cmd.copen()
    vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = vim.api.nvim_get_current_buf() })
    _G.astronvim_test_quickfix = {
      bufnr = vim.api.nvim_get_current_buf(),
      mapping = vim.fn.maparg("q", "n", false, true),
    }
  ]]

  local state = child.lua_get [[(function()
    local large = _G.astronvim_test_large_buffer
    local target_window
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winid) == large.target then
        target_window = winid
        break
      end
    end
    return {
      large = large,
      target = target_window and {
        list = vim.wo[target_window].list,
        autoformat = vim.b[large.target].autoformat,
        completion = vim.b[large.target].completion,
      },
      nofile = _G.astronvim_test_nofile,
      nofile_cache_cleared = vim.g.q_close_windows[_G.astronvim_test_nofile.bufnr] == nil,
      quickfix = _G.astronvim_test_quickfix,
    }
  end)()]]

  assert.same({ list = false, autoformat = false, completion = false }, state.target)
  assert.same({ list = true, autoformat = true, completion = true }, state.large.untouched)
  assert.equals("<Cmd>let g:astronvim_test_q_preserved = true<CR>", state.nofile.mapping.rhs)
  assert.is_true(state.nofile_cache_cleared)
  assert.equals("<Cmd>close<CR>", state.quickfix.mapping.rhs)
  assert.equals("Close window", state.quickfix.mapping.desc)
end

return T
