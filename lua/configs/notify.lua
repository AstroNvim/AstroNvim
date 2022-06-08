local status_ok, notify = pcall(require, "notify")
if status_ok then
  notify.setup(astronvim.user_plugin_opts("plugins.notify", { stages = "fade" }))

  vim.notify = notify
end
