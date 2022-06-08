local status_ok, indent_o_matic = pcall(require, "indent-o-matic")
if status_ok then
  indent_o_matic.setup(astronvim.user_plugin_opts "plugins.indent-o-matic")
end
