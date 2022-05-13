local M = {}

function M.config()
  local present, null_ls = pcall(require, "null-ls")
  if present then
    null_ls.setup(astronvim.user_plugin_opts "plugins.null-ls")
  end
end

return M
