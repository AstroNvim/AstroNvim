local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then return true end
  end
  return false
end

local function find_spec(spec, name)
  for _, nested_spec in ipairs(spec.specs) do
    if nested_spec[1] == name then return nested_spec end
  end
  error("Missing nested spec: " .. name)
end

local function find_dependency(spec, name)
  for _, dependency in ipairs(spec.dependencies) do
    if dependency[1] == name then return dependency end
  end
  error("Missing dependency: " .. name)
end

local function with_dap_spec(callback)
  local calls = { inputs = {}, icons = {} }
  local function record(name, ...) table.insert(calls, { name = name, arguments = { n = select("#", ...), ... } }) end
  local dap = { repl = {} }
  for _, method in ipairs {
    "continue",
    "terminate",
    "set_breakpoint",
    "restart_frame",
    "pause",
    "toggle_breakpoint",
    "step_over",
    "step_into",
    "step_out",
    "clear_breakpoints",
    "close",
    "run_to_cursor",
  } do
    dap[method] = function(...) record("dap." .. method, ...) end
  end
  dap.repl.toggle = function(...) record("dap.repl.toggle", ...) end

  local dapui = {
    eval = function(...) record("dapui.eval", ...) end,
    toggle = function(...) record("dapui.toggle", ...) end,
  }

  return unit_helpers.with_module("astronvim.plugins.dap", {
    loaded = {
      astroui = {
        get_icon = function(name)
          table.insert(calls.icons, name)
          return "icon:" .. name
        end,
      },
      dap = dap,
      dapui = dapui,
      ["dap.ui.widgets"] = { hover = function(...) record("dap.ui.widgets.hover", ...) end },
    },
    vim = {
      tbl_get = function(value, ...)
        for _, key in ipairs { ... } do
          if type(value) ~= "table" then return nil end
          value = value[key]
        end
        return value
      end,
      ui = {
        input = function(options, callback_fn)
          table.insert(calls.inputs, { options = options, callback = callback_fn })
        end,
      },
    },
  }, function(spec) return callback(spec, calls) end)
end

local function apply_dap_mappings(spec, maps, signs)
  local options = {
    mappings = maps,
    _map_sections = { d = { desc = "Debugger" } },
    signs = signs,
  }
  find_spec(spec, "AstroNvim/astrocore").opts(nil, options)
  return options
end

local function with_dap_config(options, callback)
  options = options or {}
  local calls = { decodes = {}, notifications = {}, parser_inputs = {}, cleaner_inputs = {} }
  local vscode = {}
  local loaded = {
    ["dap.ext.vscode"] = vscode,
    astrocore = {
      notify = function(...) table.insert(calls.notifications, { ... }) end,
    },
    ["plenary.json"] = unit_helpers.remove,
    json5 = unit_helpers.remove,
  }
  local preload = {
    ["plenary.json"] = function()
      calls.plenary_requires = (calls.plenary_requires or 0) + 1
      if not options.plenary then error "plenary unavailable" end
      return options.plenary
    end,
    json5 = function()
      calls.json5_requires = (calls.json5_requires or 0) + 1
      if not options.json5 then error "json5 unavailable" end
      return options.json5
    end,
  }

  return unit_helpers.with_module("astronvim.plugins.configs.nvim-dap", {
    loaded = loaded,
    preload = preload,
    vim = {
      json = {
        decode = function(...)
          table.insert(calls.decodes, { ... })
          return options.fallback_result or { fallback = true }
        end,
      },
      log = { levels = { ERROR = "ERROR" } },
    },
  }, function(configure)
    configure()
    callback(vscode, calls)
  end)
end

local function expected_call(name, ...) return { name = name, arguments = { n = select("#", ...), ... } } end

