local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then return true end
  end
  return false
end

local function find_nested_spec(spec, name)
  for _, nested_spec in ipairs(spec.specs) do
    if nested_spec[1] == name then return nested_spec end
  end
  error("Missing nested spec: " .. name)
end

local function with_luasnip_configuration(options, callback)
  if type(options) == "function" then
    callback = options
    options = {}
  end
  options = options or {}
  local calls = { loaders = {}, loader_order = {}, setup_count = 0 }
  local loaded = {
    luasnip = {
      config = {
        setup = function(setup_options)
          calls.setup_count = calls.setup_count + 1
          calls.setup_options = setup_options
        end,
      },
    },
  }
  for _, loader_type in ipairs { "vscode", "snipmate", "lua" } do
    loaded["luasnip.loaders.from_" .. loader_type] = {
      lazy_load = function()
        calls.loaders[loader_type] = (calls.loaders[loader_type] or 0) + 1
        table.insert(calls.loader_order, loader_type)
        if options.loader_errors and options.loader_errors[loader_type] then error(loader_type .. " loader failed") end
      end,
    }
  end

  unit_helpers.with_module("astronvim.plugins.configs.luasnip", {
    loaded = loaded,
  }, function(configure) callback(configure, calls) end)
end

T["SNIP-01 configures LuaSnip only with options and always loads each loader"] = function()
  with_luasnip_configuration(function(configure, calls)
    configure(nil, nil)

    assert.equals(0, calls.setup_count)
    assert.same({ vscode = 1, snipmate = 1, lua = 1 }, calls.loaders)
  end)

  with_luasnip_configuration(function(configure, calls)
    local options = { history = true }
    configure(nil, options)

    assert.equals(1, calls.setup_count)
    assert.equals(options, calls.setup_options)
    assert.same({ vscode = 1, snipmate = 1, lua = 1 }, calls.loaders)
  end)
end

T["SNIP-02 declares LuaSnip options build dependency and Blink preset"] = function()
  local build_command =
    "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"

  for _, case in ipairs {
    { name = "non-Windows", has_win32 = 0, expected_build = build_command },
    { name = "Windows", has_win32 = 1, expected_build = nil },
  } do
    local has_calls = {}
    unit_helpers.with_module("astronvim.plugins.luasnip", {
      vim = {
        fn = {
          has = function(feature)
            table.insert(has_calls, feature)
            return case.has_win32
          end,
        },
      },
    }, function(spec)
      assert.same({ "win32" }, has_calls)
      assert.equals(case.expected_build, spec.build, case.name)
      assert.same({
        history = true,
        delete_check_events = "TextChanged",
        region_check_events = "CursorMoved",
      }, spec.opts)
      local friendly_snippets
      for _, dependency in ipairs(spec.dependencies) do
        if dependency[1] == "rafamadriz/friendly-snippets" then friendly_snippets = dependency end
      end
      assert.equals("table", type(friendly_snippets))
      assert.is_true(friendly_snippets.lazy)

      local blink = find_nested_spec(spec, "saghen/blink.cmp")
      assert.is_true(blink.optional)
      assert.equals("luasnip", blink.opts.snippets.preset)
    end)
  end
end

T["PAIR-01 declares AutoPairs buffer gating, Java exception, and toggle dispatch"] = function()
  local valid_buffers = {}
  local toggle_calls = {}
  unit_helpers.with_module("astronvim.plugins.autopairs", {
    loaded = {
      ["astrocore.buffer"] = {
        is_valid = function(bufnr)
          table.insert(valid_buffers, bufnr)
          return bufnr == 12
        end,
      },
      ["astrocore.toggles"] = {
        autopairs = function() table.insert(toggle_calls, "autopairs") end,
      },
    },
  }, function(spec)
    assert.equals("User AstroFile", spec.event)
    assert.same({ "disable_filetype" }, spec.opts_extend)
    assert.is_true(spec.opts.check_ts)
    assert.is_false(spec.opts.ts_config.java)
    assert.is_true(spec.opts.enabled(12))
    assert.is_false(spec.opts.enabled(13))
    assert.same({ 12, 13 }, valid_buffers)

    local mappings = { n = {} }
    find_nested_spec(spec, "AstroNvim/astrocore").opts(nil, { mappings = mappings })
    assert.equals("Toggle autopairs", mappings.n["<Leader>ua"].desc)
    mappings.n["<Leader>ua"][1]()
    assert.same({ "autopairs" }, toggle_calls)
  end)
end

