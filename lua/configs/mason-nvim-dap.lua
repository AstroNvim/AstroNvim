local status_ok, mason_nvim_dap = pcall(require, "mason-nvim-dap")
if not status_ok then return end
mason_nvim_dap.setup(astronvim.user_plugin_opts("plugins.mason-nvim-dap", { automatic_setup = true }))
mason_nvim_dap.setup_handlers(astronvim.user_plugin_opts("mason-nvim-dap.setup_handlers", {}))
