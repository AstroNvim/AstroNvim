local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end
local show = which_key.show
local show_override = astronvim.user_plugin_opts("which-key.show", nil, false)
which_key.show = type(show_override) == "function" and show_override(show)
  or function(keys, opts)
    if vim.bo.filetype ~= "TelescopePrompt" then show(keys, opts) end
  end
which_key.setup(astronvim.user_plugin_opts("plugins.which-key", {
  plugins = {
    spelling = { enabled = true },
    presets = { operators = false },
  },
  window = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
}))
