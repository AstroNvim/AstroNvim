local MiniTest = require "mini.test"
local config = require "config"
local helpers = require "helpers"

local highlight_groups = { "NeoTreeDirectoryName", "NeoTreeFileName", "NeoTreeRootName" }
local production_mapping_command = "<Cmd>Neotree toggle<CR>"

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

T["opens Neo-tree with the default leader mapping at the fixture root"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")
  helpers.wait_until(child, "vim.fn.maparg('<Leader>e', 'n', false, true).rhs ~= ''", "<Leader>e mapping")

  local before_input = child.lua_get [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then return true end
    end
    return false
  end)()]]
  local mapping = child.lua_get "vim.fn.maparg('<Leader>e', 'n', false, true)"
  assert.is_false(before_input)
  assert.equals(production_mapping_command, mapping.rhs)

  child.type_keys "<Space>e"
  helpers.wait_until(
    child,
    [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then return true end
    end
    return false
  end)()]],
    "visible neo-tree window"
  )

  local state = child.lua_get [[(function()
    local neo_tree_window
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then
        neo_tree_window = winid
        break
      end
    end
    local filesystem = require("neo-tree.sources.manager").get_state("filesystem")
    return {
      loaded = package.loaded["neo-tree"] ~= nil,
      root = vim.fs.normalize(filesystem.path),
      visible = neo_tree_window ~= nil and vim.api.nvim_win_is_valid(neo_tree_window),
      focused = neo_tree_window ~= nil and vim.api.nvim_get_current_win() == neo_tree_window,
      git_status = vim.fn.systemlist({ "git", "status", "--porcelain" }),
      highlights = (function()
        local highlights = {}
        for _, group in ipairs({ "NeoTreeDirectoryName", "NeoTreeFileName", "NeoTreeRootName" }) do
          highlights[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
        end
        return highlights
      end)(),
    }
  end)()]]

  assert.is_true(state.loaded)
  assert.is_true(state.visible)
  assert.is_true(state.focused)
  assert.equals(vim.fs.normalize(helpers.fixture_project(child)), state.root)
  assert.same({}, state.git_status)
  helpers.expect_screen(
    child,
    "neo-tree",
    function(screenshot) return helpers.normalize_fixture_root(screenshot, helpers.fixture_project(child)) end
  )
  helpers.expect_highlight_golden(child, config.highlights_dir .. "/neo-tree.txt", state.highlights, highlight_groups)
end

return T
