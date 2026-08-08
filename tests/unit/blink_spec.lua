local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_mini_icons(value, callback)
  local previous = _G.MiniIcons
  _G.MiniIcons = value
  local ok, result = xpcall(callback, debug.traceback)
  _G.MiniIcons = previous
  if not ok then error(result, 0) end
  return result
end

local function with_blink(options, callback)
  options = options or {}
  local calls = { capability_arguments = {}, capability_calls = 0 }
  local cursor = options.cursor or { line = 1, column = 0, text = "" }
  local mode = options.mode or { value = "i" }
  local astrocore = {
    config = { features = { cmp = options.cmp_enabled ~= false } },
    is_available = function(name)
      table.insert(calls.available, name)
      return options.available and options.available[name] or false
    end,
    plugin_opts = function(name)
      calls.plugin_opts = name
      return { signature = { enabled = options.signature_enabled == true } }
    end,
  }
  calls.available = {}

  local loaded = {
    astrocore = astrocore,
    ["blink.cmp"] = {
      get_lsp_capabilities = function(capabilities)
        calls.capability_calls = calls.capability_calls + 1
        calls.capability_arguments[calls.capability_calls] = { value = capabilities }
        return options.augmented_capabilities or { inherited = capabilities, augmented = true }
      end,
    },
  }
  local preload = {}
  for name, module in pairs(options.preload or {}) do
    preload[name] = module
  end
  for name, module in pairs(options.loaded or {}) do
    loaded[name] = module
    if module == unit_helpers.remove and preload[name] == nil then preload[name] = unit_helpers.remove end
  end

  return unit_helpers.with_module("astronvim.plugins.blink", {
    loaded = loaded,
    preload = preload,
    replace_vim = { b = true, bo = true, g = true },
    vim = {
      F = { if_nil = function(value, fallback) return value == nil and fallback or value end },
      api = {
        nvim_win_get_cursor = function() return { cursor.line, cursor.column } end,
        nvim_buf_get_lines = function() return { cursor.text } end,
        nvim_get_mode = function() return { mode = mode.value } end,
      },
      b = { completion = options.completion },
      bo = { buftype = options.buftype or "", filetype = options.filetype or "" },
      g = { icons_enabled = options.icons_enabled },
      tbl_contains = function(values, expected)
        for _, value in ipairs(values) do
          if value == expected then return true end
        end
        return false
      end,
      tbl_get = function(value, ...)
        for _, key in ipairs { ... } do
          if type(value) ~= "table" then return nil end
          value = value[key]
        end
        return value
      end,
    },
  }, function(spec) return callback(spec, calls, cursor, mode) end)
end

local function find_spec(spec, name)
  for _, nested_spec in ipairs(spec.specs) do
    if nested_spec[1] == name then return nested_spec end
  end
  error("Missing nested spec: " .. name)
end

local function kind_component(spec) return spec.opts.completion.menu.draw.components.kind_icon end

T["BLINK-01 enables completion only for supported buffers"] = function()
  with_blink(nil, function(spec) assert.is_true(spec.opts.enabled()) end)

  with_blink({ completion = false }, function(spec) assert.is_false(spec.opts.enabled()) end)

  with_blink(
    { buftype = "prompt", filetype = "TelescopePrompt" },
    function(spec) assert.is_false(spec.opts.enabled()) end
  )

  with_blink({
    buftype = "prompt",
    filetype = "dap-repl",
    available = { ["cmp-dap"] = true },
  }, function(spec) assert.is_true(spec.opts.enabled()) end)
end

