local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function call_log(calls)
  local entries = {}
  for _, entry in ipairs(calls) do
    table.insert(entries, entry)
  end
  return entries
end

local function with_mason_lspconfig(options, callback)
  options = options or {}
  local calls = {}
  local installed_call = 0
  local scheduled = {}
  local registry = { listeners = {} }

  function registry.get_installed_package_names()
    installed_call = installed_call + 1
    table.insert(calls, "registry:get_installed:" .. installed_call)
    return (options.installed_batches and options.installed_batches[installed_call]) or options.installed or {}
  end

  function registry.refresh(refresh_callback)
    table.insert(calls, "registry:refresh")
    if options.refresh then refresh_callback(options.refresh.success, options.refresh.updated_registries) end
  end

  function registry:off(event, handler)
    table.insert(calls, "registry:off:" .. event)
    assert.equals("function", type(handler))
    local listeners = self.listeners[event] or {}
    for index = #listeners, 1, -1 do
      if listeners[index] == handler then table.remove(listeners, index) end
    end
    self.listeners[event] = listeners
  end

  function registry:on(event, handler)
    table.insert(calls, "registry:on:" .. event)
    local listeners = self.listeners[event] or {}
    table.insert(listeners, handler)
    self.listeners[event] = listeners
  end

  function registry:emit(event, value)
    for _, handler in ipairs(self.listeners[event] or {}) do
      handler(value)
    end
  end

  function registry:listener_count(event) return #(self.listeners[event] or {}) end

  local loaded = {
    astrocore = {
      is_available = function(plugin)
        if plugin == "astrolsp" then return options.astrolsp_available ~= false end
        if plugin == "mason-tool-installer.nvim" then return options.tool_installer_available == true end
        return false
      end,
    },
    astrolsp = {
      lsp_setup = function(server) table.insert(calls, "setup:" .. server) end,
    },
    ["mason-core.functional"] = {
      each = function(callback_fn, values)
        for _, value in ipairs(values) do
          callback_fn(value)
        end
      end,
    },
    ["mason-registry"] = registry,
    ["mason-lspconfig.mappings"] = {
      get_mason_map = function() return { package_to_lspconfig = options.package_to_lspconfig or {} } end,
    },
    ["mason-lspconfig"] = {
      setup = function(opts)
        calls.setup_options = opts
        table.insert(calls, "mason-lspconfig:setup")
      end,
    },
  }

  for server, config in pairs(options.server_configs or {}) do
    loaded["mason-lspconfig.lsp." .. server] = config
  end

  return unit_helpers.with_module("astronvim.plugins.configs.mason-lspconfig", {
    loaded = loaded,
    preload = options.server_preloads,
    vim = {
      lsp = {
        config = function(server, config)
          table.insert(calls, "config:" .. server)
          calls.configurations = calls.configurations or {}
          calls.configurations[server] = config
        end,
      },
      schedule_wrap = function(callback_fn)
        return function(...)
          local arguments = { n = select("#", ...), ... }
          table.insert(scheduled, function() callback_fn(unpack(arguments, 1, arguments.n)) end)
        end
      end,
    },
  }, function(configure)
    local context = {
      drain_scheduled = function()
        while #scheduled > 0 do
          local callback_fn = table.remove(scheduled, 1)
          callback_fn()
        end
      end,
      scheduled_count = function() return #scheduled end,
    }
    callback(configure, registry, calls, context)
  end)
end

T["MASON-01 appends the AstroNvim registry and selects enabled or ASCII icons"] = function()
  unit_helpers.with_module("astronvim.plugins.mason", {
    vim = { g = { icons_enabled = false } },
  }, function(spec)
    local options = { registries = { "custom:registry" } }
    spec.opts(nil, options)

    assert.same({ "custom:registry", "github:mason-org/mason-registry" }, options.registries)
    assert.same({ package_installed = "O", package_uninstalled = "X", package_pending = "0" }, options.ui.icons)
  end)

  unit_helpers.with_module("astronvim.plugins.mason", {
    vim = { g = { icons_enabled = true } },
  }, function(spec)
    local options = {}
    spec.opts(nil, options)

    assert.same({ package_installed = "✓", package_uninstalled = "✗", package_pending = "⟳" }, options.ui.icons)
  end)
