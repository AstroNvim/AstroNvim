local M = {}
local user_plugin_opts = astronvim.user_plugin_opts

function M.config()
  local status_ok, which_key = pcall(require, "which-key")
  if status_ok then
    local show = which_key.show
    local show_override = user_plugin_opts("which-key.show", nil, false)
    which_key.show = type(show_override) == "function" and show_override(show)
      or function(keys, opts)
        if vim.bo.filetype ~= "TelescopePrompt" then
          show(keys, opts)
        end
      end
    which_key.setup(user_plugin_opts("plugins.which-key", {
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
