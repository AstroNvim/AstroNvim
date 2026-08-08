local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then return true end
  end
  return false
end

local function with_astrolsp_spec(options, callback)
  options = options or {}
  local calls = {}
  local metadata = {
    capability_calls = 0,
    capabilities = options.capabilities or { sentinel = "generated capabilities" },
    range_queries = {},
    version_calls = 0,
    version_value = options.version_value or { sentinel = "current version" },
  }
  local buffers = options.buffers or {}
  local valid_buffers = options.valid_buffers or {}
  local names = options.names or {}
  local operations = options.operations or {}
  local version = setmetatable({
    range = function(query)
      table.insert(metadata.range_queries, query)
      return {
        has = function(_, current_version)
          metadata.range_version = current_version
          return options.version_in_codelens_disabled_range == true
        end,
      }
    end,
  }, {
    __call = function()
      metadata.version_calls = metadata.version_calls + 1
      return metadata.version_value
    end,
  })

  local file_operations = {}
  for _, name in ipairs {
    "willCreateFiles",
    "didCreateFiles",
    "willDeleteFiles",
    "didDeleteFiles",
    "willRenameFiles",
    "didRenameFiles",
  } do
    file_operations[name] = function(argument)
      table.insert(calls, { operation = name, argument = argument })
      if operations[name] then return operations[name](argument) end
    end
  end

  return unit_helpers.with_module("astronvim.plugins._astrolsp", {
    loaded = {
      ["astrocore.buffer"] = {
        is_valid = function(bufnr) return valid_buffers[bufnr] == true end,
      },
      ["astrolsp.file_operations"] = file_operations,
      ["neo-tree.events"] = options.neo_tree_events or {
        BEFORE_FILE_ADD = "before_file_add",
        FILE_ADDED = "file_added",
        BEFORE_FILE_DELETE = "before_file_delete",
        FILE_DELETED = "file_deleted",
        BEFORE_FILE_MOVE = "before_file_move",
        BEFORE_FILE_RENAME = "before_file_rename",
        FILE_MOVED = "file_moved",
        FILE_RENAMED = "file_renamed",
      },
    },
    replace_vim = { b = true, version = true },
    vim = {
      api = {
        nvim_buf_get_name = function(bufnr) return names[bufnr] end,
      },
      b = buffers,
      lsp = {
        protocol = {
          make_client_capabilities = function()
            metadata.capability_calls = metadata.capability_calls + 1
            return metadata.capabilities
          end,
        },
      },
      uv = {
        fs_stat = options.fs_stat or function() return nil end,
      },
      version = version,
    },
  }, function(spec) return callback(spec, calls, buffers, metadata) end)
end

local function file_events(spec) return spec.specs[1].opts.autocmds.astrolsp_createfiles_events end

T["LSP-02 reports valid new and URI buffers around a write"] = function()
  with_astrolsp_spec({
    buffers = { [1] = {}, [2] = {}, [3] = {} },
    valid_buffers = { [1] = true, [2] = false, [3] = true },
    names = {
      [1] = "/workspace/new.lua",
      [2] = "/workspace/invalid.lua",
      [3] = "zipfile:///workspace/archive.zip::new.lua",
    },
    fs_stat = function() return nil end,
  }, function(spec, calls, buffers)
    local will_create, did_create = unpack(file_events(spec))

    will_create.callback { buf = 1 }
    assert.equals("/workspace/new.lua", buffers[1].new_file)
    did_create.callback { buf = 1 }
    assert.equals(false, buffers[1].new_file)

    buffers[2].new_file = "stale"
    will_create.callback { buf = 2 }
    did_create.callback { buf = 2 }
    assert.equals(false, buffers[2].new_file)

    will_create.callback { buf = 3 }
    did_create.callback { buf = 3 }
    assert.equals(false, buffers[3].new_file)

    assert.same({
      { operation = "willCreateFiles", argument = "/workspace/new.lua" },
      { operation = "didCreateFiles", argument = "/workspace/new.lua" },
      { operation = "willCreateFiles", argument = "zipfile:///workspace/archive.zip::new.lua" },
      { operation = "didCreateFiles", argument = "zipfile:///workspace/archive.zip::new.lua" },
    }, calls)
  end)
