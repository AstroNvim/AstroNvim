local MiniTest = require "mini.test"
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

T["GIT-04 loads Gitsigns from AstroGitFile without changing editor state"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    local buffer = vim.api.nvim_get_current_buf()
    local windows = #vim.api.nvim_list_wins()
    vim.api.nvim_exec_autocmds("User", { pattern = "AstroGitFile", modeline = false })
    local loaded = vim.wait(3000, function() return package.loaded.gitsigns ~= nil end, 20)
    return {
      loaded = loaded,
      buffer = buffer,
      current_buffer = vim.api.nvim_get_current_buf(),
      buffer_valid = vim.api.nvim_buf_is_valid(buffer),
      windows = windows,
      current_windows = #vim.api.nvim_list_wins(),
    }
  end)()]]

  assert.is_true(state.loaded)
  assert.is_true(state.buffer_valid)
  assert.equals(state.buffer, state.current_buffer)
  assert.equals(state.windows, state.current_windows)
end

T["SESSION-04 hands the AstroNvim session mapping to Resession without persistence"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    local mapping = vim.fn.maparg("<Leader>Sl", "n", false, true)
    local calls = {}
    package.loaded.resession = {
      load = function(name) table.insert(calls, name) end,
    }
    assert(type(mapping.callback) == "function")
    mapping.callback()
    return { desc = mapping.desc, calls = calls }
  end)()]]

  assert.equals("Load last session", state.desc)
  assert.same({ "Last Session" }, state.calls)
end

T["TERM-04 applies terminal-local options and hidden-terminal mappings"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    local spec = require "astronvim.plugins.toggleterm"
    local on_create = spec.opts.on_create
    local calls = {}
    local function local_mappings(bufnr, mode)
      local mappings = {}
      for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
        if mapping.lhs == "<F7>" or mapping.lhs == "<C-'>" then
          mappings[mapping.lhs] = { callback = mapping.callback ~= nil, desc = mapping.desc }
        end
      end
      return mappings
    end
    local function create_terminal(hidden)
      local bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(bufnr)
      on_create {
        bufnr = bufnr,
        hidden = hidden,
        toggle = function() table.insert(calls, bufnr) end,
      }
      local normal = local_mappings(bufnr, "n")
      local terminal = local_mappings(bufnr, "t")
      local insert = local_mappings(bufnr, "i")
      if hidden then
        for _, mode in ipairs { "n", "t", "i" } do
          for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
            if mapping.lhs == "<F7>" or mapping.lhs == "<C-'>" then mapping.callback() end
          end
        end
      end
      return {
        buffer = bufnr,
        foldcolumn = vim.wo.foldcolumn,
        signcolumn = vim.wo.signcolumn,
        normal = normal,
        terminal = terminal,
        insert = insert,
      }
    end

    return { hidden = create_terminal(true), visible = create_terminal(false), calls = calls }
  end)()]]

  for _, mode in ipairs { "normal", "terminal", "insert" } do
    for _, key in ipairs { "<F7>", "<C-'>" } do
      assert.is_true(state.hidden[mode][key].callback, mode .. " hidden " .. key)
      assert.equals("Toggle terminal", state.hidden[mode][key].desc, mode .. " hidden " .. key)
      assert.is_nil(state.visible[mode][key], mode .. " visible " .. key)
    end
  end
  assert.same({ foldcolumn = "0", signcolumn = "no" }, {
    foldcolumn = state.hidden.foldcolumn,
    signcolumn = state.hidden.signcolumn,
  })
  assert.same({ foldcolumn = "0", signcolumn = "no" }, {
    foldcolumn = state.visible.foldcolumn,
    signcolumn = state.visible.signcolumn,
  })
  assert.equals(6, #state.calls)
  for _, bufnr in ipairs(state.calls) do
    assert.equals(state.hidden.buffer, bufnr)
  end
end

T["TERM-05 owns base options and bounds terminal lifecycle through AstroNvim mappings"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    local spec = require "astronvim.plugins.toggleterm"
    local mapping = vim.fn.maparg("<Leader>tf", "n", false, true)
    vim.api.nvim_feedkeys(" tf", "mx", false)

    local terminal_buffer
    local opened = vim.wait(3000, function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "terminal" then
          terminal_buffer = bufnr
          return true
        end
      end
      return false
    end, 20)

    local terminal_window = false
    if opened then
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == terminal_buffer then
          terminal_window = true
          break
        end
      end
      vim.cmd "stopinsert"
      vim.api.nvim_feedkeys(vim.keycode "<F7>", "mx", false)
    end

    local hidden = opened and vim.wait(3000, function()
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == terminal_buffer then return false end
      end
      return true
    end, 20)

    return {
      mapping_rhs = mapping.rhs,
      size = spec.opts.size,
      shading_factor = spec.opts.shading_factor,
      highlights = spec.opts.highlights,
      opened = opened,
      terminal_window = terminal_window,
      hidden = hidden,
      terminal_buffer = terminal_buffer,
    }
  end)()]]

  assert.equals("<Cmd>ToggleTerm direction=float<CR>", state.mapping_rhs)
  assert.equals(10, state.size)
  assert.equals(2, state.shading_factor)
  assert.same({
    Normal = { link = "Normal" },
    NormalNC = { link = "NormalNC" },
    NormalFloat = { link = "NormalFloat" },
    FloatBorder = { link = "FloatBorder" },
    StatusLine = { link = "StatusLine" },
    StatusLineNC = { link = "StatusLineNC" },
    WinBar = { link = "WinBar" },
    WinBarNC = { link = "WinBarNC" },
  }, state.highlights)
  assert.is_true(state.opened)
  assert.is_true(state.terminal_window)
  assert.is_true(state.hidden)