end

T["MASON-02 dispatches the Mason UI mapping through the public module boundary"] = function()
  local calls = {}
  unit_helpers.with_module("astronvim.plugins.mason", {
    loaded = {
      ["mason.ui"] = { open = function() table.insert(calls, "open") end },
    },
  }, function(spec)
    local maps = { n = {} }
    spec.specs[1].opts(nil, { mappings = maps })

    assert.equals("Mason Installer", maps.n["<Leader>pm"].desc)
    maps.n["<Leader>pm"][1]()
    assert.same({ "open" }, calls)
  end)
end

T["MASON-03 configures Tool Installer and handles startup states"] = function()
  local cases = {
    {
      name = "after VimEnter",
      did_enter = 1,
      run_on_start = nil,
      cleanup_error = true,
      expected = { "setup", "cleanup", "run" },
    },
    { name = "before VimEnter", did_enter = 0, run_on_start = nil, expected = { "setup" } },
    { name = "disabled", did_enter = 1, run_on_start = false, expected = { "setup" } },
  }

  for _, case in ipairs(cases) do
    local calls = {}
    unit_helpers.with_module("astronvim.plugins.configs.mason-tool-installer", {
      replace_vim = { v = true },
      loaded = {
        ["mason-tool-installer"] = {
          setup = function(opts)
            calls.options = opts
            table.insert(calls, "setup")
          end,
          run_on_start = function() table.insert(calls, "run") end,
        },
      },
      vim = {
        v = { vim_did_enter = case.did_enter },
        api = {
          nvim_del_augroup_by_name = function(name)
            assert.equals("mti_start", name)
            table.insert(calls, "cleanup")
            if case.cleanup_error then error "missing augroup" end
          end,
        },
      },
    }, function(configure)
      local options = { run_on_start = case.run_on_start }
      configure(nil, options)
      assert.equals(options, calls.options)
    end)
    assert.same(case.expected, call_log(calls), case.name)
  end
end

T["MASON-04 gives Tool Installer ownership of LSP installation requests"] = function()
  for _, case in ipairs {
    { available = true, expected = nil },
    { available = false, expected = { "lua-language-server" } },
  } do
    with_mason_lspconfig(
      { tool_installer_available = case.available, astrolsp_available = false },
      function(configure, _, calls)
        local options = { ensure_installed = { "lua-language-server" } }
        configure(nil, options)

        if case.available then
          assert.is_nil(options.ensure_installed)
        else
          assert.same(case.expected, options.ensure_installed)
        end
        assert.equals(options, calls.setup_options)
      end
    )
  end
end

T["MASON-05 maps package strings and objects in callback order without duplicate server setup"] = function()
  with_mason_lspconfig({
    installed = { "lua-language-server" },
    refresh = { success = true, updated_registries = {} },
    package_to_lspconfig = {
      ["lua-language-server"] = "lua_ls",
      ["typescript-language-server"] = "ts_ls",
    },
    server_configs = { lua_ls = { setting = "lua" }, ts_ls = { setting = "typescript" } },
  }, function(configure, registry, calls, context)
    local options = {}
    configure(nil, options)

    assert.same({
      "registry:get_installed:1",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
    }, call_log(calls))
    assert.equals(2, context.scheduled_count())
    assert.equals(1, registry:listener_count "package:install:success")
    assert.equals(false, options.automatic_enable)
    context.drain_scheduled()

    configure(nil, {})
    assert.equals(2, context.scheduled_count())
    assert.equals(1, registry:listener_count "package:install:success")
    context.drain_scheduled()

    registry:emit("package:install:success", { name = "typescript-language-server" })
    registry:emit("package:install:success", "lua-language-server")
    assert.equals(2, context.scheduled_count())
    context.drain_scheduled()

    assert.same({
      "registry:get_installed:1",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
      "config:lua_ls",
      "setup:lua_ls",
      "registry:get_installed:2",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
      "config:ts_ls",
      "setup:ts_ls",
    }, call_log(calls))
  end)
