return {
  "AstroNvim/astrolsp",
  lazy = true,
  opts_extend = { "servers" },
  opts = function(_, opts)
    return require("astrocore").extend_tbl(opts, {
      features = {
        codelens = true,
        inlay_hints = false,
        semantic_tokens = true,
      },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      ---@diagnostic disable-next-line: missing-fields
      config = { lua_ls = { settings = { Lua = { workspace = { checkThirdParty = false } } } } },
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
      lsp_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true }),
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          { border = "rounded", silent = true, focusable = false }
        ),
      },
      servers = {},
      on_attach = nil,
    } --[[@as AstroLSPOpts]])
  end,
  specs = {
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.event_handlers then opts.event_handlers = {} end
        vim.list_extend(opts.event_handlers, {
          {
            event = "before_file_move",
            id = "astrolsp_willmove",
            handler = function(args)
              require("astrolsp.file_operations").willRenameFiles { from = args.source, to = args.destination }
            end,
          },
          {
            event = "before_file_rename",
            id = "astrolsp_willrename",
            handler = function(args)
              require("astrolsp.file_operations").willRenameFiles { from = args.source, to = args.destination }
            end,
          },
          {
            event = "before_file_delete",
            id = "astrolsp_willdelete",
            handler = function(args) require("astrolsp.file_operations").willDeleteFiles(args) end,
          },
          {
            event = "before_file_add",
            id = "astrolsp_willcreate",
            handler = function(args) require("astrolsp.file_operations").willCreateFiles(args) end,
          },
          {
            event = "file_moved",
            id = "astrolsp_didmove",
            handler = function(args)
              require("astrolsp.file_operations").didRenameFiles { from = args.source, to = args.destination }
            end,
          },
          {
            event = "file_renamed",
            id = "astrolsp_didrename",
            handler = function(args)
              require("astrolsp.file_operations").didRenameFiles { from = args.source, to = args.destination }
            end,
          },
          {
            event = "file_deleted",
            id = "astrolsp_diddelete",
            handler = function(args) require("astrolsp.file_operations").didDeleteFiles(args) end,
          },
          {
            event = "file_added",
            id = "astrolsp_didcreate",
            handler = function(args) require("astrolsp.file_operations").didCreateFiles(args) end,
          },
        })
      end,
    },
  },
}
