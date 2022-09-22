local status_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not status_ok then return end
mason_null_ls.setup(astronvim.user_plugin_opts "plugins.mason-null-ls")
mason_null_ls.setup_handlers(
  astronvim.user_plugin_opts(
    "mason-null-ls.setup_handlers",
    { function(server) astronvim.null_ls_register(server) end }
  )
)
