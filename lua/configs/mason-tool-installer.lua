local status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if not status_ok then return end
mason_tool_installer.setup(astronvim.user_plugin_opts "plugins.mason-tool-installer")