T["BLINK-02 augments nil and existing LSP configuration without replacing capability input"] = function()
  with_blink({ signature_enabled = true }, function(spec, calls)
    local astrolsp_opts = {}
    find_spec(spec, "AstroNvim/astrolsp").opts(nil, astrolsp_opts)

    assert.equals(1, calls.capability_calls)
    assert.is_nil(calls.capability_arguments[1].value)
    assert.equals(true, astrolsp_opts.config["*"].capabilities.augmented)
    assert.equals(false, astrolsp_opts.features.signature_help)
    assert.equals("blink.cmp", calls.plugin_opts)
  end)

  local existing_capabilities = { textDocument = { completion = {} } }
  local augmented_capabilities = { textDocument = { completion = { dynamicRegistration = true } } }
  with_blink({ augmented_capabilities = augmented_capabilities }, function(spec, calls)
    local astrolsp_opts = {
      config = { ["*"] = { capabilities = existing_capabilities } },
      features = { codelens = true },
    }
    find_spec(spec, "AstroNvim/astrolsp").opts(nil, astrolsp_opts)

    assert.equals(1, calls.capability_calls)
    assert.is_true(calls.capability_arguments[1].value == existing_capabilities)
    assert.is_true(astrolsp_opts.config["*"].capabilities == augmented_capabilities)
    assert.equals(true, astrolsp_opts.features.codelens)
    assert.is_nil(astrolsp_opts.features.signature_help)
  end)
end

