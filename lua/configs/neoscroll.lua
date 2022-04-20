local M = {}

function M.config()
  local status_ok, neoscroll = pcall(require, "neoscroll")
  if status_ok then
    neoscroll.setup(require("core.utils").user_plugin_opts("plugins.neoscroll", {}))
  end
end

return M
