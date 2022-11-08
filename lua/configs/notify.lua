local notify = require "notify"
notify.setup(astronvim.user_plugin_opts("plugins.notify", { stages = "fade" }))
vim.notify = notify
