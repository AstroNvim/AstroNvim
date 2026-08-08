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

T["TEST-03 validates fixture variants and bounded GuessIndent and Gitsigns activation"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  local project = helpers.fixture_project(child)
  local state = child.lua_get(([=[(function()
    local project = %s
    local indentation = vim.fs.joinpath(project, "indentation.txt")
    local tracked = vim.fs.joinpath(project, "git-tracked.txt")
    local untracked = vim.fs.joinpath(project, "git-untracked.txt")
    local session = vim.fs.joinpath(project, "session.json")
    local launch = vim.fs.joinpath(project, ".vscode", "launch.json")
    vim.fn.writefile({ "tracked fixture modification" }, tracked)
    vim.fn.writefile({ "untracked fixture content" }, untracked)
    vim.cmd.edit(vim.fn.fnameescape(indentation))
    local indentation_buffer = vim.api.nvim_get_current_buf()
    local guess_indent_loaded = vim.wait(3000, function() return package.loaded["guess-indent"] ~= nil end, 20)

    vim.cmd.edit(vim.fn.fnameescape(tracked))
    local tracked_buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_exec_autocmds("User", { pattern = "AstroGitFile", modeline = false })
    local gitsigns_loaded = vim.wait(3000, function() return package.loaded.gitsigns ~= nil end, 20)
    local git_status = vim.fn.systemlist { "git", "-C", project, "status", "--short" }
    local session_data = vim.json.decode(table.concat(vim.fn.readfile(session), "\n"))
    local launch_data = vim.json.decode(table.concat(vim.fn.readfile(launch), "\n"))

    return {
      indentation_buffer = indentation_buffer,
      indentation_name = vim.api.nvim_buf_get_name(indentation_buffer),
      guess_indent_loaded = guess_indent_loaded,
      tracked_buffer = tracked_buffer,
      tracked_name = vim.api.nvim_buf_get_name(tracked_buffer),
      gitsigns_loaded = gitsigns_loaded,
      git_status = git_status,
      indentation_content = vim.fn.readfile(indentation),
      session_data = session_data,
      launch_data = launch_data,
    }
  end)()]=]):format(vim.inspect(project)))

  assert.is_true(state.guess_indent_loaded)
  assert.is_true(state.gitsigns_loaded)
  assert.equals(vim.fs.joinpath(project, "indentation.txt"), state.indentation_name)
  assert.equals(vim.fs.joinpath(project, "git-tracked.txt"), state.tracked_name)
  assert.is_true(state.indentation_buffer ~= state.tracked_buffer)
  assert.same({ " M git-tracked.txt", "?? git-untracked.txt" }, state.git_status)
  assert.same({ "root", "  two-space indent", "\tone-tab indent" }, state.indentation_content)
  assert.same({ name = "fixture-session", buffers = { "plain.txt", "indentation.txt" } }, state.session_data)
  assert.same({
    version = "0.2.0",
    configurations = { { name = "Fixture", type = "lua", request = "launch" } },
  }, state.launch_data)
end

return T
