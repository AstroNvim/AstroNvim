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

local function start_ready_child()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")
end

local function neo_tree_visible_expression()
  return [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then return true end
    end
    return false
  end)()]]
end

local function find_cell_sequence(cells, value)
  local expected = vim.fn.split(value, "\\zs")
  for start = 1, #cells - #expected + 1 do
    local matches = true
    for index, cell in ipairs(expected) do
      if cells[start + index - 1] ~= cell then
        matches = false
        break
      end
    end
    if matches then return start end
  end
end

local function normalize_fixture_entries(screenshot)
  local fixture_names = { "git-tracked.txt", "indentation.txt", "session.json" }
  local entry_counts = {}
  local rows_to_remove = {}
  local hidden_items_row
  local hidden_items_count = 0
  local singular_hidden_items_count = 0

  local blank_row = #screenshot.text - 1
  local divider
  for column, cell in ipairs(screenshot.text[blank_row]) do
    if cell == "│" then
      divider = column
      break
    end
  end
  assert.is_not_nil(divider)
  for column = divider + 1, #screenshot.text[blank_row] do
    assert.equals(" ", screenshot.text[blank_row][column], "Expected a blank editor-pane reference row")
  end

  for row, cells in ipairs(screenshot.text) do
    local line = table.concat(cells)
    for _, name in ipairs(fixture_names) do
      if line:find(name, 1, true) then
        entry_counts[name] = (entry_counts[name] or 0) + 1
        table.insert(rows_to_remove, row)
        for column = divider + 1, #screenshot.text[row] do
          assert.equals(
            screenshot.text[blank_row][column],
            screenshot.text[row][column],
            "Fixture normalization cannot discard editor-pane text"
          )
          assert.equals(
            screenshot.attr[blank_row][column],
            screenshot.attr[row][column],
            "Fixture normalization cannot discard editor-pane highlights"
          )
        end
      end
    end
    if find_cell_sequence(cells, "(2 hidden items)") then
      hidden_items_count = hidden_items_count + 1
      hidden_items_row = row
    end
    if find_cell_sequence(cells, "(1 hidden item)") then
      singular_hidden_items_count = singular_hidden_items_count + 1
    end
  end

  for _, name in ipairs(fixture_names) do
    assert.equals(1, entry_counts[name], "Expected exactly one Neo-tree fixture entry for " .. name)
  end
  assert.equals(1, hidden_items_count, "Expected exactly one pre-normalization hidden-item row")
  assert.equals(0, singular_hidden_items_count, "Expected the fixture directory to contribute one hidden item")

  local item_start = assert(find_cell_sequence(screenshot.text[hidden_items_row], "(2 hidden items)"))
  local replacement = vim.fn.split("(1 hidden item) ", "\\zs")
  for index, cell in ipairs(replacement) do
    screenshot.text[hidden_items_row][item_start + index - 1] = cell
  end
  local trailing_column = item_start + #replacement - 1
  screenshot.attr[hidden_items_row][trailing_column] = screenshot.attr[hidden_items_row][trailing_column + 1]

  table.sort(rows_to_remove, function(left, right) return left > right end)
  for _, row in ipairs(rows_to_remove) do
    table.remove(screenshot.text, row)
    table.remove(screenshot.attr, row)
  end

  for _ = 1, #rows_to_remove do
    blank_row = #screenshot.text - 1
    table.insert(screenshot.text, #screenshot.text, vim.deepcopy(screenshot.text[blank_row]))
    table.insert(screenshot.attr, #screenshot.attr, vim.deepcopy(screenshot.attr[blank_row]))
  end

  return screenshot
end

T["BASE-06 opens Neo-tree with the default leader mapping at the fixture root"] = function()
  start_ready_child()
  helpers.wait_until(child, "vim.fn.maparg('<Leader>e', 'n', false, true).rhs ~= ''", "<Leader>e mapping")

  local before_input = child.lua_get(neo_tree_visible_expression())
  local mapping = child.lua_get "vim.fn.maparg('<Leader>e', 'n', false, true)"
  assert.is_false(before_input)
  assert.equals(production_mapping_command, mapping.rhs)

  child.type_keys "<Space>e"
  helpers.wait_until(child, neo_tree_visible_expression(), "visible neo-tree window")

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
  helpers.expect_screen(child, "neo-tree", function(screenshot)
    screenshot = helpers.normalize_fixture_root(screenshot, helpers.fixture_project(child))
    return normalize_fixture_entries(screenshot)
  end)
  helpers.expect_highlight_golden(child, config.highlights_dir .. "/neo-tree.txt", state.highlights, highlight_groups)
end

T["NEO-01 focuses Neo-tree from a file window and returns from its window"] = function()
  start_ready_child()
  local origin = child.lua_get "vim.api.nvim_get_current_win()"

  child.type_keys "<Space>o"
  helpers.wait_until(child, neo_tree_visible_expression(), "Neo-tree focus from file window")
  local neo_tree_window = child.lua_get [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then return winid end
    end
  end)()]]
  assert.equals(neo_tree_window, child.lua_get "vim.api.nvim_get_current_win()")

  child.type_keys "<Space>o"
  helpers.wait_until(child, "vim.api.nvim_get_current_win() == " .. origin, "return from Neo-tree")
  assert.equals(origin, child.lua_get "vim.api.nvim_get_current_win()")
