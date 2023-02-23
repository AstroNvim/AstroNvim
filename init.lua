for _, source in ipairs {
  "core.bootstrap",
  "core.options",
  "core.lazy",
  "core.autocmds",
  "core.mappings",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

local utils = require "core.utils"

if astronvim.default_colorscheme then
  if not pcall(vim.cmd.colorscheme, astronvim.default_colorscheme) then
    utils.notify("Error setting up colorscheme: " .. astronvim.default_colorscheme, "error")
  end
end

utils.conditional_func(astronvim.user_opts("polish", nil, false), true)
