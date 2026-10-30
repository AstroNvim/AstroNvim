local MiniTest = require "mini.test"
local helpers = require "helpers"

local child

local function write_with_new_mtime(path, lines)
  local before = assert(vim.uv.fs_stat(path))
  assert.equals(0, vim.fn.writefile(lines, path))
  assert(vim.uv.fs_utime(path, before.atime.sec, before.mtime.sec + 2))
end

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
  child = helpers.start_ready_child()

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

    local buffer_state = child.lua_get [[{
      autoread = vim.bo.autoread == true,
      buftype = vim.bo.buftype,
      modified = vim.bo.modified,
    }]]
    assert.same({ autoread = false, buftype = "", modified = false }, buffer_state)
    write_with_new_mtime(path, { "after" })
    -- Synthetic FocusGained does not run checktime on Neovim 0.12; invoke the production callback.
    child.lua [[require("astronvim.plugins._astrocore_autocmds").opts.autocmds.checktime[1].callback()]]
    helpers.wait_until(child, "vim.api.nvim_get_current_line() == 'after'", "checktime file change")
    assert.is_not_true(child.lua_get "vim.bo.autoread")

    child.lua [[
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" })
      vim.bo.modified = true
    ]]
    write_with_new_mtime(path, { "external" })
    child.cmd [[doautocmd FocusGained]]
    helpers.wait_until(child, "vim.api.nvim_get_current_line() == 'unsaved'", "modified buffer preservation")

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
