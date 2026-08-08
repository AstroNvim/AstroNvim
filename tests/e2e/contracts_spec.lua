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

local function expect_members(values, expected)
  for _, expected_value in ipairs(expected) do
    local found = false
    for _, value in ipairs(values) do
      if value == expected_value then
        found = true
        break
      end
    end
    MiniTest.expect.equality(found, true)
  end
end

local function expect_autocmds(autocmds, expected)
  for _, expected_autocmd in ipairs(expected) do
    local matches = 0
    for _, autocmd in ipairs(autocmds or {}) do
      if autocmd.event == expected_autocmd.event and autocmd.pattern == expected_autocmd.pattern then
        matches = matches + 1
      end
    end
    MiniTest.expect.equality(matches, 1)
  end
end

T["BASE-04 resolves high-value plugin metadata and options"] = function()
  start_ready_child()

  local actual = child.lua_get [[(function()
    local plugins = require("lazy.core.config").plugins
    local astrocore = require("astrocore").config
    local astrolsp = require("astrocore").plugin_opts "astrolsp"
    local astroui = require("astroui").config

    local function list(value)
      if value == nil then return {} end
      return type(value) == "table" and value or { value }
    end

    local function dependencies(plugin)
      local names = {}
      for _, dependency in ipairs(plugin.dependencies or {}) do
        table.insert(names, type(dependency) == "table" and dependency.name or dependency)
      end
      return names
    end

    return {
      plugins = {
        AstroNvim = { lazy = plugins.AstroNvim.lazy, priority = plugins.AstroNvim.priority },
        astrocore = {
          lazy = plugins.astrocore.lazy,
          priority = plugins.astrocore.priority,
          dependencies = dependencies(plugins.astrocore),
        },
        astroui = { lazy = plugins.astroui.lazy },
        astrolsp = { event = list(plugins.astrolsp.event) },
        blink = { event = list(plugins["blink.cmp"].event) },
        treesitter = {
          event = list(plugins["nvim-treesitter"].event),
          cmd = list(plugins["nvim-treesitter"].cmd),
          lazy = plugins["nvim-treesitter"].lazy,
        },
        neotree = { cmd = list(plugins["neo-tree.nvim"].cmd) },
        mason = { cmd = list(plugins["mason.nvim"].cmd) },
        installer = {
          cmd = list(plugins["mason-tool-installer.nvim"].cmd),
          dependencies = dependencies(plugins["mason-tool-installer.nvim"]),
        },
        dap = { lazy = plugins["nvim-dap"].lazy, dependencies = dependencies(plugins["nvim-dap"]) },
        mason_dap = {
          cmd = list(plugins["mason-nvim-dap.nvim"].cmd),
          dependencies = dependencies(plugins["mason-nvim-dap.nvim"]),
        },
        dap_ui = { dependencies = dependencies(plugins["nvim-dap-ui"]) },
        lazydev = { ft = list(plugins["lazydev.nvim"].ft), cmd = list(plugins["lazydev.nvim"].cmd) },
      },
      astrolsp = {
        defaults = astrolsp.defaults,
        formatting = astrolsp.formatting,
      },
      astrocore = {
        features = {
          autopairs = astrocore.features.autopairs,
          cmp = astrocore.features.cmp,
          diagnostics = astrocore.features.diagnostics,
          highlighturl = astrocore.features.highlighturl,
          notifications = astrocore.features.notifications,
        },
        diagnostics = {
          virtual_text = astrocore.diagnostics.virtual_text,
          update_in_insert = astrocore.diagnostics.update_in_insert,
          underline = astrocore.diagnostics.underline,
          severity_sort = astrocore.diagnostics.severity_sort,
          float = astrocore.diagnostics.float,
        },
      },
      astroui = {
        colorscheme = astroui.colorscheme,
        folding = { methods = astroui.folding.methods },
      },
    }
  end)()]]

  expect_values(actual.plugins.AstroNvim, { lazy = false, priority = 10000 })
  expect_values(actual.plugins.astrocore, { lazy = false, priority = 10000 })
  expect_members(actual.plugins.astrocore.dependencies, { "astroui" })
  expect_values(actual.plugins.astroui, { lazy = true })

  expect_members(actual.plugins.astrolsp.event, { "User AstroFile" })
  expect_values(actual.astrolsp.defaults.hover, { silent = true })
  expect_values(actual.astrolsp.defaults.signature_help, { silent = true, focusable = false })
  expect_values(actual.astrolsp.formatting.format_on_save, { enabled = true })
  MiniTest.expect.equality(#actual.astrolsp.formatting.disabled, 0)

  expect_members(actual.plugins.blink.event, { "InsertEnter", "CmdlineEnter" })
  expect_members(actual.plugins.treesitter.event, { "VeryLazy" })
  expect_members(
    actual.plugins.treesitter.cmd,
    { "TSInstall", "TSInstallFromGrammar", "TSUninstall", "TSUpdate", "TSLog" }
  )
  expect_values(actual.plugins.treesitter, { lazy = true })
  expect_members(actual.plugins.neotree.cmd, { "Neotree" })
  expect_members(
    actual.plugins.mason.cmd,
    { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" }
  )

  expect_members(actual.plugins.installer.cmd, {
    "MasonToolsInstall",
    "MasonToolsInstallSync",
    "MasonToolsUpdate",
    "MasonToolsUpdateSync",
    "MasonToolsClean",
  })
  expect_members(actual.plugins.installer.dependencies, { "mason.nvim", "astrocore" })
  expect_values(actual.plugins.dap, { lazy = true })
  expect_members(actual.plugins.dap.dependencies, { "mason-nvim-dap.nvim", "nvim-dap-ui", "cmp-dap" })
  expect_members(actual.plugins.mason_dap.cmd, { "DapInstall", "DapUninstall" })
  expect_members(actual.plugins.mason_dap.dependencies, { "nvim-dap", "mason.nvim" })
  expect_members(actual.plugins.dap_ui.dependencies, { "nvim-nio" })

  expect_members(actual.plugins.lazydev.ft, { "lua" })
  expect_members(actual.plugins.lazydev.cmd, { "LazyDev" })
  expect_values(actual.astrocore.features, {
    autopairs = true,
    cmp = true,
    diagnostics = true,
    highlighturl = true,
    notifications = true,
  })
  expect_values(actual.astrocore.diagnostics, {
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
  })
  expect_values(actual.astrocore.diagnostics.float, { source = "if_many", header = "", prefix = "" })
  expect_values(actual.astroui, { colorscheme = "astrotheme" })
  expect_members(actual.astroui.folding.methods, { "lsp", "treesitter", "indent" })
end

T["BASE-04 applies representative mappings and global options"] = function()
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

T["BASE-04 registers unique high-value autocmd descriptions events and patterns"] = function()
  start_ready_child()

  local descriptions = {
    "Automatically create parent directories if they don't exist when saving a file",
    "Highlight yanked text",
    "Unlist quickfix buffers",
    "Disable certain functionality on very large files",
    "trigger willCreateFiles before writing a new file",
    "trigger didCreateFiles after writing a new file",
    "Open Neo-Tree on startup with directory",
    "Refresh Neo-Tree sources when closing lazygit",
  }
  local actual = child.lua_get [[
    (function()
      local descriptions = {
        "Automatically create parent directories if they don't exist when saving a file",
        "Highlight yanked text",
        "Unlist quickfix buffers",
        "Disable certain functionality on very large files",
        "trigger willCreateFiles before writing a new file",
        "trigger didCreateFiles after writing a new file",
        "Open Neo-Tree on startup with directory",
        "Refresh Neo-Tree sources when closing lazygit",
      }
      local autocmds = {}
      for _, description in ipairs(descriptions) do
        autocmds[description] = {}
        for _, autocmd in ipairs(vim.api.nvim_get_autocmds {}) do
          if autocmd.desc == description then
            table.insert(autocmds[description], { event = autocmd.event, pattern = autocmd.pattern })
          end
        end
        table.sort(autocmds[description], function(left, right)
          return left.event == right.event and left.pattern < right.pattern or left.event < right.event
        end)
      end
      return autocmds
    end)()
  ]]

  local cases = {
    {
      name = "create parent directories",
      description = descriptions[1],
      expected = { { event = "BufWritePre", pattern = "*" } },
    },
    {
      name = "highlight yanked text",
      description = descriptions[2],
      expected = { { event = "TextYankPost", pattern = "*" } },
    },
    {
      name = "unlist quickfix buffers",
      description = descriptions[3],
      expected = { { event = "FileType", pattern = "qf" } },
    },
    {
      name = "large buffer settings",
      description = descriptions[4],
      expected = { { event = "User", pattern = "AstroLargeBuf" } },
    },
    {
      name = "LSP will create files",
      description = descriptions[5],
      expected = { { event = "BufWritePre", pattern = "*" } },
    },
    {
      name = "LSP did create files",
      description = descriptions[6],
      expected = { { event = "BufWritePost", pattern = "*" } },
    },
    {
      name = "Neo-tree directory startup",
      description = descriptions[7],
      expected = { { event = "BufEnter", pattern = "*" } },
    },
    {
      name = "Neo-tree lazygit refresh",
      description = descriptions[8],
      expected = { { event = "TermClose", pattern = "*lazygit*" } },
    },
  }

  for _, case in ipairs(cases) do
    expect_autocmds(actual[case.description], case.expected)
  end
end

return T
