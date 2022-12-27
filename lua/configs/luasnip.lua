local user_settings = astronvim.user_plugin_opts "luasnip"
local luasnip = require "luasnip"
if user_settings.config then luasnip.config.setup(user_settings.config) end
vim.tbl_map(function(type) require("luasnip.loaders.from_" .. type).lazy_load() end, { "vscode", "snipmate", "lua" })
