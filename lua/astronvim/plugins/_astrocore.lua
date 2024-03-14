local astronvim = require "astronvim"
astronvim.init()

return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  { "AstroNvim/AstroNvim", priority = 10000, lazy = false },
  { import = "astronvim.lazy_snapshot", cond = astronvim.config.pin_plugins },
  {
    "AstroNvim/astrocore",
    dependencies = { "AstroNvim/astroui" },
    lazy = false,
    priority = 10000,
    opts = function(_, opts)
      local get_icon = require("astroui").get_icon
      return require("astrocore").extend_tbl(opts, {
        features = {
          large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files
          autopairs = true, -- enable autopairs at start
          cmp = true, -- enable completion at start
          diagnostics_mode = 3, -- enable diagnostics by default
          highlighturl = true, -- highlight URLs by default
          notifications = true, -- disable notifications
        },
        diagnostics = {
          virtual_text = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = get_icon "DiagnosticError",
              [vim.diagnostic.severity.HINT] = get_icon "DiagnosticHint",
              [vim.diagnostic.severity.WARN] = get_icon "DiagnosticWarn",
              [vim.diagnostic.severity.INFO] = get_icon "DiagnosticInfo",
            },
          },
          update_in_insert = true,
          underline = true,
          severity_sort = true,
          float = {
            focused = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        },
        rooter = {
          detector = { "lsp", { ".git", "_darcs", ".hg", ".bzr", ".svn" }, { "lua", "MakeFile", "package.json" } },
          ignore = {
            servers = {},
            dirs = {},
          },
          autochdir = false,
          scope = "global",
          notify = false,
        },
        sessions = {
          autosave = { last = true, cwd = true },
          ignore = {
            dirs = {},
            filetypes = { "gitcommit", "gitrebase" },
            buftypes = {},
          },
        },
      } --[[@as AstroCoreOpts]])
    end,
  },
}
