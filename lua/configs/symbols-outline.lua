local M = {}

function M.setup()
  vim.g.symbols_outline = require("core.utils").user_plugin_opts("plugins.symbols_outline", {
    width = 17,
  })
end

return M
