require("smart-splits").setup(astronvim.user_plugin_opts("plugins.smart-splits", {
  ignored_filetypes = {
    "nofile",
    "quickfix",
    "qf",
    "prompt",
  },
  ignored_buftypes = { "nofile" },
}))
