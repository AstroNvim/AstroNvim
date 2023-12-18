local astronvim = require "astronvim"
astronvim.init()

return {
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