end

T["LSP-02 skips existing buffers and preserves fs_stat failure behavior"] = function()
  with_astrolsp_spec({
    buffers = { [1] = {}, [2] = { new_file = "stale" } },
    valid_buffers = { [1] = true, [2] = true },
    names = { [1] = "/workspace/existing.lua", [2] = "/workspace/stat-error.lua" },
    fs_stat = function(path)
      if path == "/workspace/existing.lua" then return { type = "file" } end
      error "fs_stat failed"
    end,
  }, function(spec, calls, buffers)
    local will_create = file_events(spec)[1]

    will_create.callback { buf = 1 }
    assert.equals(false, buffers[1].new_file)
    assert.same({}, calls)

    local ok, err = pcall(will_create.callback, { buf = 2 })
    assert.is_false(ok)
    assert.is_true(tostring(err):find("fs_stat failed", 1, true) ~= nil)
    assert.equals(false, buffers[2].new_file)
    assert.same({}, calls)
  end)
end

T["LSP-03 clears state before a didCreateFiles callback error"] = function()
  with_astrolsp_spec({
    buffers = { [1] = {} },
    valid_buffers = { [1] = true },
    names = { [1] = "/workspace/did-error.lua" },
    operations = {
      didCreateFiles = function() error "didCreateFiles failed" end,
    },
  }, function(spec, _, buffers)
    local will_create, did_create = unpack(file_events(spec))
    will_create.callback { buf = 1 }

    local ok, err = pcall(did_create.callback, { buf = 1 })
    assert.is_false(ok)
    assert.is_true(tostring(err):find("didCreateFiles failed", 1, true) ~= nil)
    assert.equals(false, buffers[1].new_file)
  end)
end

local function neo_tree_handlers(spec)
  local handlers = {}
  local options = { event_handlers = {} }
  spec.specs[2].opts(nil, options)
  for _, handler in ipairs(options.event_handlers) do
    local key = handler.id .. "_" .. handler.event
    assert.is_nil(handlers[key], "Duplicate Neo-tree handler: " .. key)
    handlers[key] = handler.handler
  end
  return handlers, #options.event_handlers
end

T["LSP-04 registers Neo-tree adapters with stable IDs and event variants"] = function()
  with_astrolsp_spec({
    fs_stat = function(path)
      return path == "/workspace/source-directory" and { type = "directory" }
        or path == "/workspace/destination-directory" and { type = "directory" }
        or nil
    end,
  }, function(spec)
    local handlers, handler_count = neo_tree_handlers(spec)

    assert.equals(8, handler_count)
    assert.equals("function", type(handlers.astrolsp_willCreateFiles_before_file_add))
    assert.equals("function", type(handlers.astrolsp_didCreateFiles_file_added))
    assert.equals("function", type(handlers.astrolsp_willDeleteFiles_before_file_delete))
    assert.equals("function", type(handlers.astrolsp_didDeleteFiles_file_deleted))
    assert.equals("function", type(handlers.astrolsp_willRenameFiles_before_file_move))
    assert.equals("function", type(handlers.astrolsp_willRenameFiles_before_file_rename))
    assert.equals("function", type(handlers.astrolsp_didRenameFiles_file_moved))
    assert.equals("function", type(handlers.astrolsp_didRenameFiles_file_renamed))
  end)
end

