--- ### AstroNvim Core Bootstrap
--
-- This module simply sets up the global `astronvim` module.
-- This is automatically loaded and should not be resourced, everything is accessible through the global `astronvim` variable.
--
-- @module astronvim.bootstrap
-- @copyright 2022
-- @license GNU General Public License v3.0

_G.astronvim = {}

--- installation details from external installers
astronvim.install = _G["astronvim_installation"] or { home = vim.fn.stdpath "config" }
astronvim.supported_configs = { astronvim.install.home }
--- external astronvim configuration folder
astronvim.install.config = vim.fn.stdpath("config"):gsub("[^/\\]+$", "astronvim")
-- check if they are the same, protects against NVIM_APPNAME use for isolated install
if astronvim.install.home ~= astronvim.install.config then
  vim.opt.rtp:append(astronvim.install.config)
  --- supported astronvim user conifg folders
  table.insert(astronvim.supported_configs, astronvim.install.config)
end

--- Looks to see if a module path references a lua file in a configuration folder and tries to load it. If there is an error loading the file, write an error and continue
---@param module string The module path to try and load
---@return table|nil # The loaded module if successful or nil
local function load_module_file(module)
  -- placeholder for final return value
  local found_file = nil
  -- search through each of the supported configuration locations
  for _, config_path in ipairs(astronvim.supported_configs) do
    -- convert the module path to a file path (example user.init -> user/init.lua)
    local module_path = config_path .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
    -- check if there is a readable file, if so, set it as found
    if vim.fn.filereadable(module_path) == 1 then found_file = module_path end
  end
  -- if we found a readable lua file, try to load it
  local out = nil
  if found_file then
    -- try to load the file
    local status_ok, loaded_module = pcall(require, module)
    -- if successful at loading, set the return variable
    if status_ok then
      out = loaded_module
    -- if unsuccessful, throw an error
    else
      vim.api.nvim_err_writeln("Error loading file: " .. found_file .. "\n\n" .. loaded_module)
    end
  end
  -- return the loaded module or nil if no file found
  return out
end

--- Main configuration engine logic for extending a default configuration table with either a function override or a table to merge into the default option
-- @param overrides the override definition, either a table or a function that takes a single parameter of the original table
-- @param default the default configuration table
-- @param extend boolean value to either extend the default or simply overwrite it if an override is provided
-- @return the new configuration table
local function func_or_extend(overrides, default, extend)
  -- if we want to extend the default with the provided override
  if extend then
    -- if the override is a table, use vim.tbl_deep_extend
    if type(overrides) == "table" then
      local opts = overrides or {}
      default = default and vim.tbl_deep_extend("force", default, opts) or opts
    -- if the override is  a function, call it with the default and overwrite default with the return value
    elseif type(overrides) == "function" then
      default = overrides(default)
    end
  -- if extend is set to false and we have a provided override, simply override the default
  elseif overrides ~= nil then
    default = overrides
  end
  -- return the modified default table
  return default
end

--- user settings from the base `user/init.lua` file
local user_settings = load_module_file "user.init"

--- Search the user settings (user/init.lua table) for a table with a module like path string
-- @param module the module path like string to look up in the user settings table
-- @return the value of the table entry if exists or nil
local function user_setting_table(module)
  -- get the user settings table
  local settings = user_settings or {}
  -- iterate over the path string split by '.' to look up the table value
  for tbl in string.gmatch(module, "([^%.]+)") do
    settings = settings[tbl]
    -- if key doesn't exist, keep the nil value and stop searching
    if settings == nil then break end
  end
  -- return the found settings
  return settings
end

--- User configuration entry point to override the default options of a configuration table with a user configuration file or table in the user/init.lua user settings
---@param module string The module path of the override setting
---@param default? any The default value that will be overridden
---@param extend? boolean # Whether extend the default settings or overwrite them with the user settings entirely (default: true)
---@return any # The new configuration settings with the user overrides applied
function astronvim.user_opts(module, default, extend)
  -- default to extend = true
  if extend == nil then extend = true end
  -- if no default table is provided set it to an empty table
  if default == nil then default = {} end
  -- try to load a module file if it exists
  local user_module_settings = load_module_file("user." .. module)
  -- if no user module file is found, try to load an override from the user settings table from user/init.lua
  if user_module_settings == nil then user_module_settings = user_setting_table(module) end
  -- if a user override was found call the configuration engine
  if user_module_settings ~= nil then default = func_or_extend(user_module_settings, default, extend) end
  -- return the final configuration table with any overrides applied
  return default
end

--- Updater settings overridden with any user provided configuration
astronvim.updater = {
  options = astronvim.user_opts("updater", { remote = "origin", channel = "stable" }),
  snapshot = { module = "lazy_snapshot", path = vim.fn.stdpath "config" .. "/lua/lazy_snapshot.lua" },
  rollback_file = vim.fn.stdpath "cache" .. "/astronvim_rollback.lua",
}
local options = astronvim.updater.options
if astronvim.install.is_stable ~= nil then options.channel = astronvim.install.is_stable and "stable" or "nightly" end
if options.pin_plugins == nil then options.pin_plugins = options.channel == "stable" end

--- table of user created terminals
astronvim.user_terminals = {}
--- table of language servers to ignore the setup of, configured through lsp.skip_setup in the user configuration
astronvim.lsp = { skip_setup = astronvim.user_opts("lsp.skip_setup", {}), progress = {} }
--- the default colorscheme to apply on startup
astronvim.default_colorscheme = astronvim.user_opts("colorscheme", "astrotheme", false)
