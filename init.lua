local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
  impatient.enable_profile()
end

local utils = require "core.utils"

utils.disabled_builtins()

utils.bootstrap()

local sources = {
  "core.options",
  (vim.fn.has "nvim-0.7" == 1 and "nightly." or "") .. "core.autocmds",
  "core.plugins",
  (vim.fn.has "nvim-0.7" == 1 and "nightly." or "") .. "core.mappings",
}

for _, source in ipairs(sources) do
  local status_ok, fault = pcall(require, source)
  if not status_ok then
    error("Failed to load " .. source .. "\n\n" .. fault)
  end
end

local polish = utils.user_plugin_opts "polish"

if type(polish) == "function" then
  polish()
end

-- keep this last:
utils.compiled()