T["LSP-04 adapts Neo-tree create delete move and rename state"] = function()
  local deleted = true
  with_astrolsp_spec({
    fs_stat = function(path)
      if path == "/workspace/deleted-directory" and not deleted then return { type = "directory" } end
      if path == "/workspace/source-directory" then return { type = "directory" } end
      if path == "/workspace/destination-directory" then return { type = "directory" } end
      return nil
    end,
  }, function(spec, calls)
    local handlers = neo_tree_handlers(spec)

    handlers.astrolsp_willCreateFiles_before_file_add "/workspace/created.lua"
    handlers.astrolsp_didCreateFiles_file_added "/workspace/created.lua"

    deleted = false
    handlers.astrolsp_willDeleteFiles_before_file_delete "/workspace/deleted-directory"
    deleted = true
    handlers.astrolsp_didDeleteFiles_file_deleted "/workspace/deleted-directory"
    handlers.astrolsp_didDeleteFiles_file_deleted "/workspace/deleted-directory"

    handlers.astrolsp_willRenameFiles_before_file_move {
      source = "/workspace/source-directory",
      destination = "/workspace/destination-file",
    }
    handlers.astrolsp_willRenameFiles_before_file_rename {
      source = "/workspace/missing-source",
      destination = "/workspace/destination-directory",
    }
    handlers.astrolsp_didRenameFiles_file_moved {
      source = "/workspace/missing-source",
      destination = "/workspace/destination-file",
    }
    handlers.astrolsp_didRenameFiles_file_renamed {
      source = "/workspace/missing-source",
      destination = "/workspace/destination-directory",
    }

    assert.same({
      { operation = "willCreateFiles", argument = "/workspace/created.lua" },
      { operation = "didCreateFiles", argument = "/workspace/created.lua" },
      {
        operation = "willDeleteFiles",
        argument = { path = "/workspace/deleted-directory", kind = "folder" },
      },
      {
        operation = "didDeleteFiles",
        argument = { path = "/workspace/deleted-directory", kind = "folder" },
      },
      {
        operation = "didDeleteFiles",
        argument = { path = "/workspace/deleted-directory", kind = "file" },
      },
      {
        operation = "willRenameFiles",
        argument = { from = "/workspace/source-directory", to = "/workspace/destination-file", kind = "folder" },
      },
      {
        operation = "willRenameFiles",
        argument = { from = "/workspace/missing-source", to = "/workspace/destination-directory", kind = "folder" },
      },
      {
        operation = "didRenameFiles",
        argument = { from = "/workspace/missing-source", to = "/workspace/destination-file", kind = "file" },
      },
      {
        operation = "didRenameFiles",
        argument = { from = "/workspace/missing-source", to = "/workspace/destination-directory", kind = "folder" },
      },
    }, calls)
  end)
end

T["LSP-06 permits formatting only for supported enabled clients"] = function()
  local config = { formatting = { disabled = {} } }
  unit_helpers.with_module("astronvim.plugins._astrolsp_autocmds", {
    loaded = {
      astrolsp = {
        config = config,
        format_opts = {},
      },
    },
  }, function(spec)
    local command = spec.opts.commands.Format
    local autoformat = spec.opts.autocmds.lsp_auto_format
    local function client(name, supported)
      return {
        name = name,
        supports_method = function(_, method, bufnr)
          return supported and method == "textDocument/formatting" and bufnr == 12
        end,
      }
    end

    assert.is_true(command.cond(client("formatter", true), 12))
    assert.is_true(autoformat.cond(client("formatter", true), 12))
    assert.is_false(command.cond(client("formatter", false), 12))

    config.formatting.disabled = true
    assert.is_false(command.cond(client("formatter", true), 12))
    assert.is_false(autoformat.cond(client("formatter", true), 12))

    config.formatting.disabled = { "formatter" }
    assert.is_false(command.cond(client("formatter", true), 12))
    assert.is_true(command.cond(client("other", true), 12))
  end)
end

T["LSP-01 declares AstroLSP feature, file operation, and wildcard capability defaults"] = function()
  with_astrolsp_spec({}, function(spec, _, _, metadata)
    local options = spec.opts

    assert.same({ codelens = true, inlay_hints = false, semantic_tokens = true }, options.features)
    assert.equals(10000, options.file_operations.timeout)
    assert.same({
      didCreate = true,
      didDelete = true,
      didRename = true,
      willCreate = true,
      willDelete = true,
      willRename = true,
    }, options.file_operations.operations)
    assert.is_true(options.config["*"].capabilities == metadata.capabilities)
    assert.equals(1, metadata.capability_calls)
    assert.same({ "0.12.0 - 0.12.1" }, metadata.range_queries)
    assert.equals(1, metadata.version_calls)
    assert.is_true(metadata.range_version == metadata.version_value)
    assert.same({}, options.handlers)
    assert.same({}, options.servers)
    assert.is_nil(options.on_attach)
  end)

  with_astrolsp_spec({ version_in_codelens_disabled_range = true }, function(spec, _, _, metadata)
    assert.is_false(spec.opts.features.codelens)
    assert.same({ "0.12.0 - 0.12.1" }, metadata.range_queries)
    assert.equals(1, metadata.version_calls)
    assert.is_true(metadata.range_version == metadata.version_value)
  end)
