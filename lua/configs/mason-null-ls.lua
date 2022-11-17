local mason_null_ls = require "mason-null-ls"
mason_null_ls.setup(astronvim.user_plugin_opts("plugins.mason-null-ls", { automatic_setup = true }))
mason_null_ls.setup_handlers(astronvim.user_plugin_opts("mason-null-ls.setup_handlers", {}))
