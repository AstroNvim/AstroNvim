local status_ok, dapui = pcall(require, "dapui")
if not status_ok then return end
dapui.setup(astronvim.user_plugin_opts("plugins.dapui", { floating = { border = "rounded" } }))
