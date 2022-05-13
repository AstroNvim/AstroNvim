local M = {}

function M.config()
  local present, indent_o_matic = pcall(require, "indent-o-matic")
  if present then
    indent_o_matic.setup(astronvim.user_plugin_opts "plugins.indent-o-matic")
  end
end

return M