T["PAIR-01 forwards setup options and disables AutoPairs when the feature is off"] = function()
  for _, case in ipairs {
    { name = "enabled", feature_enabled = true, expected_calls = { "setup" } },
    { name = "disabled", feature_enabled = false, expected_calls = { "setup", "disable" } },
  } do
    local calls = {}
    unit_helpers.with_module("astronvim.plugins.configs.nvim-autopairs", {
      loaded = {
        ["nvim-autopairs"] = {
          setup = function(options)
            calls.setup_options = options
            table.insert(calls, "setup")
          end,
          disable = function() table.insert(calls, "disable") end,
        },
        astrocore = { config = { features = { autopairs = case.feature_enabled } } },
      },
    }, function(configure)
      local options = { check_ts = true }
      configure(nil, options)
      assert.equals(options, calls.setup_options)
    end)
    assert.equals(#case.expected_calls, #calls, case.name)
    for index, expected_call in ipairs(case.expected_calls) do
      assert.equals(expected_call, calls[index], case.name)
    end
  end
end

T["ESCAPE-01 declares Better Escape timing mappings and disabled defaults"] = function()
  unit_helpers.with_module("astronvim.plugins.better-escape", {}, function(spec)
    assert.equals("VeryLazy", spec.event)
    assert.equals(300, spec.opts.timeout)
    assert.is_false(spec.opts.default_mappings)
    assert.same({ k = "<Esc>", j = "<Esc>" }, spec.opts.mappings.i.j)
  end)
end

T["LAZYDEV-01 declares libraries word filters and Blink provider merge"] = function()
  unit_helpers.with_module("astronvim.plugins.lazydev", {}, function(spec)
    assert.equals("lua", spec.ft)
    assert.equals("LazyDev", spec.cmd)
    assert.same({ "library" }, spec.opts_extend)
    assert.same({
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "lazy.nvim", words = { "Lazy" } },
      { path = "astrocore", words = { "AstroCore" } },
      { path = "astrolsp", words = { "AstroLSP" } },
      { path = "astroui", words = { "AstroUI" } },
      { path = "astrotheme", words = { "AstroTheme" } },
    }, spec.opts.library)

    local blink = find_nested_spec(spec, "saghen/blink.cmp")
    assert.is_true(blink.optional)
    assert.same({ "lazydev" }, blink.opts.sources.default)
    assert.same(
      { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      blink.opts.sources.providers.lazydev
    )
  end)
end

T["TSAUTOTAG-01 activates with AstroFile and declares AstroNvim options"] = function()
  unit_helpers.with_module("astronvim.plugins.ts-autotag", {}, function(spec)
    assert.equals("windwp/nvim-ts-autotag", spec[1])
    assert.equals("User AstroFile", spec.event)
    assert.same({}, spec.opts)
  end)
end

T["TS-01 lazy loads Treesitter only when no command-line file is present"] = function()
  for _, case in ipairs {
    { name = "no file", argc = 0, expected_lazy = true },
    { name = "command-line file", argc = 1, expected_lazy = false },
  } do
    local argc_arguments = {}
    unit_helpers.with_module("astronvim.plugins.treesitter", {
      vim = {
        fn = {
          argc = function(argument)
            table.insert(argc_arguments, argument)
            return case.argc
          end,
        },
      },
    }, function(spec)
      assert.same({ -1 }, argc_arguments)
      assert.equals(case.expected_lazy, spec.lazy, case.name)
      local expected_commands = { "TSInstall", "TSInstallFromGrammar", "TSUninstall", "TSUpdate", "TSLog" }
      assert.equals(#expected_commands, #spec.cmd)
      for _, command in ipairs(expected_commands) do
        assert.is_true(contains(spec.cmd, command))
      end
      assert.equals(":TSUpdate", spec.build)
    end)
  end
end

T["TS-02 declares the main textobjects branch lazy loading and lookahead"] = function()
  unit_helpers.with_module("astronvim.plugins.treesitter-textobjects", {}, function(spec)
    assert.equals("nvim-treesitter/nvim-treesitter-textobjects", spec[1])
    assert.equals("main", spec.branch)
    assert.is_true(spec.lazy)
    assert.is_true(spec.opts.select.lookahead)
  end)
end

T["TS-01 and TSAUTOTAG-01 retain required plugin metadata and scoped defaults"] = function()
  unit_helpers.with_module("astronvim.plugins.treesitter", {
    vim = { fn = { argc = function() return 0 end } },
  }, function(spec)
    assert.equals("nvim-treesitter/nvim-treesitter", spec[1])
    assert.equals("main", spec.branch)
    assert.equals("VeryLazy", spec.event)
    assert.equals(":TSUpdate", spec.build)
    assert.same({}, spec.opts)
  end)

  unit_helpers.with_module("astronvim.plugins.ts-autotag", {}, function(spec)
    assert.equals("windwp/nvim-ts-autotag", spec[1])
    assert.equals("User AstroFile", spec.event)
    assert.same({}, spec.opts)
  end)
end

return T
