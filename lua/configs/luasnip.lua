local M = {}

function M.config()
  local status_ok, loader = pcall(require, "luasnip/loaders/from_vscode")
  if not status_ok then
    return
  end

  local user_settings = require("core.utils").user_plugin_opts("luasnip", {})
  if user_settings.vscode_snippet_paths ~= nil then
    loader.lazy_load { paths = user_settings.vscode_snippet_paths }
  end
  loader.lazy_load()
end

return M