end

local function with_astrolsp_autocmd_spec(options, callback)
  options = options or {}
  local codelens = options.codelens or {}
  return unit_helpers.with_module("astronvim.plugins._astrolsp_autocmds", {
    loaded = {
      astrolsp = options.astrolsp or {
        config = { features = { codelens = true }, formatting = { disabled = {} } },
        format_opts = {},
      },
    },
    vim = {
      lsp = { codelens = codelens, buf = options.lsp_buf or {} },
    },
    replace_vim = { lsp = true },
  }, callback)
end

T["LSP-09 registers legacy CodeLens refresh only without native enable"] = function()
  local refreshes = {}
  with_astrolsp_autocmd_spec({
    codelens = {
      refresh = function(options) table.insert(refreshes, options) end,
    },
  }, function(spec)
    local autocmd = spec.opts.autocmds.lsp_codelens_refresh
    assert.equals("textDocument/codeLens", autocmd.cond)
    assert.equals(3, #autocmd[1].event)
    for _, event in ipairs { "TextChanged", "InsertLeave", "BufEnter" } do
      assert.is_true(contains(autocmd[1].event, event))
    end

    autocmd[1].callback { buf = 24 }
    assert.same({ { bufnr = 24 } }, refreshes)
  end)

  with_astrolsp_autocmd_spec({
    astrolsp = { config = { features = { codelens = false }, formatting = { disabled = {} } }, format_opts = {} },
    codelens = {
      refresh = function(options) table.insert(refreshes, options) end,
    },
  }, function(spec)
    spec.opts.autocmds.lsp_codelens_refresh[1].callback { buf = 25 }
    assert.same({ { bufnr = 24 } }, refreshes)
  end)

  with_astrolsp_autocmd_spec({
    codelens = { enable = function() end },
  }, function(spec) assert.is_false(spec.opts.autocmds.lsp_codelens_refresh) end)
end

local function with_astrolsp_mappings(options, callback)
  options = options or {}
  local calls = {}
  local maps
  local function record(name)
    return function(...)
      local arguments = { n = select("#", ...), ... }
      table.insert(calls, { name = name, arguments = arguments })
    end
  end
  local function empty_map_table() return { n = {}, v = {}, x = {} } end

  return unit_helpers.with_module("astronvim.plugins._astrolsp_mappings", {
    loaded = {
      astrocore = {
        empty_map_table = empty_map_table,
        extend_tbl = function(_, additions)
          maps = additions
          return additions
        end,
      },
      astroui = { get_icon = function() return "LSP" end },
      astrolsp = { format_opts = options.format_opts or { async = true } },
      ["astrolsp.toggles"] = {
        codelens = record "toggle_codelens",
        buffer_autoformat = record "toggle_buffer_autoformat",
        autoformat = record "toggle_autoformat",
        signature_help = record "toggle_signature_help",
        buffer_inlay_hints = record "toggle_buffer_inlay_hints",
        inlay_hints = record "toggle_inlay_hints",
        buffer_semantic_tokens = record "toggle_buffer_semantic_tokens",
      },
    },
    vim = {
      tbl_contains = function(values, value)
        for _, candidate in ipairs(values) do
          if candidate == value then return true end
        end
        return false
      end,
      lsp = {
        buf = {
          code_action = record "code_action",
          declaration = record "declaration",
          definition = record "definition",
          format = record "format",
          references = record "references",
          rename = record "rename",
          signature_help = record "signature_help",
          type_definition = record "type_definition",
          workspace_symbol = record "workspace_symbol",
          workspace_diagnostics = options.workspace_diagnostics and record "workspace_diagnostics" or nil,
        },
        codelens = {
          enable = options.native_codelens and record "codelens_enable" or nil,
          refresh = record "codelens_refresh",
          run = record "codelens_run",
        },
      },
    },
    replace_vim = { lsp = true },
  }, function(spec)
    local mapping_options = options.mapping_options
      or { formatting = { disabled = options.disabled or {} }, mappings = {} }
    spec.opts(nil, mapping_options)
    callback(maps, calls, mapping_options)
  end)
end

local function conditional_mapping_inventory(maps)
  local inventory = {}
  for mode, mode_maps in pairs(maps) do
    for lhs, mapping in pairs(mode_maps) do
      if mapping.cond then inventory[mode .. ":" .. lhs] = mapping.cond end
    end
  end
  return inventory
end

T["LSPMAP-01 inventories conditional mappings and their required methods"] = function()
  with_astrolsp_mappings({ workspace_diagnostics = true }, function(maps)
    local inventory = conditional_mapping_inventory(maps)
    assert.same({
      ["n:<Leader>la"] = "textDocument/codeAction",
      ["x:<Leader>la"] = "textDocument/codeAction",
      ["n:<Leader>lA"] = "textDocument/codeAction",
      ["n:<Leader>ll"] = "textDocument/codeLens",
      ["n:<Leader>lL"] = "textDocument/codeLens",
      ["n:<Leader>uL"] = "textDocument/codeLens",
      ["n:gD"] = "textDocument/declaration",
      ["n:gd"] = "textDocument/definition",
      ["n:<Leader>lf"] = inventory["n:<Leader>lf"],
      ["v:<Leader>lf"] = inventory["v:<Leader>lf"],
      ["n:<Leader>uf"] = inventory["n:<Leader>uf"],
      ["n:<Leader>uF"] = inventory["n:<Leader>uF"],
      ["n:<Leader>u?"] = "textDocument/signatureHelp",
      ["n:<Leader>uh"] = "textDocument/inlayHint",
      ["n:<Leader>uH"] = "textDocument/inlayHint",
      ["n:<Leader>lR"] = "textDocument/references",
      ["n:<Leader>lr"] = "textDocument/rename",
      ["n:<Leader>lh"] = "textDocument/signatureHelp",
      ["n:gK"] = "textDocument/signatureHelp",
      ["n:gy"] = "textDocument/typeDefinition",
      ["n:<Leader>lG"] = "workspace/symbol",
      ["n:<Leader>lw"] = "workspace/diagnostic",
      ["n:<Leader>uY"] = inventory["n:<Leader>uY"],
    }, inventory)

    local supported = {}
    local client = {
      name = "formatter",
      supports_method = function(_, method, bufnr)
        table.insert(supported, { method = method, bufnr = bufnr })
        return true
      end,
    }
    assert.is_true(inventory["n:<Leader>lf"](client, 31))
    assert.is_true(inventory["v:<Leader>lf"](client, 32))
    assert.is_true(inventory["n:<Leader>uY"](client, 33))
    assert.is_true(inventory["n:<Leader>uf"](client, 34))
    assert.is_true(inventory["n:<Leader>uF"](client, 35))
    assert.same({
      { method = "textDocument/formatting", bufnr = 31 },
      { method = "textDocument/rangeFormatting", bufnr = 32 },
      { method = "textDocument/semanticTokens/full", bufnr = 33 },
      { method = "textDocument/formatting", bufnr = 34 },
      { method = "textDocument/formatting", bufnr = 35 },
    }, supported)
  end)

  for _, disabled in ipairs { true, { "formatter" } } do
    with_astrolsp_mappings({ disabled = disabled }, function(maps)
      local client = {
        name = "formatter",
        supports_method = function() return true end,
      }
      assert.is_false(maps.n["<Leader>uf"].cond(client, 41))
      assert.is_false(maps.n["<Leader>uF"].cond(client, 42))
    end)
  end
end

local function expected_call(name, ...) return { name = name, arguments = { n = select("#", ...), ... } } end

T["LSPMAP-02 dispatches mapping calls with stable arguments"] = function()
  with_astrolsp_mappings({ native_codelens = true, workspace_diagnostics = true }, function(maps, calls)
    for _, mapping in ipairs {
      maps.n["<Leader>la"],
      maps.x["<Leader>la"],
      maps.n["<Leader>lA"],
      maps.n["<Leader>lf"],
      maps.v["<Leader>lf"],
      maps.n["<Leader>ll"],
      maps.n["<Leader>lL"],
      maps.n["<Leader>uL"],
      maps.n["gD"],
      maps.n.gd,
      maps.n["<Leader>uf"],
      maps.n["<Leader>uF"],
      maps.n["<Leader>u?"],
      maps.n["<Leader>uh"],
      maps.n["<Leader>uH"],
      maps.n["<Leader>lR"],
      maps.n["<Leader>lr"],
      maps.n["<Leader>lh"],
      maps.n.gK,
      maps.n.gy,
      maps.n["<Leader>lG"],
      maps.n["<Leader>lw"],
      maps.n["<Leader>uY"],
    } do
      mapping[1]()
    end

    assert.same({
      expected_call "code_action",
      expected_call "code_action",
      expected_call("code_action", { context = { only = { "source" }, diagnostics = {} } }),
      expected_call("format", { async = true }),
      expected_call("format", { async = true }),
      expected_call("codelens_enable", true),
      expected_call "codelens_run",
      expected_call "toggle_codelens",
      expected_call "declaration",
      expected_call "definition",
      expected_call "toggle_buffer_autoformat",
      expected_call "toggle_autoformat",
      expected_call "toggle_signature_help",
      expected_call "toggle_buffer_inlay_hints",
      expected_call "toggle_inlay_hints",
      expected_call "references",
      expected_call "rename",
      expected_call "signature_help",
      expected_call "signature_help",
      expected_call "type_definition",
      expected_call "workspace_symbol",
      expected_call "workspace_diagnostics",
      expected_call "toggle_buffer_semantic_tokens",
    }, calls)
  end)

  with_astrolsp_mappings({}, function(maps, calls)
    assert.is_nil(maps.n["<Leader>lw"])
    maps.n["<Leader>ll"][1]()
    assert.same({ expected_call "codelens_refresh" }, calls)
  end)
end

T["LSP-13 preserves valid format options for enabled formatting clients"] = function()
  local format_calls = {}
  local format_opts = { async = true, timeout_ms = 1000 }
  local format_opts_snapshot = { async = true, timeout_ms = 1000 }
  local client = {
    name = "formatter",
    supports_method = function(_, method, bufnr) return method == "textDocument/formatting" and bufnr == 14 end,
  }

  with_astrolsp_autocmd_spec({
    astrolsp = { config = { features = {}, formatting = { disabled = {} } }, format_opts = format_opts },
    lsp_buf = { format = function(options) table.insert(format_calls, options) end },
  }, function(spec)
    local command = spec.opts.commands.Format
    local autoformat = spec.opts.autocmds.lsp_auto_format

    assert.is_true(command.cond(client, 14))
    assert.is_true(autoformat.cond(client, 14))
    command[1]()
  end)

  assert.same(format_opts_snapshot, format_opts)
  assert.same(format_opts_snapshot, format_calls[1])
end

T["LSPMAP-04 keeps range formatting limited to range-capable clients"] = function()
  with_astrolsp_mappings({}, function(maps)
    local methods = {}
    local client = {
      name = "range-only",
      supports_method = function(_, method, bufnr)
        table.insert(methods, { method = method, bufnr = bufnr })
        return method == "textDocument/rangeFormatting"
      end,
    }
    assert.is_false(maps.n["<Leader>lf"].cond(client, 28))
    assert.is_true(maps.v["<Leader>lf"].cond(client, 28))
    assert.same({
      { method = "textDocument/formatting", bufnr = 28 },
      { method = "textDocument/rangeFormatting", bufnr = 28 },
    }, methods)
  end)
end

T["LSPCONFIG-01 preserves command compatibility metadata without owning options"] = function()
  for _, case in ipairs {
    { exists = 0, command = { "LspInfo", "LspLog", "LspStart" } },
    { exists = 1, command = { "LspInfo", "LspLog", "LspStart" } },
    { exists = 2, command = nil },
    { exists = 3, command = { "LspInfo", "LspLog", "LspStart" } },
  } do
    unit_helpers.with_module("astronvim.plugins.lspconfig", {
      vim = { fn = { exists = function() return case.exists end } },
    }, function(spec)
      assert.equals("neovim/nvim-lspconfig", spec[1])
      assert.equals("User AstroFile", spec.event)
      assert.same(case.command, spec.cmd)
      assert.is_nil(spec.opts)
      assert.is_nil(spec.config)
    end)
  end
end

T["LSPMAP-03 exposes legacy LSP commands only without native :lsp"] = function()
  for _, case in ipairs {
    { native = false, expected = { "LspInfo", "LspLog", "LspStart" } },
    { native = true, expected = nil },
  } do
    local exists_calls = {}
    unit_helpers.with_module("astronvim.plugins.lspconfig", {
      vim = {
        fn = {
          exists = function(command)
            table.insert(exists_calls, command)
            return case.native and 2 or 0
          end,
        },
      },
    }, function(spec)
      assert.same(case.expected, spec.cmd)
      assert.same({ ":lsp" }, exists_calls)
    end)
  end
end

T["LSP-03 repeats new writes and clears state after failed write callbacks"] = function()
  with_astrolsp_spec({
    buffers = { [1] = {}, [2] = {}, [3] = {} },
    valid_buffers = { [1] = true, [2] = true, [3] = true },
    names = {
      [1] = "/workspace/repeated.lua",
      [2] = "/workspace/failed-write.lua",
      [3] = "/workspace/will-error.lua",
    },
    operations = {
      willCreateFiles = function(path)
        if path == "/workspace/will-error.lua" then error "willCreateFiles failed" end
      end,
    },
  }, function(spec, calls, buffers)
    local will_create, did_create = unpack(file_events(spec))

    for _ = 1, 2 do
      will_create.callback { buf = 1 }
      did_create.callback { buf = 1 }
    end
    assert.equals(false, buffers[1].new_file)

    will_create.callback { buf = 2 }
    assert.equals("/workspace/failed-write.lua", buffers[2].new_file)

    local ok, err = pcall(will_create.callback, { buf = 3 })
    assert.is_false(ok)
    assert.is_true(tostring(err):find("willCreateFiles failed", 1, true) ~= nil)
    assert.equals(false, buffers[3].new_file)

    did_create.callback { buf = 3 }

    assert.same({
      { operation = "willCreateFiles", argument = "/workspace/repeated.lua" },
      { operation = "didCreateFiles", argument = "/workspace/repeated.lua" },
      { operation = "willCreateFiles", argument = "/workspace/repeated.lua" },
      { operation = "didCreateFiles", argument = "/workspace/repeated.lua" },
      { operation = "willCreateFiles", argument = "/workspace/failed-write.lua" },
      { operation = "willCreateFiles", argument = "/workspace/will-error.lua" },
    }, calls)
  end)
end

T["LSP-11 clears failed file creation state"] = function()
  with_astrolsp_spec({
    buffers = { [1] = {} },
    valid_buffers = { [1] = true },
    names = { [1] = "/workspace/failing.lua" },
    fs_stat = function() return nil end,
    operations = {
      willCreateFiles = function() error "will create failure" end,
    },
  }, function(spec, calls, buffers)
    local will_create, did_create = unpack(file_events(spec))
    local ok, error_message = pcall(will_create.callback, { buf = 1 })

    assert.is_false(ok)
    assert.is_true(tostring(error_message):find("will create failure", 1, true) ~= nil)
    assert.is_false(buffers[1].new_file)

    did_create.callback { buf = 1 }
    assert.same({ { operation = "willCreateFiles", argument = "/workspace/failing.lua" } }, calls)
  end)
end

T["LSP-11 keeps Neo-tree ownership stable"] = function()
  local stats = {
    ["/workspace/first"] = { type = "directory" },
    ["/workspace/second"] = { type = "file" },
  }
  with_astrolsp_spec({ fs_stat = function(path) return stats[path] end }, function(spec, calls)
    local neo_tree = spec.specs[2]
    local options = { event_handlers = { { id = "caller_handler", event = "caller" } } }
    neo_tree.opts(nil, options)
    neo_tree.opts(nil, options)

    local handlers = {}
    for _, handler in ipairs(options.event_handlers) do
      local key = handler.id .. "_" .. handler.event
      assert.is_nil(handlers[key], "Duplicate Neo-tree handler: " .. key)
      handlers[key] = handler.handler
    end
    assert.equals(9, #options.event_handlers)

    handlers.astrolsp_willDeleteFiles_before_file_delete "/workspace/first"
    handlers.astrolsp_willDeleteFiles_before_file_delete "/workspace/second"

    handlers.astrolsp_didDeleteFiles_file_deleted "/workspace/second"
    stats["/workspace/first"] = nil
    handlers.astrolsp_didDeleteFiles_file_deleted "/workspace/first"

    assert.same({
      { operation = "willDeleteFiles", argument = { path = "/workspace/first", kind = "folder" } },
      { operation = "willDeleteFiles", argument = { path = "/workspace/second", kind = "file" } },
      { operation = "didDeleteFiles", argument = { path = "/workspace/second", kind = "file" } },
      { operation = "didDeleteFiles", argument = { path = "/workspace/first", kind = "folder" } },
    }, calls)
  end)
end

T["LSP-12 keeps signature-help state scoped to its buffer lifecycle"] = function()
  local current = { buffer = 1, line = "" }
  local buffer_vars = {
    [1] = {
      signature_help = true,
      signature_help_triggerCharacters = { ["("] = true },
      signature_help_retriggerCharacters = { [","] = true },
    },
    [2] = {
      signature_help = true,
      signature_help_triggerCharacters = { ["("] = true },
      signature_help_retriggerCharacters = { [","] = true },
    },
  }
  local signature_calls = {}

  unit_helpers.with_module("astronvim.plugins._astrolsp_autocmds", {
    loaded = {
      astrolsp = {
        config = { features = { codelens = true, signature_help = true }, formatting = { disabled = {} } },
        format_opts = {},
      },
    },
    replace_vim = { b = true, lsp = true },
    vim = {
      b = buffer_vars,
      api = {
        nvim_win_get_cursor = function() return { 1, #current.line } end,
        nvim_get_current_line = function() return current.line end,
      },
      lsp = {
        codelens = { enable = function() end },
        buf = {
          signature_help = function()
            if current.buffer == 1 and current.line == "error(" then error "signature callback failure" end
            table.insert(signature_calls, current.buffer)
          end,
        },
      },
    },
  }, function(spec)
    local signature_help = spec.opts.autocmds.lsp_auto_signature_help
    local changed = signature_help[1].callback
    local function cleanup_callback(event)
      for _, autocmd in ipairs(signature_help) do
        local events = type(autocmd.event) == "table" and autocmd.event or { autocmd.event }
        if contains(events, event) then return autocmd.callback end
      end
    end
    local insert_leave = assert(cleanup_callback "InsertLeave")
    local buffer_delete = assert(cleanup_callback "BufDelete")
    local function change(buffer, line)
      current.buffer = buffer
      current.line = line
      changed { buf = buffer }
    end

    change(1, "call(")
    buffer_vars[2].signature_help = false
    change(2, "disabled(")
    change(1, "call( ")

    buffer_vars[2].signature_help = true
    change(2, "switch(")
    insert_leave { buf = 1 }
    change(2, "switch( ")
    buffer_delete { buf = 1 }
    change(2, "switch(  ")

    local ok, error_message = pcall(change, 1, "error(")
    assert.is_false(ok)
    assert.is_true(tostring(error_message):find("signature callback failure", 1, true) ~= nil)
    change(2, "switch(   ")
  end)

  assert.same({ 1, 1, 2, 2, 2, 2 }, signature_calls)
end

return T
