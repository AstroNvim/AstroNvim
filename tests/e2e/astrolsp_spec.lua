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
  child.lua [[require("lazy").load { plugins = { "astrolsp" } }]]
end

T["LSP-07 forwards Format and format-on-save options through a fake formatter"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    vim.cmd.enew()
    local bufnr = vim.api.nvim_get_current_buf()
    local astrolsp = require "astrolsp"
    local client = {
      id = 901,
      name = "fake-formatter",
      server_capabilities = {},
      supports_method = function(_, method, requested_bufnr)
        return method == "textDocument/formatting" and requested_bufnr == bufnr
      end,
    }
    local calls = {}
    local format_opts = {
      async = true,
      timeout_ms = 87,
      filter = function(format_client) return format_client.name == "fake-formatter" end,
    }

    astrolsp.format_opts = format_opts
    vim.lsp.get_client_by_id = function(id) return id == client.id and client or nil end
    vim.lsp.get_clients = function(options)
      if not options or not options.bufnr or options.bufnr == bufnr then return { client } end
      return {}
    end
    vim.lsp.buf.format = function(options)
      table.insert(calls, {
        async = options.async,
        timeout_ms = options.timeout_ms,
        bufnr = options.bufnr,
        filter_is_forwarded = options.filter == format_opts.filter,
      })
    end
    vim.api.nvim_exec_autocmds("LspAttach", { buffer = bufnr, data = { client_id = client.id } })

    vim.cmd.Format()

    local function format_on_save(buffer_autoformat, global_autoformat)
      vim.b[bufnr].autoformat = buffer_autoformat
      astrolsp.config.formatting.format_on_save.enabled = global_autoformat
      vim.api.nvim_exec_autocmds("BufWritePre", { buffer = bufnr })
      return #calls
    end

    local after_buffer_disabled = format_on_save(false, true)
    local after_buffer_enabled = format_on_save(true, false)
    local after_global_disabled = format_on_save(nil, false)
    local after_global_enabled = format_on_save(nil, true)

    return {
      command_options = calls[1],
      after_buffer_disabled = after_buffer_disabled,
      after_buffer_enabled = after_buffer_enabled,
      after_global_disabled = after_global_disabled,
      after_global_enabled = after_global_enabled,
      autoformat_options = calls[2],
      final_autoformat_options = calls[3],
      buffer = bufnr,
    }
  end)()]]

  assert.same({ async = true, timeout_ms = 87, filter_is_forwarded = true }, state.command_options)
  assert.equals(1, state.after_buffer_disabled)
  assert.equals(2, state.after_buffer_enabled)
  assert.equals(2, state.after_global_disabled)
  assert.equals(3, state.after_global_enabled)
  assert.same(
    { async = true, timeout_ms = 87, bufnr = state.buffer, filter_is_forwarded = true },
    state.autoformat_options
  )
  assert.same(
    { async = true, timeout_ms = 87, bufnr = state.buffer, filter_is_forwarded = true },
    state.final_autoformat_options
  )
end

T["LSP-10 gives a fake none-ls client one AstroLSP attach path"] = function()
  start_ready_child()

  local state = child.lua_get [[(function()
    vim.cmd.enew()
    local bufnr = vim.api.nvim_get_current_buf()
    local astrolsp = require "astrolsp"
    local client = {
      id = 902,
      name = "none-ls",
      server_capabilities = {},
      supports_method = function() return false end,
    }
    local user_on_attach_calls = {}
    local configured_on_attach = astrolsp.config.on_attach
    local user_on_attach = function(attached_client, attached_bufnr)
      table.insert(user_on_attach_calls, { client = attached_client.name, buffer = attached_bufnr })
    end
    local none_ls_spec = require "astronvim.plugins.none-ls"
    local none_ls_astrolsp
    for _, spec in ipairs(none_ls_spec.specs) do
      if spec[1] == "AstroNvim/astrolsp" then
        none_ls_astrolsp = spec
        break
      end
    end
    local integration_options = { mappings = { n = {} }, on_attach = user_on_attach }
    none_ls_astrolsp.opts(nil, integration_options)

    vim.lsp.get_client_by_id = function(id) return id == client.id and client or nil end
    vim.lsp.get_clients = function() return {} end
    astrolsp.config.on_attach = integration_options.on_attach
    vim.api.nvim_exec_autocmds("LspAttach", { buffer = bufnr, data = { client_id = client.id } })

    return {
      configured_on_attach_is_nil = configured_on_attach == nil,
      integration_preserved_on_attach = integration_options.on_attach == user_on_attach,
      null_ls_mapping = integration_options.mappings.n["<Leader>lI"][1],
      user_on_attach_calls = user_on_attach_calls,
      attached_client = astrolsp.attached_clients[client.id] == client,
      astro_attach_handlers = #vim.api.nvim_get_autocmds { group = "astrolsp_on_attach", event = "LspAttach" },
      buffer = bufnr,
    }
  end)()]]

  assert.is_true(state.configured_on_attach_is_nil)
  assert.is_true(state.integration_preserved_on_attach)
  assert.equals("<Cmd>NullLsInfo<CR>", state.null_ls_mapping)
  assert.same({ { client = "none-ls", buffer = state.buffer } }, state.user_on_attach_calls)
  assert.is_true(state.attached_client)
  assert.equals(1, state.astro_attach_handlers)
end

return T
