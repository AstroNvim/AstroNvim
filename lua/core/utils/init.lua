--- ### AstroNvim Utilities
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim`
--
-- This module can also be manually loaded with `local astronvim = require "core.utils"`
--
-- @module core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

_G.astronvim = {}
local stdpath = vim.fn.stdpath
local tbl_insert = table.insert
local map = vim.keymap.set

--- installation details from external installers
astronvim.install = astronvim_installation or { home = stdpath "config" }
--- external astronvim configuration folder
astronvim.install.config = stdpath("config"):gsub("nvim$", "astronvim")
vim.opt.rtp:append(astronvim.install.config)
local supported_configs = { astronvim.install.home, astronvim.install.config }

--- Looks to see if a module path references a lua file in a configuration folder and tries to load it. If there is an error loading the file, write an error and continue
-- @param module the module path to try and load
-- @return the loaded module if successful or nil
local function load_module_file(module)
  -- placeholder for final return value
  local found_module = nil
  -- search through each of the supported configuration locations
  for _, config_path in ipairs(supported_configs) do
    -- convert the module path to a file path (example user.init -> user/init.lua)
    local module_path = config_path .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
    -- check if there is a readable file, if so, set it as found
    if vim.fn.filereadable(module_path) == 1 then found_module = module_path end
  end
  -- if we found a readable lua file, try to load it
  if found_module then
    -- try to load the file
    local status_ok, loaded_module = pcall(require, module)
    -- if successful at loading, set the return variable
    if status_ok then
      found_module = loaded_module
      -- if unsuccessful, throw an error
    else
      vim.api.nvim_err_writeln("Error loading file: " .. found_module .. "\n\n" .. loaded_module)
    end
  end
  -- return the loaded module or nil if no file found
  return found_module
end

--- user settings from the base `user/init.lua` file
astronvim.user_settings = load_module_file "user.init"
--- default packer compilation location to be used in bootstrapping and packer setup call
astronvim.default_compile_path = stdpath "data" .. "/packer_compiled.lua"
--- table of user created terminals
astronvim.user_terminals = {}
--- table of plugins to load with git
astronvim.git_plugins = {}
--- table of plugins to load when file opened
astronvim.file_plugins = {}
--- regex used for matching a valid URL/URI string
astronvim.url_matcher =
  "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Main configuration engine logic for extending a default configuration table with either a function override or a table to merge into the default option
-- @function astronvim.func_or_extend
-- @param overrides the override definition, either a table or a function that takes a single parameter of the original table
-- @param default the default configuration table
-- @param extend boolean value to either extend the default or simply overwrite it if an override is provided
-- @return the new configuration table
local function func_or_extend(overrides, default, extend)
  -- if we want to extend the default with the provided override
  if extend then
    -- if the override is a table, use vim.tbl_deep_extend
    if type(overrides) == "table" then
      default = astronvim.default_tbl(overrides, default)
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

--- Merge extended options with a default table of options
-- @param opts the new options that should be merged with the default table
-- @param default the default table that you want to merge into
-- @return the merged table
function astronvim.default_tbl(opts, default)
  opts = opts or {}
  return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- Call function if a condition is met
-- @param func the function to run
-- @param condition a boolean value of whether to run the function or not
function astronvim.conditional_func(func, condition, ...)
  -- if the condition is true or no condition is provided, evaluate the function with the rest of the parameters and return the result
  if (condition == nil or condition) and type(func) == "function" then return func(...) end
end

--- Get highlight properties for a given highlight name
-- @param name highlight group name
-- @return table of highlight group properties
function astronvim.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
    local old_true_val = hl[true]
    hl[true] = nil
    if not vim.tbl_isempty(hl) then
      hl[true] = old_true_val
      if not hl["foreground"] then hl["foreground"] = "NONE" end
      if not hl["background"] then hl["background"] = "NONE" end
      hl.fg, hl.bg, hl.sp = hl.foreground, hl.background, hl.special
      hl.ctermfg, hl.ctermbg = hl.foreground, hl.background
      return hl
    end
  end
  return fallback
end

--- Trim a string or return nil
-- @param str the string to trim
-- @return a trimmed version of the string or nil if the parameter isn't a string
function astronvim.trim_or_nil(str) return type(str) == "string" and vim.trim(str) or nil end

--- Add left and/or right padding to a string
-- @param str the string to add padding to
-- @param padding a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
-- @return the padded string
function astronvim.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0) or ""
end

--- Initialize icons used throughout the user interface
function astronvim.initialize_icons()
  astronvim.icons = astronvim.user_plugin_opts("icons", require "core.icons.nerd_font")
  astronvim.text_icons = astronvim.user_plugin_opts("text_icons", require "core.icons.text")
end

--- Get an icon from `lspkind` if it is available and return it
-- @param kind the kind of icon in `lspkind` to retrieve
-- @return the icon
function astronvim.get_icon(kind)
  local icon_pack = vim.g.icons_enabled and "icons" or "text_icons"
  if not astronvim[icon_pack] then astronvim.initialize_icons() end
  return astronvim[icon_pack] and astronvim[icon_pack][kind] or ""
end

--- Serve a notification with a title of AstroNvim
-- @param msg the notification body
-- @param type the type of the notification (:help vim.log.levels)
-- @param opts table of nvim-notify options to use (:help notify-options)
function astronvim.notify(msg, type, opts)
  vim.schedule(function() vim.notify(msg, type, astronvim.default_tbl(opts, { title = "AstroNvim" })) end)
end

--- Trigger an AstroNvim user event
-- @param event the event name to be appended to Astro
function astronvim.event(event)
  vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "Astro" .. event }) end)
end

--- Wrapper function for neovim echo API
-- @param messages an array like table where each item is an array like table of strings to echo
function astronvim.echo(messages)
  -- if no parameter provided, echo a new line
  messages = messages or { { "\n" } }
  if type(messages) == "table" then vim.api.nvim_echo(messages, false, {}) end
end

--- Echo a message and prompt the user for yes or no response
-- @param messages the message to echo
-- @return True if the user responded y, False for any other response
function astronvim.confirm_prompt(messages)
  if messages then astronvim.echo(messages) end
  local confirmed = string.lower(vim.fn.input "(y/n) ") == "y"
  astronvim.echo()
  astronvim.echo()
  return confirmed
end

--- Search the user settings (user/init.lua table) for a table with a module like path string
-- @param module the module path like string to look up in the user settings table
-- @return the value of the table entry if exists or nil
local function user_setting_table(module)
  -- get the user settings table
  local settings = astronvim.user_settings or {}
  -- iterate over the path string split by '.' to look up the table value
  for tbl in string.gmatch(module, "([^%.]+)") do
    settings = settings[tbl]
    -- if key doesn't exist, keep the nil value and stop searching
    if settings == nil then break end
  end
  -- return the found settings
  return settings
end

--- Check if packer is installed and loadable, if not then install it and make sure it loads
function astronvim.initialize_packer()
  -- try loading packer
  local packer_path = stdpath "data" .. "/site/pack/packer/opt/packer.nvim"
  local packer_avail = vim.fn.empty(vim.fn.glob(packer_path)) == 0
  -- if packer isn't availble, reinstall it
  if not packer_avail then
    -- set the location to install packer
    -- delete the old packer install if one exists
    vim.fn.delete(packer_path, "rf")
    -- clone packer
    vim.fn.system {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      packer_path,
    }
    -- add packer and try loading it
    vim.cmd.packadd "packer.nvim"
    local packer_loaded, _ = pcall(require, "packer")
    packer_avail = packer_loaded
    -- if packer didn't load, print error
    if not packer_avail then vim.api.nvim_err_writeln("Failed to load packer at:" .. packer_path) end
  end
  -- if packer is available, check if there is a compiled packer file
  if packer_avail then
    -- try to load the packer compiled file
    local run_me, _ = loadfile(
      astronvim.user_plugin_opts("plugins.packer", { compile_path = astronvim.default_compile_path }).compile_path
    )
    if run_me then
      -- if the file loads, run the compiled function
      run_me()
    else
      -- if there is no compiled file, ask user to sync packer
      require "core.plugins"
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "PackerComplete",
        callback = function()
          vim.cmd.bw()
          vim.tbl_map(require, { "nvim-treesitter", "mason" })
          astronvim.notify "Mason is installing packages if configured, check status with :Mason"
        end,
      })
      vim.opt.cmdheight = 1
      vim.notify "Please wait while plugins are installed..."
      vim.cmd.PackerSync()
    end
  end
end

function astronvim.lazy_load_commands(plugin, commands)
  if type(commands) == "string" then commands = { commands } end
  if astronvim.is_available(plugin) and not packer_plugins[plugin].loaded then
    for _, command in ipairs(commands) do
      pcall(
        vim.cmd,
        string.format(
          'command -nargs=* -range -bang -complete=file %s lua require("packer.load")({"%s"}, { cmd = "%s", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)',
          command,
          plugin,
          command
        )
      )
    end
  end
end

--- Set vim options with a nested table like API with the format vim.<first_key>.<second_key>.<value>
-- @param options the nested table of vim options
function astronvim.vim_opts(options)
  for scope, table in pairs(options) do
    for setting, value in pairs(table) do
      vim[scope][setting] = value
    end
  end
end

--- User configuration entry point to override the default options of a configuration table with a user configuration file or table in the user/init.lua user settings
-- @param module the module path of the override setting
-- @param default the default settings that will be overridden
-- @param extend boolean value to either extend the default settings or overwrite them with the user settings entirely (default: true)
-- @param prefix a module prefix for where to search (default: user)
-- @return the new configuration settings with the user overrides applied
function astronvim.user_plugin_opts(module, default, extend, prefix)
  -- default to extend = true
  if extend == nil then extend = true end
  -- if no default table is provided set it to an empty table
  default = default or {}
  -- try to load a module file if it exists
  local user_settings = load_module_file((prefix or "user") .. "." .. module)
  -- if no user module file is found, try to load an override from the user settings table from user/init.lua
  if user_settings == nil and prefix == nil then user_settings = user_setting_table(module) end
  -- if a user override was found call the configuration engine
  if user_settings ~= nil then default = func_or_extend(user_settings, default, extend) end
  -- return the final configuration table with any overrides applied
  return default
end

--- Open a URL under the cursor with the current operating system (Supports Mac OS X and *nix)
-- @param path the path of the file to open with the system opener
function astronvim.system_open(path)
  path = path or vim.fn.expand "<cfile>"
  if vim.fn.has "mac" == 1 then
    -- if mac use the open command
    vim.fn.jobstart({ "open", path }, { detach = true })
  elseif vim.fn.has "unix" == 1 then
    -- if unix then use xdg-open
    vim.fn.jobstart({ "xdg-open", path }, { detach = true })
  else
    -- if any other operating system notify the user that there is currently no support
    astronvim.notify("System open is not supported on this OS!", "error")
  end
end

-- term_details can be either a string for just a command or
-- a complete table to provide full access to configuration when calling Terminal:new()

--- Toggle a user terminal if it exists, if not then create a new one and save it
-- @param term_details a terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
function astronvim.toggle_term_cmd(opts)
  local terms = astronvim.user_terminals
  -- if a command string is provided, create a basic table for Terminal:new() options
  if type(opts) == "string" then opts = { cmd = opts, hidden = true } end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then terms[opts.cmd] = {} end
  if not terms[opts.cmd][num] then
    if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  astronvim.user_terminals[opts.cmd][num]:toggle()
end

--- Add a source to cmp
-- @param source the cmp source string or table to add (see cmp documentation for source table format)
function astronvim.add_cmp_source(source)
  -- load cmp if available
  local cmp_avail, cmp = pcall(require, "cmp")
  if cmp_avail then
    -- get the current cmp config
    local config = cmp.get_config()
    -- add the source to the list of sources
    tbl_insert(config.sources, source)
    -- call the setup function again
    cmp.setup(config)
  end
end

--- Get the priority of a cmp source
-- @param  source the cmp source string or table (see cmp documentation for source table format)
-- @return a cmp source table with the priority set from the user configuration
function astronvim.get_user_cmp_source(source)
  -- if the source is a string, convert it to a cmp source table
  source = type(source) == "string" and { name = source } or source
  -- get the priority of the source name from the user configuration
  local priority = astronvim.user_plugin_opts("cmp.source_priority", {
    nvim_lsp = 1000,
    luasnip = 750,
    buffer = 500,
    path = 250,
  })[source.name]
  -- if a priority is found, set it in the source
  if priority then source.priority = priority end
  -- return the source table
  return source
end

--- add a source to cmp with the user configured priority
-- @param source a cmp source string or table (see cmp documentation for source table format)
function astronvim.add_user_cmp_source(source) astronvim.add_cmp_source(astronvim.get_user_cmp_source(source)) end

--- register mappings table with which-key
-- @param mappings nested table of mappings where the first key is the mode, the second key is the prefix, and the value is the mapping table for which-key
-- @param opts table of which-key options when setting the mappings (see which-key documentation for possible values)
function astronvim.which_key_register(mappings, opts)
  local status_ok, which_key = pcall(require, "which-key")
  if not status_ok then return end
  for mode, prefixes in pairs(mappings) do
    for prefix, mapping_table in pairs(prefixes) do
      which_key.register(
        mapping_table,
        astronvim.default_tbl(opts, {
          mode = mode,
          prefix = prefix,
          buffer = nil,
          silent = true,
          noremap = true,
          nowait = true,
        })
      )
    end
  end
end

--- Get a list of registered null-ls providers for a given filetype
-- @param filetype the filetype to search null-ls for
-- @return a list of null-ls sources
function astronvim.null_ls_providers(filetype)
  local registered = {}
  -- try to load null-ls
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    -- get the available sources of a given filetype
    for _, source in ipairs(sources.get_available(filetype)) do
      -- get each source name
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        tbl_insert(registered[method], source.name)
      end
    end
  end
  -- return the found null-ls sources
  return registered
end

--- Get the null-ls sources for a given null-ls method
-- @param filetype the filetype to search null-ls for
-- @param method the null-ls method (check null-ls documentation for available methods)
-- @return the available sources for the given filetype and method
function astronvim.null_ls_sources(filetype, method)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and astronvim.null_ls_providers(filetype)[methods.internal[method]] or {}
end

--- Create a button entity to use with the alpha dashboard
-- @param sc the keybinding string to convert to a button
-- @param txt the explanation text of what the keybinding does
-- @return a button entity table for an alpha configuration
function astronvim.alpha_button(sc, txt)
  -- replace <leader> in shortcut text with LDR for nicer printing
  local sc_ = sc:gsub("%s", ""):gsub("LDR", "<leader>")
  -- if the leader is set, replace the text with the actual leader key for nicer printing
  if vim.g.mapleader then sc = sc:gsub("LDR", vim.g.mapleader == " " and "SPC" or vim.g.mapleader) end
  -- return the button entity to display the correct text and send the correct keybinding on press
  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = {
      position = "center",
      text = txt,
      shortcut = sc,
      cursor = 5,
      width = 36,
      align_shortcut = "right",
      hl = "DashboardCenter",
      hl_shortcut = "DashboardShortcut",
    },
  }
end

--- Check if a plugin is defined in packer. Useful with lazy loading when a plugin is not necessarily loaded yet
-- @param plugin the plugin string to search for
-- @return boolean value if the plugin is available
function astronvim.is_available(plugin) return packer_plugins ~= nil and packer_plugins[plugin] ~= nil end

--- A helper function to wrap a module function to require a plugin before running
-- @param plugin the plugin string to call `require("packer").laoder` with
-- @param module the system module where the functions live (e.g. `vim.ui`)
-- @param func_names a string or a list like table of strings for functions to wrap in the given moduel (e.g. `{ "ui", "select }`)
function astronvim.load_plugin_with_func(plugin, module, func_names)
  if type(func_names) == "string" then func_names = { func_names } end
  for _, func in ipairs(func_names) do
    local old_func = module[func]
    module[func] = function(...)
      module[func] = old_func
      require("packer").loader(plugin)
      module[func](...)
    end
  end
end

--- Table based API for setting keybindings
-- @param map_table A nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to
-- @param base A base set of options to set on every keybinding
function astronvim.set_mappings(map_table, base)
  -- iterate over the first keys for each mode
  for mode, maps in pairs(map_table) do
    -- iterate over each keybinding set in the current mode
    for keymap, options in pairs(maps) do
      -- build the options for the command accordingly
      if options then
        local cmd = options
        local keymap_opts = base or {}
        if type(options) == "table" then
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend("force", options, keymap_opts)
          keymap_opts[1] = nil
        end
        -- extend the keybinding options with the base provided and set the mapping
        map(mode, keymap, cmd, keymap_opts)
      end
    end
  end
end

--- Delete the syntax matching rules for URLs/URIs if set
function astronvim.delete_url_match()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == "HighlightURL" then vim.fn.matchdelete(match.id) end
  end
end

--- Add syntax matching rules for highlighting URLs/URIs
function astronvim.set_url_match()
  astronvim.delete_url_match()
  if vim.g.highlighturl_enabled then vim.fn.matchadd("HighlightURL", astronvim.url_matcher, 15) end
end

--- Run a shell command and capture the output and if the command succeeded or failed
-- @param cmd the terminal command to execute
-- @param show_error boolean of whether or not to show an unsuccessful command as an error to the user
-- @return the result of a successfully executed command or nil
function astronvim.cmd(cmd, show_error)
  if vim.fn.has "win32" == 1 then cmd = { "cmd.exe", "/C", cmd } end
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil and true or show_error) then
    vim.api.nvim_err_writeln("Error running command: " .. cmd .. "\nError message:\n" .. result)
  end
  return success and result or nil
end

require "core.utils.ui"
require "core.utils.status"
require "core.utils.updater"
require "core.utils.mason"
require "core.utils.lsp"

return astronvim
