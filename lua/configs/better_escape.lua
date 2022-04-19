local M = {}

function M.config()
  local present, better_escape = pcall(require, "better_escape")
  if present then
    better_escape.setup(require("core.utils").user_plugin_opts("plugins.better_escape", {
      mapping = { "ii", "jj", "jk", "kj" },
      timeout = vim.o.timeoutlen,
      keys = "<ESC>",
    }))
  end
end

return M
