local M = {}

function M.config()
  local status_ok, which_key = pcall(require, "which-key")
  if status_ok then
    -- Don't show which-key popup when Telescope is opened
    local show = which_key.show
    which_key.show = function(keys, opts)
      if vim.bo.filetype == "TelescopePrompt" then
        return
      end
      show(keys, opts)
    end
    which_key.setup(require("core.utils").user_plugin_opts("plugins.which-key", {
      plugins = {
        spelling = { enabled = true },
        presets = { operators = false },
      },
      window = {
        border = "rounded",
        padding = { 2, 2, 2, 2 },
      },
    }))
  end
end

return M
