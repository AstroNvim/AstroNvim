local M = {}

function M.config()
  local present, notify = pcall(require, "notify")
  if present then
    notify.setup(astronvim.user_plugin_opts("plugins.notify", { stages = "fade" }))

    vim.notify = notify
  end
end

return M
