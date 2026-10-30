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

T["FIXTURE-01 validates file variants and live GuessIndent and Gitsigns effects"] = function()
  child = helpers.start_ready_child()

  local project = helpers.fixture_project(child)
  local state = child.lua_get(([=[(function()
    local project = %s
    local indentation = vim.fs.joinpath(project, "indentation.txt")
    local tracked = vim.fs.joinpath(project, "git-tracked.txt")
    local untracked = vim.fs.joinpath(project, "git-untracked.txt")
    local indentation_options
    vim.fn.writefile({ "tracked fixture modification" }, tracked)
    vim.fn.writefile({ "untracked fixture content" }, untracked)
    vim.cmd.edit(vim.fn.fnameescape(indentation))
    local indentation_buffer = vim.api.nvim_get_current_buf()
    indentation_options = {
      expandtab = vim.bo.expandtab,
      tabstop = vim.bo.tabstop,
      softtabstop = vim.bo.softtabstop,
      shiftwidth = vim.bo.shiftwidth,
    }

    vim.cmd.edit(vim.fn.fnameescape(tracked))
    local tracked_buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_exec_autocmds("User", { pattern = "AstroGitFile", modeline = false })
    vim.wait(3000, function()
      return #(require("gitsigns").get_hunks(tracked_buffer) or {}) >= 1
    end, 20)
    local git_status = vim.fn.systemlist { "git", "-C", project, "status", "--short" }
    local hunks = require("gitsigns").get_hunks(tracked_buffer) or {}

    return {
      indentation_buffer = indentation_buffer,
      indentation_name = vim.api.nvim_buf_get_name(indentation_buffer),
      indentation_options = indentation_options,
      tracked_buffer = tracked_buffer,
      tracked_name = vim.api.nvim_buf_get_name(tracked_buffer),
      gitsigns_hunk_count = #hunks,
      git_status = git_status,
      indentation_content = vim.fn.readfile(indentation),
    }
  end)()]=]):format(vim.inspect(project)))

  assert.same({ expandtab = true, tabstop = 2, softtabstop = 2, shiftwidth = 2 }, state.indentation_options)
  assert.is_true(state.gitsigns_hunk_count >= 1)
  assert.equals(vim.fs.joinpath(project, "indentation.txt"), state.indentation_name)
  assert.equals(vim.fs.joinpath(project, "git-tracked.txt"), state.tracked_name)
  assert.is_true(state.indentation_buffer ~= state.tracked_buffer)
  assert.same({ " M git-tracked.txt", "?? git-untracked.txt" }, state.git_status)
  assert.same({ "root", "  two-space indent", "\tone-tab indent" }, state.indentation_content)
end

return T
