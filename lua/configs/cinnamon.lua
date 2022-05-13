local M = {}

function M.config()
  local status_ok, cinnamon = pcall(require, "cinnamon")
  if status_ok then
    cinnamon.setup(astronvim.user_plugin_opts("plugins.cinnamon", {
      extra_keymaps = true,
      extended_keymaps = true,
    }))
  end
end

return M
