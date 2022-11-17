local user_settings = astronvim.user_plugin_opts "luasnip"
local luasnip = require "luasnip"
if user_settings.config then luasnip.config.setup(user_settings.config) end
for _, load_type in ipairs { "vscode", "snipmate", "lua" } do
  local loader = require("luasnip.loaders.from_" .. load_type)
  loader.lazy_load()
  -- TODO: DEPRECATE _snippet_paths option in next major version release
  local paths = user_settings[load_type .. "_snippet_paths"]
  if paths then loader.lazy_load { paths = paths } end
  local loader_settings = user_settings[load_type]
  if loader_settings then loader.lazy_load(loader_settings) end
end
if type(user_settings.filetype_extend) == "table" then
  for filetype, snippets in pairs(user_settings.filetype_extend) do
    luasnip.filetype_extend(filetype, snippets)
  end
end
