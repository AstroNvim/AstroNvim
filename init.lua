if vim.loader then vim.loader.enable() end -- enable vim.loader early if available

for _, source in ipairs {
  "astronvim.bootstrap",
  "astronvim.options",
  "astronvim.lazy",
  "astronvim.autocmds",
  "astronvim.mappings",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

if astronvim.default_colorscheme then
  if not pcall(vim.cmd.colorscheme, astronvim.default_colorscheme) then
    require("astronvim.utils").notify("Error setting up colorscheme: " .. astronvim.default_colorscheme, "error")
  end
end

require("astronvim.utils").conditional_func(astronvim.user_opts("polish", nil, false), true)
