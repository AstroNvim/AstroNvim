if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end

for _, source in ipairs { "astronvim.bootstrap", "astronvim.options", "astronvim.lazy" } do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

local polish = astronvim.user_opts("polish", nil, false)
if type(polish) == "function" then polish() end
