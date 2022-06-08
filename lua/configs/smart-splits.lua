local status_ok, smart_splits = pcall(require, "smart-splits")
if status_ok then
  smart_splits.setup(astronvim.user_plugin_opts("plugins.smart-splits", {
    ignored_filetypes = {
      "nofile",
      "quickfix",
      "qf",
      "prompt",
    },
    ignored_buftypes = { "nofile" },
  }))
end
