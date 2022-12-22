for _, source in ipairs {
  "core.utils",
  "core.options",
  "core.plugins",
  "core.diagnostics",
  "core.autocmds",
  "core.mappings",
  "configs.which-key-register",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

local colorscheme = astronvim.user_plugin_opts("colorscheme", false, false)
if colorscheme then colorscheme = pcall(vim.cmd.colorscheme, colorscheme) end
if not colorscheme then vim.cmd.colorscheme "default_theme" end

astronvim.conditional_func(astronvim.user_plugin_opts("polish", nil, false), true)

if vim.fn.has "nvim-0.8" ~= 1 or vim.version().prerelease then
  vim.schedule(function() astronvim.notify("Unsupported Neovim Version! Please check the requirements", "error") end)
end
