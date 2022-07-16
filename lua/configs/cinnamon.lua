local status_ok, cinnamon = pcall(require, "cinnamon")
if not status_ok then return end
cinnamon.setup(astronvim.user_plugin_opts("plugins.cinnamon", {}))
