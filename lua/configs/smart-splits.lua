local status_ok, smart_splits = pcall(require, "smart-splits")
if not status_ok then return end
smart_splits.setup(astronvim.user_plugin_opts("plugins.smart-splits", {
  ignored_filetypes = {
    "nofile",
    "quickfix",
    "qf",
    "prompt",
  },
  ignored_buftypes = { "nofile" },
}))
