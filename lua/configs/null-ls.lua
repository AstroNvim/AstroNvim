local status_ok, null_ls = pcall(require, "null-ls")
if status_ok then
  null_ls.setup(astronvim.user_plugin_opts "plugins.null-ls")
end
