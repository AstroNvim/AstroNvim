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
    ---@type AstroCoreOpts
    opts = {
      features = {
        max_file = { size = 1024 * 100, lines = 10000 }, -- set global limits for large files
        autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
        highlighturl = true, -- highlight URLs by default
        notifications = true, -- disable notifications
      },
      rooter = {
        detector = { "lsp", { ".git", "_darcs", ".hg", ".bzr", ".svn", "lua", "Makefile", "package.json" } },
        ignore = {
          servers = {},
          dirs = {},
        },
        autochdir = true,
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
    },
  },
}
