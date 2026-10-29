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

T["NVIM-FS-01 uses native autoread or the supported checktime fallback"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  local is_neovim_013 = child.lua_get "vim.fn.has('nvim-0.13') == 1"
  if not is_neovim_013 then
    assert.is_false(child.lua_get "vim.o.autoread")
    local path = helpers.fixture_project(child) .. "/checktime-fallback.txt"
    vim.fn.writefile({ "before" }, path)
    child.lua(([[vim.cmd.edit(%s)]]):format(vim.inspect(path)))
    helpers.wait_until(
      child,
      ([[vim.api.nvim_buf_get_name(0) == %s and vim.api.nvim_get_current_line() == "before"]]):format(vim.inspect(path)),
      "checktime fixture"
    )

    vim.wait(1200)
    vim.fn.writefile({ "after" }, path)
    child.lua [[
      local autoread = vim.bo.autoread
      vim.bo.autoread = true
      vim.cmd "checktime"
      vim.bo.autoread = autoread
    ]]
    helpers.wait_until(child, "vim.api.nvim_get_current_line() == 'after'", "checktime file change")

    child.lua [[
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" })
      vim.bo.modified = true
    ]]
    vim.wait(1200)
    vim.fn.writefile({ "external" }, path)
    child.lua [[vim.api.nvim_exec_autocmds("FocusGained", {})]]
    vim.wait(100)
    assert.equals("unsaved", child.lua_get "vim.api.nvim_get_current_line()")

    return
  end

  local options = child.lua_get [[{
    autoread = vim.o.autoread,
    diff_algorithm = vim.opt.diffopt:get().algorithm,
    diff_linematch = vim.opt.diffopt:get().linematch,
  }]]
  assert.is_true(options.autoread)
  assert.equals("histogram", options.diff_algorithm)
  assert.equals("60", options.diff_linematch)

  local path = helpers.fixture_project(child) .. "/native-autoread.txt"
  vim.fn.writefile({ "before" }, path)
  child.lua(([[vim.cmd.edit(%s)]]):format(vim.inspect(path)))
  helpers.wait_until(
    child,
    ([[vim.api.nvim_buf_get_name(0) == %s and vim.api.nvim_get_current_line() == "before"]]):format(vim.inspect(path)),
    "native autoread fixture"
  )

  vim.fn.writefile({ "after" }, path)
  helpers.wait_until(child, "vim.api.nvim_get_current_line() == 'after'", "native autoread file change")

  if child.lua_get "vim.fn.has('win32') == 1" then
    vim.fn.writefile({ "replaced" }, path)
  else
    local replacement = path .. ".replacement"
    vim.fn.writefile({ "replaced" }, replacement)
    assert.equals(0, vim.fn.rename(replacement, path))
  end
  helpers.wait_until(child, "vim.api.nvim_get_current_line() == 'replaced'", "native autoread replacement")
end

return T