end

T["MASON-06 handles unmapped and optional server configuration branches"] = function()
  with_mason_lspconfig({
    installed = { "unknown", "missing", "failing", "available" },
    refresh = { success = true, updated_registries = {} },
    package_to_lspconfig = {
      missing = "missing_server",
      failing = "failing_server",
      available = "available_server",
    },
    server_configs = { available_server = { setting = true } },
    server_preloads = {
      ["mason-lspconfig.lsp.failing_server"] = function() error "server configuration failed" end,
    },
  }, function(configure, _, calls, context)
    configure(nil, {})

    assert.same({
      "registry:get_installed:1",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
    }, call_log(calls))
    context.drain_scheduled()
    assert.same({
      "registry:get_installed:1",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
      "setup:missing_server",
      "setup:failing_server",
      "config:available_server",
      "setup:available_server",
    }, call_log(calls))
  end)
end

T["MASON-06 refreshes only successful nonempty registries and installs event packages after re-registration"] = function()
  local refresh_cases = {
    {
      refresh = { success = true, updated_registries = { "primary" } },
      installed_batches = { {}, { "after-refresh" } },
      expected = {
        "registry:get_installed:1",
        "registry:refresh",
        "registry:off:package:install:success",
        "registry:on:package:install:success",
        "mason-lspconfig:setup",
        "registry:get_installed:2",
        "config:after_refresh",
        "setup:after_refresh",
      },
    },
    {
      refresh = { success = true, updated_registries = {} },
      installed_batches = { {} },
      expected = {
        "registry:get_installed:1",
        "registry:refresh",
        "registry:off:package:install:success",
        "registry:on:package:install:success",
        "mason-lspconfig:setup",
      },
    },
    {
      refresh = { success = false, updated_registries = { "primary" } },
      installed_batches = { {} },
      expected = {
        "registry:get_installed:1",
        "registry:refresh",
        "registry:off:package:install:success",
        "registry:on:package:install:success",
        "mason-lspconfig:setup",
      },
    },
  }

  for _, case in ipairs(refresh_cases) do
    with_mason_lspconfig({
      refresh = case.refresh,
      installed_batches = case.installed_batches,
      package_to_lspconfig = { ["after-refresh"] = "after_refresh", ["event-package"] = "event_server" },
      server_configs = { after_refresh = {}, event_server = {} },
    }, function(configure, registry, calls, context)
      configure(nil, {})
      assert.same({
        "registry:get_installed:1",
        "registry:refresh",
        "registry:off:package:install:success",
        "registry:on:package:install:success",
        "mason-lspconfig:setup",
      }, call_log(calls))
      context.drain_scheduled()
      assert.same(case.expected, call_log(calls))

      if case == refresh_cases[1] then
        registry:emit("package:install:success", "event-package")
        assert.equals(1, context.scheduled_count())
        context.drain_scheduled()
        assert.same({ "config:event_server", "setup:event_server" }, { calls[9], calls[10] })
      end
    end)
  end
end

T["MASON-06 delegates without AstroLSP and respects automatic_enable false"] = function()
  with_mason_lspconfig({ astrolsp_available = false }, function(configure, _, calls)
    local options = { automatic_enable = true }
    configure(nil, options)

    assert.equals(true, options.automatic_enable)
    assert.same({ "mason-lspconfig:setup" }, call_log(calls))
  end)

  with_mason_lspconfig({ automatic_enable = false }, function(configure, _, calls)
    local options = { automatic_enable = false }
    configure(nil, options)

    assert.equals(false, options.automatic_enable)
    assert.same({ "mason-lspconfig:setup" }, call_log(calls))
  end)
end

