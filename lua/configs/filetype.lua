local M = {}

function M.config()
  local present, better_escape = pcall(require, "filetype")
  if not present then
    return
  end

  if vim.fn.has "nvim-0.6" == 0 then
    vim.g.did_load_filetypes = 1
  end

  better_escape.setup(require("core.utils").user_plugin_opts("plugins.filetype", {}))
end

return M