T["DAP-01 dispatches every non-input DAP mapping through public services"] = function()
  with_dap_spec(function(spec, calls)
    local maps = { n = {}, v = {} }
    apply_dap_mappings(spec, maps, {})

    local mappings = {
      { "<F5>", "dap.continue" },
      { "<F17>", "dap.terminate" },
      { "<F29>", "dap.restart_frame" },
      { "<F6>", "dap.pause" },
      { "<F9>", "dap.toggle_breakpoint" },
      { "<F10>", "dap.step_over" },
      { "<F11>", "dap.step_into" },
      { "<F23>", "dap.step_out" },
      { "<Leader>db", "dap.toggle_breakpoint" },
      { "<Leader>dB", "dap.clear_breakpoints" },
      { "<Leader>dc", "dap.continue" },
      { "<Leader>di", "dap.step_into" },
      { "<Leader>do", "dap.step_over" },
      { "<Leader>dO", "dap.step_out" },
      { "<Leader>dq", "dap.close" },
      { "<Leader>dQ", "dap.terminate" },
      { "<Leader>dp", "dap.pause" },
      { "<Leader>dr", "dap.restart_frame" },
      { "<Leader>dR", "dap.repl.toggle" },
      { "<Leader>ds", "dap.run_to_cursor" },
    }
    for _, mapping in ipairs(mappings) do
      local call_count = #calls
      maps.n[mapping[1]][1]()
      assert.equals(call_count + 1, #calls, mapping[1])
      assert.same(expected_call(mapping[2]), calls[#calls], mapping[1])
    end

    local dapui_spec = find_dependency(spec, "rcarriga/nvim-dap-ui")
    local dapui_maps = { n = {}, v = {} }
    apply_dap_mappings(dapui_spec, dapui_maps, {})
    for _, mapping in ipairs {
      { dapui_maps.n["<Leader>du"], "dapui.toggle" },
      { dapui_maps.n["<Leader>dh"], "dap.ui.widgets.hover" },
      { dapui_maps.v["<Leader>dE"], "dapui.eval" },
    } do
      local call_count = #calls
      mapping[1][1]()
      assert.equals(call_count + 1, #calls)
      assert.same(expected_call(mapping[2]), calls[#calls])
    end

    assert.equals("Debugger: Start", maps.n["<F5>"].desc)
    assert.equals("Evaluate Selection", dapui_maps.v["<Leader>dE"].desc)
  end)
end

T["DAP-02 confirms and cancels conditional breakpoints and input evaluation"] = function()
  with_dap_spec(function(spec, calls)
    local maps = { n = {}, v = {} }
    apply_dap_mappings(spec, maps, {})

    for _, key in ipairs { "<F21>", "<Leader>dC" } do
      local call_count = #calls
      maps.n[key][1]()
      local cancelled = calls.inputs[#calls.inputs]
      assert.equals("Condition: ", cancelled.options.prompt)
      cancelled.callback(nil)
      assert.equals(call_count, #calls, key .. " cancellation")

      maps.n[key][1]()
      local confirmed = calls.inputs[#calls.inputs]
      local confirmed_call_count = #calls
      confirmed.callback "count > 2"
      assert.equals(confirmed_call_count + 1, #calls, key .. " confirmation")
      assert.same(expected_call("dap.set_breakpoint", "count > 2"), calls[#calls], key .. " confirmation")
    end

    local dapui_spec = find_dependency(spec, "rcarriga/nvim-dap-ui")
    local dapui_maps = { n = {}, v = {} }
    apply_dap_mappings(dapui_spec, dapui_maps, {})
    dapui_maps.n["<Leader>dE"][1]()
    local cancelled = calls.inputs[#calls.inputs]
    local call_count = #calls
    assert.equals("Expression: ", cancelled.options.prompt)
    cancelled.callback(nil)
    assert.equals(call_count, #calls)

    dapui_maps.n["<Leader>dE"][1]()
    local confirmed = calls.inputs[#calls.inputs]
    local confirmed_call_count = #calls
    confirmed.callback "value"
    assert.equals(confirmed_call_count + 1, #calls)
    assert.same(expected_call("dapui.eval", "value", { enter = true }), calls[#calls])
  end)
end

T["DAP-03 selects JSON5 and comment cleaning once, then reuses both parsers"] = function()
  local parser_inputs = {}
  local cleaner_inputs = {}
  with_dap_config({
    plenary = {
      json_strip_comments = function(...)
        local arguments = { n = select("#", ...), ... }
        table.insert(cleaner_inputs, arguments)
        return "clean:" .. arguments[1]
      end,
    },
    json5 = {
      parse = function(input)
        table.insert(parser_inputs, input)
        return { decoded = input }
      end,
    },
  }, function(vscode, calls)
    assert.same({ decoded = "clean:first" }, vscode.json_decode "first")
    assert.same({ decoded = "clean:second" }, vscode.json_decode "second")
    assert.same({
      { n = 2, "first", {} },
      { n = 2, "second", {} },
    }, cleaner_inputs)
    assert.same({ "clean:first", "clean:second" }, parser_inputs)
    assert.equals(1, calls.plenary_requires)
    assert.equals(1, calls.json5_requires)
    assert.equals(0, #calls.decodes)
    assert.equals(0, #calls.notifications)
  end)
end

T["DAP-03 falls back to Neovim JSON decoding when optional parsers are unavailable"] = function()
  with_dap_config({}, function(vscode, calls)
    assert.same({ fallback = true }, vscode.json_decode "{ // first\n }")
    assert.same({ fallback = true }, vscode.json_decode "{ // second\n }")
    assert.same({
      { "{ // first\n }", { skip_comments = true } },
      { "{ // second\n }", { skip_comments = true } },
    }, calls.decodes)
    assert.equals(1, calls.plenary_requires)
    assert.equals(1, calls.json5_requires)
    assert.equals(0, #calls.notifications)
  end)
end

T["DAP-04 configures DAP UI setup and lifecycle listeners"] = function()
  local calls = {}
  local listeners = {
    after = { event_initialized = {} },
    before = { event_terminated = {}, event_exited = {} },
  }
  unit_helpers.with_module("astronvim.plugins.configs.nvim-dap-ui", {
    loaded = {
      dap = { listeners = listeners },
      dapui = {
        setup = function(options) table.insert(calls, { "setup", options }) end,
        open = function() table.insert(calls, { "open" }) end,
        close = function() table.insert(calls, { "close" }) end,
      },
    },
  }, function(configure)
    local options = { layouts = { "left" } }
    configure(nil, options)
    assert.same({ "setup", options }, calls[1])
    assert.equals("function", type(listeners.after.event_initialized.dapui_config))
    assert.equals("function", type(listeners.before.event_terminated.dapui_config))
    assert.equals("function", type(listeners.before.event_exited.dapui_config))

    listeners.after.event_initialized.dapui_config()
    listeners.before.event_terminated.dapui_config()
    listeners.before.event_exited.dapui_config()
    assert.same({ { "setup", options }, { "open" }, { "close" }, { "close" } }, calls)
  end)
end

local function registration_counts(calls)
  local counts = {}
  for _, call in ipairs(calls) do
    local key = call[1] .. ":" .. call[2]
    counts[key] = (counts[key] or 0) + 1
  end
  return counts
end

T["DAP-05 registers all Blink DAP filetypes when Blink is available"] = function()
  local calls = {}
  unit_helpers.with_module("astronvim.plugins.configs.cmp-dap", {
    loaded = {
      ["blink.cmp"] = {
        add_filetype_source = function(...) table.insert(calls, { ... }) end,
      },
    },
  }, function(configure)
    configure()
    local counts = registration_counts(calls)
    for _, filetype in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
      assert.equals(1, counts[filetype .. ":dap"])
    end
  end)
end

T["DAP-05 skips unavailable Blink"] = function()
  local blink_loads = 0
  unit_helpers.with_module("astronvim.plugins.configs.cmp-dap", {
    loaded = { ["blink.cmp"] = unit_helpers.remove },
    preload = {
      ["blink.cmp"] = function()
        blink_loads = blink_loads + 1
        error "Blink unavailable"
      end,
    },
  }, function(configure)
    configure()
    assert.equals(1, blink_loads)
  end)
end

T["DAP-07b preserves named foreign DAP UI listeners across repeated setup"] = function()
  local calls = {}
  local listeners = {
    after = {
      event_initialized = {
        foreign_initialized = function() table.insert(calls, "foreign initialized") end,
      },
    },
    before = {
      event_terminated = {
        foreign_terminated = function() table.insert(calls, "foreign terminated") end,
      },
      event_exited = {
        foreign_exited = function() table.insert(calls, "foreign exited") end,
      },
    },
  }
  unit_helpers.with_module("astronvim.plugins.configs.nvim-dap-ui", {
    loaded = {
      dap = { listeners = listeners },
      dapui = {
        setup = function() end,
        open = function() table.insert(calls, "open") end,
        close = function() table.insert(calls, "close") end,
      },
    },
  }, function(configure)
    configure(nil, {})
    configure(nil, {})

    local listener_groups = {
      { listeners = listeners.after.event_initialized, foreign_key = "foreign_initialized" },
      { listeners = listeners.before.event_terminated, foreign_key = "foreign_terminated" },
      { listeners = listeners.before.event_exited, foreign_key = "foreign_exited" },
    }
    for _, listener_group in ipairs(listener_groups) do
      local listener_count = 0
      for _ in pairs(listener_group.listeners) do
        listener_count = listener_count + 1
      end
      assert.equals(2, listener_count)
      assert.equals("function", type(listener_group.listeners[listener_group.foreign_key]))
      assert.equals("function", type(listener_group.listeners.dapui_config))
    end

    listeners.after.event_initialized.foreign_initialized()
    listeners.after.event_initialized.dapui_config()
    listeners.before.event_terminated.foreign_terminated()
    listeners.before.event_terminated.dapui_config()
    listeners.before.event_exited.foreign_exited()
    listeners.before.event_exited.dapui_config()
    assert.same({ "foreign initialized", "open", "foreign terminated", "close", "foreign exited", "close" }, calls)
  end)
end

T["DAP-05 and DAP-06 declare optional completion and UI dependency boundaries"] = function()
  with_dap_spec(function(spec)
    local dapui = find_dependency(spec, "rcarriga/nvim-dap-ui")
    local cmp_dap = find_dependency(spec, "rcarriga/cmp-dap")
    local mason_dap = find_dependency(spec, "jay-babu/mason-nvim-dap.nvim")
    local nio = find_dependency(dapui, "nvim-neotest/nvim-nio")
    local blink = find_spec(cmp_dap, "saghen/blink.cmp")
    local blink_compat = find_spec(blink, "saghen/blink.compat")

    assert.is_true(spec.lazy)
    assert.is_true(dapui.lazy)
    assert.is_true(nio.lazy)
    assert.is_true(cmp_dap.lazy)
    assert.is_true(blink.optional)
    assert.is_true(blink_compat.lazy)
    assert.equals(2, #mason_dap.cmd)
    assert.is_true(contains(mason_dap.cmd, "DapInstall"))
    assert.is_true(contains(mason_dap.cmd, "DapUninstall"))
  end)
end

T["DAP-08 owns missing and existing DAP signs with exact icon lookup deltas"] = function()
  with_dap_spec(function(spec, calls)
    local maps = { n = {}, v = {} }
    local expected_signs = {
      { name = "DapBreakpoint", highlight = "DiagnosticInfo" },
      { name = "DapBreakpointCondition", highlight = "DiagnosticInfo" },
      { name = "DapBreakpointRejected", highlight = "DiagnosticError" },
      { name = "DapLogPoint", highlight = "DiagnosticInfo" },
      { name = "DapStopped", highlight = "DiagnosticWarn" },
    }
    local icon_count = #calls.icons
    local initialized = apply_dap_mappings(spec, maps, nil)
    assert.equals("table", type(initialized.signs))
    assert.equals(icon_count + 5, #calls.icons, "missing signs icon lookup delta")

    for _, sign in ipairs(expected_signs) do
      assert.equals("icon:" .. sign.name, initialized.signs[sign.name].text)
      assert.equals(sign.highlight, initialized.signs[sign.name].texthl)
    end

    for _, sign in ipairs(expected_signs) do
      local signs = {
        Keep = { text = "keep", texthl = "KeepHighlight" },
        [sign.name] = { text = "stale", texthl = "StaleHighlight", stale = true },
      }
      icon_count = #calls.icons

      apply_dap_mappings(spec, maps, signs)

      assert.equals(icon_count + 5, #calls.icons, sign.name .. " icon lookup delta")
      assert.equals("keep", signs.Keep.text)
      assert.equals("KeepHighlight", signs.Keep.texthl)
      assert.equals("icon:" .. sign.name, signs[sign.name].text)
      assert.equals(sign.highlight, signs[sign.name].texthl)
    end
  end)
end

return T
