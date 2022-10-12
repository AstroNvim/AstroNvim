local status_ok, colorizer = pcall(require, "colorizer")
if not status_ok then return end
colorizer.setup(astronvim.user_plugin_opts("plugins.colorizer", { user_default_options = { names = false } }))
