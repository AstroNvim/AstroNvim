local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
  impatient.enable_profile()
end

local utils = require "core.utils"

utils.disabled_builtins()

utils.bootstrap()

local sources = {
  "core.options",
  "core.autocmds",
  "core.plugins",
  "core.mappings",
}

for _, source in ipairs(sources) do
  local status_ok, fault = pcall(require, source)
  if not status_ok then
    error("Failed to load " .. source .. "\n\n" .. fault)
  end
end

local status_ok, ui = pcall(require, "core.ui")
if status_ok then
  for ui_addition, enabled in pairs(utils.user_settings().ui) do
    if enabled and type(ui[ui_addition]) == "function" then
      ui[ui_addition]()
    end
  end
end

utils.compiled()

local polish = utils.user_plugin_opts "polish"
if type(polish) == "function" then
  polish()
end
