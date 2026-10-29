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

T["TREESITTER-E2E-01 parses a real Lua buffer and disables large-buffer parsing"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  local parsed = child.lua_get [[(function()
    vim.cmd.enew()
    vim.bo.filetype = "lua"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "local function add(left, right)",
      "  return left + right",
      "end",
    })
    local parser = vim.treesitter.get_parser(0, "lua")
    local tree = parser:parse()[1]
    return { root = tree:root():type(), children = tree:root():named_child_count() }
  end)()]]

  assert.equals("chunk", parsed.root)
  assert.is_true(parsed.children >= 1)

  local large = child.lua_get [[(function()
    local path = vim.fs.joinpath(vim.fn.getcwd(), "large.lua")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { string.rep("x", 1600000) })
    vim.api.nvim_buf_set_name(0, path)
    vim.cmd.write()
    local buffer = require("astrocore.buffer")
    return {
      large = buffer.is_large(0),
      treesitter = require("astrocore.treesitter").is_enabled(0),
    }
  end)()]]
  assert.is_true(large.large)
  assert.is_false(large.treesitter)
end

return T
