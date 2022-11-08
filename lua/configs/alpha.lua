require("alpha").setup(astronvim.user_plugin_opts("plugins.alpha", {
  layout = {
    { type = "padding", val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) } },
    {
      type = "text",
      val = astronvim.user_plugin_opts("header", {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }, false),
      opts = { position = "center", hl = "DashboardHeader" },
    },
    { type = "padding", val = 5 },
    {
      type = "group",
      val = {
        astronvim.alpha_button("LDR f f", "  Find File  "),
        astronvim.alpha_button("LDR f o", "  Recents  "),
        astronvim.alpha_button("LDR f w", "  Find Word  "),
        astronvim.alpha_button("LDR f n", "  New File  "),
        astronvim.alpha_button("LDR f m", "  Bookmarks  "),
        astronvim.alpha_button("LDR S l", "  Last Session  "),
      },
      opts = { spacing = 1 },
    },
  },
  opts = { noautocmd = true },
}))
