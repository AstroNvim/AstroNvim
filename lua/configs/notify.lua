local M = {}

function M.config()
  local present, notify = pcall(require, "notify")
  if not present then
    return
  end

  notify.setup(require("core.utils").user_plugin_opts("plugins.notify", {
    stages = "fade",
    on_open = nil,
    on_close = nil,
    render = "default",
    timeout = 5000,
    max_width = nil,
    max_height = nil,
    background_colour = "Normal",
    minimum_width = 50,
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "✎",
    },
  }))

  vim.notify = notify
end

return M
