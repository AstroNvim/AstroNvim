local status_ok, better_escape = pcall(require, "better_escape")
if status_ok then
  better_escape.setup(astronvim.user_plugin_opts "plugins.better_escape")
end
