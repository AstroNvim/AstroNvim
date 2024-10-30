return {
  "AstroNvim/astrolsp",
  lazy = true,
  opts = function(_, opts)
    local lsp_handlers
    if vim.fn.has "nvim-0.11" == 0 then
      lsp_handlers = {
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          { border = "rounded", silent = true, focusable = false }
        ),
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true }),
      }
    end

    return require("astrocore").extend_tbl(opts, {
      features = {
        codelens = true,
        inlay_hints = false,
        semantic_tokens = true,
      },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      ---@diagnostic disable-next-line: missing-fields
      config = {},
      file_operations = {
        timeout = 10000,
        operations = {
          didCreate = false,
          didDelete = false,
          didRename = false,
          willCreate = false,
          willDelete = false,
          willRename = false,
        },
      },
      flags = {},
      formatting = { format_on_save = { enabled = true }, disabled = {} },
      handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
      lsp_handlers = lsp_handlers,
      servers = {},
      on_attach = nil,
    } --[[@as AstroLSPOpts]])
  end,
  specs = {
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = function(_, opts)
        local events = require "neo-tree.events"
        if not opts.event_handlers then opts.event_handlers = {} end
        local move_args = function(args) return { from = args.source, to = args.destination } end
        local operations = {
          willCreateFiles = { events = { events.BEFORE_FILE_ADD } },
          didCreateFiles = { events = { events.FILE_ADDED } },
          willDeleteFiles = { events = { events.BEFORE_FILE_DELETE } },
          didDeleteFiles = { events = { events.FILE_DELETED } },
          willRenameFiles = { events = { events.BEFORE_FILE_MOVE, events.BEFORE_FILE_RENAME }, args = move_args },
          didRenameFiles = { events = { events.FILE_MOVED, events.FILE_RENAMED }, args = move_args },
        }
        for operation, config in pairs(operations) do
          for _, event in ipairs(config.events) do
            table.insert(opts.event_handlers, {
              event = event,
              id = "astrolsp_" .. operation,
              handler = function(args)
                require("astrolsp.file_operations")[operation](config.args and config.args(args) or args)
              end,
            })
          end
        end
      end,
    },
  },
}