T["MASON-07 delegates null-ls and DAP setup while Tool Installer owns installation"] = function()
  local adapters = {
    { module = "astronvim.plugins.configs.mason-null-ls", dependency = "mason-null-ls" },
    { module = "astronvim.plugins.configs.mason-nvim-dap", dependency = "mason-nvim-dap" },
  }

  for _, adapter in ipairs(adapters) do
    for _, tool_installer_available in ipairs { false, true } do
      local calls = {}
      local availability_calls = {}
      unit_helpers.with_module(adapter.module, {
        loaded = {
          astrocore = {
            is_available = function(plugin)
              table.insert(availability_calls, plugin)
              return tool_installer_available
            end,
          },
          [adapter.dependency] = {
            setup = function(options) table.insert(calls, options) end,
          },
        },
      }, function(configure)
        local options = { ensure_installed = { "tool" }, handlers = {} }
        configure(nil, options)

        assert.same({ "mason-tool-installer.nvim" }, availability_calls)
        assert.equals(1, #calls)
        assert.equals(options, calls[1])
        if tool_installer_available then
          assert.is_nil(options.ensure_installed)
        else
          assert.same({ "tool" }, options.ensure_installed)
        end
      end)
    end
  end
end

T["MASON-08 declares none-ls trigger commands and attach ownership"] = function()
  unit_helpers.with_module("astronvim.plugins.none-ls", {}, function(spec)
    local dependency = spec.dependencies[1]

    assert.equals("null-ls", spec.main)
    assert.equals("User AstroFile", spec.event)
    assert.same({ "NullLsInstall", "NullLsUninstall" }, dependency.cmd)
    assert.is_nil(spec.opts.on_attach)
  end)
end

T["MASON-08 exposes NullLsInfo only when the command exists"] = function()
  for _, exists in ipairs { 0, 2 } do
    unit_helpers.with_module("astronvim.plugins.none-ls", {
      vim = { fn = { exists = function(command) return command == ":NullLsInfo" and exists or 0 end } },
    }, function(spec)
      local maps = { n = {} }
      spec.specs[2].opts(nil, { mappings = maps })
      local mapping = maps.n["<Leader>lI"]

      assert.equals("<Cmd>NullLsInfo<CR>", mapping[1])
      assert.equals("Null-ls information", mapping.desc)
      assert.equals(exists > 0, mapping.cond())
    end)
  end
end

T["MASON-10 continues AstroLSP setup when an optional server config cannot load"] = function()
  with_mason_lspconfig({
    installed = { "lua-language-server" },
    package_to_lspconfig = { ["lua-language-server"] = "lua_ls" },
    server_preloads = {
      ["mason-lspconfig.lsp.lua_ls"] = function() error "optional config failed" end,
    },
  }, function(configure, _, calls, context)
    local options = { ensure_installed = { "lua-language-server" } }
    configure(nil, options)
    context.drain_scheduled()

    assert.same({
      "registry:get_installed:1",
      "registry:refresh",
      "registry:off:package:install:success",
      "registry:on:package:install:success",
      "mason-lspconfig:setup",
      "setup:lua_ls",
    }, call_log(calls))
    assert.is_false(options.automatic_enable)
  end)
end

T["MASON-08 adds only the NullLsInfo mapping and preserves caller mappings"] = function()
  unit_helpers.with_module("astronvim.plugins.none-ls", {
    vim = { fn = { exists = function() return 1 end } },
  }, function(spec)
    local mappings = {
      n = { ["<Leader>xx"] = { "<Cmd>Caller<CR>", desc = "Caller mapping" } },
      i = { ["<C-x>"] = { "caller" } },
    }
    local options = { mappings = mappings, features = { formatting = true } }

    spec.specs[2].opts(nil, options)
    spec.specs[2].opts(nil, options)

    assert.same({ "<Cmd>Caller<CR>", desc = "Caller mapping" }, mappings.n["<Leader>xx"])
    assert.same({ "caller" }, mappings.i["<C-x>"])
    assert.same({ "<Cmd>NullLsInfo<CR>", desc = "Null-ls information" }, {
      mappings.n["<Leader>lI"][1],
      desc = mappings.n["<Leader>lI"].desc,
    })
    assert.equals(true, options.features.formatting)
  end)
end

return T