end

T["NEO-02 leaves file buffers alone and loads Neo-tree for an entered directory"] = function()
  start_ready_child()

  local before_directory = child.lua_get [[(function()
    vim.cmd.edit(vim.fn.fnameescape(vim.fn.getcwd() .. "/plain.txt"))
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = vim.api.nvim_get_current_buf() })
    return package.loaded["neo-tree"] ~= nil
  end)()]]
  assert.is_false(before_directory)

  child.lua [[
    local directory_buffer = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(directory_buffer, vim.fn.getcwd())
    vim.api.nvim_win_set_buf(0, directory_buffer)
    vim.api.nvim_exec_autocmds("BufEnter", { buffer = directory_buffer })
  ]]
  helpers.wait_until(child, "package.loaded['neo-tree'] ~= nil", "Neo-tree directory startup")
  assert.is_true(child.lua_get "package.loaded['neo-tree'] ~= nil")
end

T["NEO-06 applies Neo-tree-local sign and fold columns"] = function()
  start_ready_child()
  child.type_keys "<Space>e"
  helpers.wait_until(child, neo_tree_visible_expression(), "visible Neo-tree window")
  helpers.wait_until(
    child,
    [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then
        return vim.wo[winid].signcolumn == "auto" and vim.wo[winid].foldcolumn == "0"
      end
    end
    return false
  end)()]],
    "Neo-tree-local columns"
  )

  local columns = child.lua_get [[(function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "neo-tree" then
        return { signcolumn = vim.wo[winid].signcolumn, foldcolumn = vim.wo[winid].foldcolumn }
      end
    end
  end)()]]
  assert.same({ signcolumn = "auto", foldcolumn = "0" }, columns)
end

T["NEO-08 leaves Neo-tree-local columns behind after returning to the file window"] = function()
  start_ready_child()
  local origin = child.lua_get "vim.api.nvim_get_current_win()"
  child.lua [[
    vim.wo.signcolumn = "yes:2"
    vim.wo.foldcolumn = "3"
  ]]

  child.type_keys "<Space>e"
  helpers.wait_until(child, neo_tree_visible_expression(), "visible Neo-tree window")
  child.type_keys "<Space>o"
  helpers.wait_until(child, "vim.api.nvim_get_current_win() == " .. origin, "return to file window")

  assert.equals("yes:2", child.lua_get "vim.wo.signcolumn")
  assert.equals("3", child.lua_get "vim.wo.foldcolumn")
end

return T