T["BLINK-03 keeps selected completion declarations and dispatches Tab callbacks"] = function()
  local cursor = { line = 1, column = 0, text = "" }
  local mode = { value = "i" }
  with_blink({ cursor = cursor, mode = mode }, function(spec)
    local opts = spec.opts
    assert.same({ "lsp", "path", "snippets", "buffer" }, opts.sources.default)
    assert.same({ "show", "show_documentation", "hide_documentation" }, opts.keymap["<C-Space>"])
    assert.equals("prefer_rust", opts.fuzzy.implementation)
    assert.is_false(opts.completion.list.selection.preselect)
    assert.is_true(opts.completion.list.selection.auto_insert)
    assert.is_true(opts.completion.menu.auto_show { mode = "insert" })
    assert.is_false(opts.completion.menu.auto_show { mode = "cmdline" })
    assert.is_true(opts.completion.accept.auto_brackets.enabled)
    assert.is_true(opts.completion.documentation.auto_show)
    assert.equals(0, opts.completion.documentation.auto_show_delay_ms)
    assert.equals("Normal:NormalFloat,FloatBorder:FloatBorder", opts.signature.window.winhighlight)
    assert.same({ "hide", "fallback" }, opts.cmdline.keymap["<End>"])
    assert.is_false(opts.cmdline.completion.ghost_text.enabled)

    assert.equals(4, #opts.keymap["<Tab>"])
    assert.equals("select_next", opts.keymap["<Tab>"][1])
    assert.equals("snippet_forward", opts.keymap["<Tab>"][2])
    assert.equals("function", type(opts.keymap["<Tab>"][3]))
    assert.equals("fallback", opts.keymap["<Tab>"][4])
    assert.equals(4, #opts.keymap["<S-Tab>"])
    assert.equals("select_prev", opts.keymap["<S-Tab>"][1])
    assert.equals("snippet_backward", opts.keymap["<S-Tab>"][2])
    assert.equals("function", type(opts.keymap["<S-Tab>"][3]))
    assert.equals("fallback", opts.keymap["<S-Tab>"][4])

    local shown = 0
    local cmp = { show = function() shown = shown + 1 end }
    local tab = opts.keymap["<Tab>"][3]
    local shift_tab = opts.keymap["<S-Tab>"][3]

    mode.value = "c"
    tab(cmp)
    shift_tab(cmp)
    mode.value = "i"
    shift_tab(cmp)

    assert.equals(2, shown)
  end)
end

T["BLINK-04 detects words before the cursor at stable boundaries"] = function()
  local cursor = { line = 1, column = 0, text = "text" }
  with_blink({ cursor = cursor }, function(spec)
    local shown = 0
    local tab = spec.opts.keymap["<Tab>"][3]
    local cmp = { show = function() shown = shown + 1 end }

    tab(cmp)
    cursor.column = 2
    cursor.text = "ab"
    tab(cmp)
    cursor.text = "a "
    tab(cmp)

    assert.equals(1, shown)
  end)
end

T["BLINK-05 selects and caches Mini Icons for LSP Path and Snippet kinds"] = function()
  with_mini_icons(true, function()
    local requests = 0
    local highlight_requests = 0
    local mini_icons = {
      get = function(category, value) return category .. ":" .. value, category .. "Highlight" end,
    }
    with_blink({
      loaded = {
        ["mini.icons"] = unit_helpers.remove,
        ["lspkind"] = unit_helpers.remove,
        ["nvim-highlight-colors"] = unit_helpers.remove,
        ["blink.cmp.types"] = { CompletionItemKind = { Color = 16, [16] = "Color" } },
      },
      preload = {
        ["mini.icons"] = function()
          requests = requests + 1
          return mini_icons
        end,
        ["nvim-highlight-colors"] = function()
          highlight_requests = highlight_requests + 1
          return { format = function() end }
        end,
      },
    }, function(spec)
      local component = kind_component(spec)
      local function render(ctx) return component.text(ctx), component.highlight(ctx) end

      local lsp = {
        kind = "Function",
        kind_icon = "?",
        icon_gap = " ",
        item = { source_name = "LSP" },
      }
      assert.equals("lsp:Function ", component.text(lsp))
      package.loaded["mini.icons"] = nil
      package.loaded["nvim-highlight-colors"] = nil
      assert.equals("lspHighlight", component.highlight(lsp))
      assert.equals(1, requests)
      assert.equals(1, highlight_requests)

      local file = {
        kind = "File",
        kind_icon = "?",
        icon_gap = "",
        label = "main.lua",
        item = { source_name = "Path" },
      }
      assert.same({ "file:main.lua", "fileHighlight" }, { render(file) })

      local folder = {
        kind = "Folder",
        kind_icon = "?",
        icon_gap = "",
        label = "lua",
        item = { source_name = "Path" },
      }
      assert.same({ "directory:lua", "directoryHighlight" }, { render(folder) })

      local snippet = {
        kind = "Snippet",
        kind_icon = "?",
        icon_gap = "",
        item = { source_name = "Snippets" },
      }
      assert.same({ "lsp:snippet", "lspHighlight" }, { render(snippet) })
      assert.equals(1, requests)
      assert.equals(1, highlight_requests)
    end)
  end)
end

T["BLINK-05 falls back from unavailable Mini Icons and handles no provider"] = function()
  with_mini_icons(nil, function()
    with_blink({
      loaded = {
        ["mini.icons"] = unit_helpers.remove,
        ["lspkind"] = { symbol_map = { Function = "L", Snippet = "S" } },
        ["nvim-highlight-colors"] = unit_helpers.remove,
      },
    }, function(spec)
      local component = kind_component(spec)
      local lsp = { kind = "Function", kind_icon = "?", icon_gap = "", item = { source_name = "LSP" } }
      local snippet = { kind = "Snippet", kind_icon = "?", icon_gap = "", item = { source_name = "Snippets" } }
      assert.equals("L", component.text(lsp))
      assert.equals("S", component.text(snippet))
    end)

    local mini_gets = 0
    with_blink({
      loaded = {
        ["mini.icons"] = { get = function() mini_gets = mini_gets + 1 end },
        ["lspkind"] = { symbol_map = { Function = "K" } },
        ["nvim-highlight-colors"] = unit_helpers.remove,
      },
    }, function(spec)
      local ctx = { kind = "Function", kind_icon = "?", icon_gap = "", item = { source_name = "LSP" } }
      assert.equals("K", kind_component(spec).text(ctx))
      assert.equals(0, mini_gets)
    end)
  end)

  with_mini_icons(true, function()
    local mini_gets = 0
    with_blink({
      loaded = {
        ["mini.icons"] = {
          get = function()
            mini_gets = mini_gets + 1
            return nil, nil
          end,
        },
        ["lspkind"] = { symbol_map = { Function = "K" } },
        ["nvim-highlight-colors"] = unit_helpers.remove,
      },
    }, function(spec)
      local ctx = { kind = "Function", kind_icon = "?", icon_gap = "", item = { source_name = "LSP" } }
      assert.equals("?", kind_component(spec).text(ctx))
      assert.equals(1, mini_gets)
    end)
  end)

  with_mini_icons(nil, function()
    with_blink({
      loaded = {
        ["mini.icons"] = unit_helpers.remove,
        ["lspkind"] = unit_helpers.remove,
        ["nvim-highlight-colors"] = unit_helpers.remove,
      },
    }, function(spec)
      local ctx =
        { kind = "Function", kind_icon = "?", icon_gap = " ", kind_hl = "Base", item = { source_name = "LSP" } }
      assert.same({ "? ", "Base" }, { kind_component(spec).text(ctx), kind_component(spec).highlight(ctx) })
    end)
  end)
end

T["BLINK-05 formats documented colors and preserves HexColor highlights"] = function()
  local kinds = { Color = 16, [16] = "Color" }
  local format_calls = {}
  with_mini_icons(nil, function()
    with_blink({
      loaded = {
        ["mini.icons"] = unit_helpers.remove,
        ["lspkind"] = unit_helpers.remove,
        ["blink.cmp.types"] = { CompletionItemKind = kinds },
        ["nvim-highlight-colors"] = {
          format = function(documentation, options)
            table.insert(format_calls, { documentation = documentation, options = options })
            return { abbr = "rgb", abbr_hl_group = "ColorHighlight" }
          end,
        },
      },
    }, function(spec)
      local component = kind_component(spec)
      local color = {
        kind_icon = "?",
        icon_gap = "",
        kind_hl = "Base",
        item = { kind = 16, documentation = "#ff0000", source_name = "Buffer" },
      }
      assert.equals("rgb", component.text(color))
      assert.equals("ColorHighlight", color.kind_hl)

      local undocumented = {
        kind_icon = "?",
        icon_gap = "",
        kind_hl = "Base",
        item = { kind = 16, source_name = "Buffer" },
      }
      assert.equals("?", component.text(undocumented))
      assert.equals("Base", undocumented.kind_hl)
      assert.same({ { documentation = "#ff0000", options = { kind = "Color" } } }, format_calls)
    end)
  end)

  with_mini_icons(true, function()
    with_blink({
      loaded = {
        ["mini.icons"] = { get = function() return "I", "LspHighlight" end },
        ["nvim-highlight-colors"] = unit_helpers.remove,
      },
    }, function(spec)
      local ctx = {
        kind = "Function",
        kind_icon = "?",
        icon_gap = "",
        kind_hl = "HexColorFF00FF",
        item = { kind = 1, source_name = "LSP" },
      }
      assert.same({ "I", "HexColorFF00FF" }, { kind_component(spec).text(ctx), kind_component(spec).highlight(ctx) })
    end)
  end)
end

T["BLINK-06 applies ASCII icons and dispatches completion toggles"] = function()
  local toggle_calls = {}
  with_blink({
    icons_enabled = false,
    loaded = {
      ["astrocore.toggles"] = {
        buffer_cmp = function() table.insert(toggle_calls, "buffer_cmp") end,
        cmp = function() table.insert(toggle_calls, "cmp") end,
      },
    },
  }, function(spec)
    local blink_opts = {}
    find_spec(spec, "saghen/blink.cmp").opts(nil, blink_opts)
    local icons = blink_opts.appearance.kind_icons

    assert.same({
      Text = "T",
      Method = "M",
      Function = "F",
      Constructor = "C",
      Field = "F",
      Variable = "V",
      Property = "P",
      Class = "C",
      Interface = "I",
      Struct = "S",
      Module = "M",
      Unit = "U",
      Value = "V",
      Enum = "E",
      EnumMember = "E",
      Keyword = "K",
      Constant = "C",
      Snippet = "S",
      Color = "C",
      File = "F",
      Reference = "R",
      Folder = "F",
      Event = "E",
      Operator = "O",
      TypeParameter = "T",
    }, icons)
    for _, icon in pairs(icons) do
      assert.is_true(icon:match "^[%w]$" ~= nil)
    end

    local mappings = { n = {} }
    local core_opts = { mappings = mappings }
    find_spec(spec, "AstroNvim/astrocore").opts(nil, core_opts)
    mappings.n["<Leader>uc"][1]()
    mappings.n["<Leader>uC"][1]()

    assert.same({ "buffer_cmp", "cmp" }, toggle_calls)
    assert.equals("Toggle autocompletion (buffer)", mappings.n["<Leader>uc"].desc)
    assert.equals("Toggle autocompletion (global)", mappings.n["<Leader>uC"].desc)
  end)
end

return T
