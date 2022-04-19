local M = {}

function M.config()
  local status_ok, loader = pcall(require, "luasnip/loaders/from_vscode")
  if status_ok then
    local user_settings = require("core.utils").user_plugin_opts("luasnip", {})
    if user_settings.vscode_snippet_paths ~= nil then
      loader.lazy_load { paths = user_settings.vscode_snippet_paths }
    end
    loader.lazy_load()
  end
end

return M
