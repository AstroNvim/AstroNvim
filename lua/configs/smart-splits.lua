local M = {}

function M.config()
  local present, smart_splits = pcall(require, "smart-splits")
  if present then
    smart_splits.setup(astronvim.user_plugin_opts("plugins.smart-splits", {
      ignored_filetypes = {
        "nofile",
        "quickfix",
        "qf",
        "prompt",
      },
      ignored_buftypes = { "nofile" },
    }))
  end
end

return M
