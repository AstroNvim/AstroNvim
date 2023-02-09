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

local colorscheme = astronvim.user_opts("colorscheme", false, false)
if colorscheme then colorscheme = pcall(vim.cmd.colorscheme, colorscheme) end
if not colorscheme then colorscheme = pcall(vim.cmd.colorscheme, "astrodark") end
if not colorscheme then utils.notify("Error setting up colorscheme...", "error") end

utils.conditional_func(astronvim.user_opts("polish", nil, false), true)

-- TODO v3: SWITCH THESE CONDITIONS
-- if vim.fn.has "nvim-0.9" ~= 1 or vim.version().prerelease then
if vim.fn.has "nvim-0.8" ~= 1 then
  vim.schedule(function() utils.notify("Unsupported Neovim Version! Please check the requirements", "error") end)
end
