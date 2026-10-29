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

local function expect_values(actual, expected)
  for key, value in pairs(expected) do
    MiniTest.expect.equality(actual[key], value)
  end
end

T["CONTRACT-01 exposes required user entry points after startup"] = function()
  start_ready_child()

  local actual = child.lua_get [[{
    ready = vim.g.astronvim_test_ready,
    commands = {
      lazy = vim.fn.exists(":Lazy") == 2,
      mason = vim.fn.exists(":Mason") == 2,
      neo_tree = vim.fn.exists(":Neotree") == 2,
      astro_version = vim.fn.exists(":AstroVersion") == 2,
    },
    mappings = {
      save = vim.fn.maparg("<Leader>w", "n", false, true).rhs ~= "",
      explorer = vim.fn.maparg("<Leader>e", "n", false, true).rhs ~= "",
      home = vim.fn.maparg("<Leader>h", "n", false, true).rhs ~= "",
    },
  }]]

  assert.is_true(actual.ready)
  for name, available in pairs(actual.commands) do
    assert.is_true(available, name)
  end
  for name, available in pairs(actual.mappings) do
    assert.is_true(available, name)
  end
end

T["CONTRACT-02 applies representative mappings and global options"] = function()
  start_ready_child()

  local actual = child.lua_get [[(function()
    local mappings = {}
    for _, lhs in ipairs({ "<Leader>w", "<Leader>q", "<Leader>e", "<Leader>pM", "<Leader>/" }) do
      local mapping = vim.fn.maparg(lhs, "n", false, true)
      mappings[lhs] = { rhs = mapping.rhs, desc = mapping.desc }
    end

    return {
      mappings = mappings,
      options = {
        clipboard = vim.o.clipboard,
        cmdheight = vim.o.cmdheight,
        completeopt = vim.o.completeopt,
        confirm = vim.o.confirm,
        cursorline = vim.o.cursorline,
        foldcolumn = vim.o.foldcolumn,
        foldenable = vim.o.foldenable,
        foldlevel = vim.o.foldlevel,
        foldmethod = vim.o.foldmethod,
        foldtext = vim.o.foldtext,
        number = vim.o.number,
        relativenumber = vim.o.relativenumber,
        termguicolors = vim.o.termguicolors,
        timeoutlen = vim.o.timeoutlen,
        updatetime = vim.o.updatetime,
        wrap = vim.o.wrap,
        markdown_recommended_style = vim.g.markdown_recommended_style,
      },
    }
  end)()]]

  local mappings = {
    ["<Leader>w"] = { rhs = "<Cmd>w<CR>", desc = "Save" },
    ["<Leader>q"] = { rhs = "<Cmd>confirm q<CR>", desc = "Quit Window" },
    ["<Leader>e"] = { rhs = "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer" },
    ["<Leader>pM"] = { rhs = "<Cmd>MasonToolsUpdate<CR>", desc = "Mason Update" },
    ["<Leader>/"] = { rhs = "gcc", desc = "Toggle comment line" },
  }
  for lhs, expected in pairs(mappings) do
    expect_values(actual.mappings[lhs], expected)
  end

  expect_values(actual.options, {
    clipboard = "unnamedplus",
    cmdheight = 0,
    completeopt = "menu,menuone,noselect",
    confirm = true,
    cursorline = true,
    foldcolumn = "1",
    foldenable = true,
    foldlevel = 99,
    foldmethod = "expr",
    foldtext = "",
    number = true,
    relativenumber = true,
    termguicolors = true,
    timeoutlen = 500,
    updatetime = 300,
    wrap = false,
    markdown_recommended_style = 0,
  })
end

T["CONTRACT-03 registers required public autocmd behavior"] = function()
  start_ready_child()

  local actual = child.lua_get [[(function()
    local autocmds = {}
    for _, autocmd in ipairs(vim.api.nvim_get_autocmds {}) do
      table.insert(autocmds, { event = autocmd.event, pattern = autocmd.pattern })
    end
    return autocmds
  end)()]]

  for _, required in ipairs {
    { event = "BufWritePre", pattern = "*" },
    { event = "TextYankPost", pattern = "*" },
    { event = "FileType", pattern = "qf" },
    { event = "User", pattern = "AstroLargeBuf" },
    { event = "BufWritePost", pattern = "*" },
    { event = "BufEnter", pattern = "*" },
    { event = "TermClose", pattern = "*lazygit*" },
  } do
    local found = false
    for _, autocmd in ipairs(actual) do
      if autocmd.event == required.event and autocmd.pattern == required.pattern then found = true end
    end
    assert.is_true(found, required.event .. " " .. required.pattern)
  end
end

return T
