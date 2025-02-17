return {
  "AstroNvim/astrolsp",
  lazy = true,
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    ---@diagnostic disable-next-line: missing-fields
    config = {},
    defaults = {
      hover = {
        border = "rounded",
        silent = true,
      },
      signature_help = {
        border = "rounded",
        silent = true,
        focusable = false,
      },
    },
    file_operations = {
      timeout = 10000,
      operations = {
        didCreate = true,
        didDelete = true,
        didRename = true,
        willCreate = true,
        willDelete = true,
        willRename = true,
      },
    },
    flags = {},
    formatting = { format_on_save = { enabled = true }, disabled = {} },
    handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
    servers = {},
    on_attach = nil,
  },
  specs = {
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.event_handlers then opts.event_handlers = {} end
        local operations = {
          willRenameFiles = {
            events = { "before_file_move", "before_file_rename" },
            args = function(args) return { from = args.source, to = args.destination } end,
          },
          willDeleteFiles = { events = { "before_file_delete" } },
          willCreateFiles = { events = { "before_file_add" } },
          didRenameFiles = {
            events = { "file_moved", "file_renamed" },
            args = function(args) return { from = args.source, to = args.destination } end,
          },
          didDeleteFiles = { events = { "file_deleted" } },
          didCreateFiles = { events = { "file_added" } },
        }
        for operation, config in pairs(operations) do
          for _, event in ipairs(config.events) do
            table.insert(opts.event_handlers, {
              event = event,
              id = "astrolsp_" .. operation,
              handler = function(args)
                require("astrolsp.file_operations")[module](config.args and config.args(args) or args)
              end,
            })
          end
        end
      end,
    },
  },
}