end

T["INDENT-02 owns GuessIndent metadata and hands events to the matching buffer only"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    local calls = {}
    package.loaded["guess-indent"] = {
      set_from_buffer = function(bufnr, use_defaults, notify)
        table.insert(calls, { buffer = bufnr, use_defaults = use_defaults, notify = notify })
      end,
    }
    local spec = require "astronvim.plugins.guess-indent"
    assert(spec[1] == "NMAC427/guess-indent.nvim")
    assert(spec.cmd == "GuessIndent")
    assert(spec.opts.auto_cmd == false)
    local astrocore_spec
    for _, nested_spec in ipairs(spec.specs) do
      if nested_spec[1] == "AstroNvim/astrocore" then astrocore_spec = nested_spec end
    end
    local autocmds = astrocore_spec.opts.autocmds.GuessIndent
    local read_callback
    local new_file_callback
    for _, autocmd in ipairs(autocmds) do
      if autocmd.event == "BufReadPost" then read_callback = autocmd.callback end
      if autocmd.event == "BufNewFile" then new_file_callback = autocmd.callback end
    end
    local read_buffer = vim.api.nvim_create_buf(true, false)
    local new_file_buffer = vim.api.nvim_create_buf(true, false)
    local other_buffer = vim.api.nvim_create_buf(true, false)

    read_callback { buf = read_buffer }
    local after_read = #calls
    new_file_callback { buf = new_file_buffer }
    local after_registration = #calls
    vim.api.nvim_exec_autocmds("BufWritePost", { buffer = other_buffer })
    local after_other_write = #calls
    vim.api.nvim_exec_autocmds("BufWritePost", { buffer = new_file_buffer })
    local after_first_write = #calls
    vim.api.nvim_exec_autocmds("BufWritePost", { buffer = new_file_buffer })
    local after_second_write = #calls
    return {
      calls = calls,
      read_buffer = read_buffer,
      new_file_buffer = new_file_buffer,
      autocmds = {
        { event = autocmds[1].event, desc = autocmds[1].desc },
        { event = autocmds[2].event, desc = autocmds[2].desc },
      },
      counts = {
        after_read = after_read,
        after_registration = after_registration,
        after_other_write = after_other_write,
        after_first_write = after_first_write,
        after_second_write = after_second_write,
      },
    }
  end)()]]

  assert.same({
    after_read = 1,
    after_registration = 1,
    after_other_write = 1,
    after_first_write = 2,
    after_second_write = 2,
  }, state.counts)
  assert.equals(2, #state.calls)
  assert.same({
    { event = "BufReadPost", desc = "Guess indentation when loading a file" },
    { event = "BufNewFile", desc = "Guess indentation when saving a new file" },
  }, state.autocmds)
  assert.same({ use_defaults = true, notify = true }, {
    use_defaults = state.calls[1].use_defaults,
    notify = state.calls[1].notify,
  })
  assert.same({ use_defaults = true, notify = true }, {
    use_defaults = state.calls[2].use_defaults,
    notify = state.calls[2].notify,
  })
  assert.equals(state.read_buffer, state.calls[1].buffer)
  assert.equals(state.new_file_buffer, state.calls[2].buffer)
end

return T
