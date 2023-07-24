return {
  "AstroNvim/astrocore",
  dependencies = { "AstroNvim/astroui" },
  lazy = false,
  priority = 10000,
  opts = {
    features = {
      max_file = { size = 1024 * 100, lines = 10000 }, -- set global limits for large files
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      highlighturl = true, -- highlight URLs by default
      notifications = true, -- disable notifications
    },
  },
}
