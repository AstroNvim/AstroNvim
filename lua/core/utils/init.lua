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
  if condition and type(func) == "function" then return func(...) end
end

--- Get highlight properties for a given highlight name
-- @param name highlight group name
-- @return table of highlight group properties
function astronvim.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
    if not hl["foreground"] then hl["foreground"] = "NONE" end
    if not hl["background"] then hl["background"] = "NONE" end
    hl.fg, hl.bg, hl.sp = hl.foreground, hl.background, hl.special
    hl.ctermfg, hl.ctermbg = hl.foreground, hl.background
    return hl
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
  if default == nil then default = {} end
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

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
-- @param plugin the plugin string to search for
-- @return boolean value if the plugin is available
function astronvim.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.plugins and lazy_config.plugins[plugin]
end

--- A helper function to wrap a module function to require a plugin before running
-- @param plugin the plugin string to call `require("lazy").laod` with
-- @param module the system module where the functions live (e.g. `vim.ui`)
-- @param func_names a string or a list like table of strings for functions to wrap in the given moduel (e.g. `{ "ui", "select }`)
function astronvim.load_plugin_with_func(plugin, module, func_names)
  if type(func_names) == "string" then func_names = { func_names } end
  for _, func in ipairs(func_names) do
    local old_func = module[func]
    module[func] = function(...)
      module[func] = old_func
      require("lazy").load { plugins = { plugin } }
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
  return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Check if a buffer is valid
-- @param bufnr the buffer to check
-- @return true if the buffer is valid or false
function astronvim.is_valid_buffer(bufnr)
  if not bufnr or bufnr < 1 then return false end
  return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
end

--- Move the current buffer tab n places in the bufferline
-- @param n numer of tabs to move the current buffer over by (positive = right, negative = left)
function astronvim.move_buf(n)
  if n == 0 then return end -- if n = 0 then no shifts are needed
  local bufs = vim.t.bufs -- make temp variable
  for i, bufnr in ipairs(bufs) do -- loop to find current buffer
    if bufnr == vim.api.nvim_get_current_buf() then -- found index of current buffer
      for _ = 0, (n % #bufs) - 1 do -- calculate number of right shifts
        local new_i = i + 1 -- get next i
        if i == #bufs then -- if at end, cycle to beginning
          new_i = 1 -- next i is actually 1 if at the end
          local val = bufs[i] -- save value
          table.remove(bufs, i) -- remove from end
          table.insert(bufs, new_i, val) -- insert at beginning
        else -- if not at the end,then just do an in place swap
          bufs[i], bufs[new_i] = bufs[new_i], bufs[i]
        end
        i = new_i -- iterate i to next value
      end
      break
    end
  end
  vim.t.bufs = bufs -- set buffers
  vim.cmd.redrawtabline() -- redraw tabline
end

--- Navigate left and right by n places in the bufferline
-- @param n the number of tabs to navigate to (positive = right, negative = left)
function astronvim.nav_buf(n)
  local current = vim.api.nvim_get_current_buf()
  for i, v in ipairs(vim.t.bufs) do
    if current == v then
      vim.cmd.b(vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1])
      break
    end
  end
end

--- Close a given buffer
-- @param bufnr? the buffer number to close or the current buffer if not provided
function astronvim.close_buf(bufnr, force)
  if force == nil then force = false end
  local current = vim.api.nvim_get_current_buf()
  if not bufnr or bufnr == 0 then bufnr = current end
  if bufnr == current then astronvim.nav_buf(-1) end

  if astronvim.is_available "bufdelete.nvim" then
    require("bufdelete").bufdelete(bufnr, force)
  else
    vim.cmd((force and "bd!" or "confirm bd") .. bufnr)
  end
end

--- Close the current tab
function astronvim.close_tab()
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.t.bufs = nil
    vim.cmd.tabclose()
  end
end

require "core.utils.ui"
require "core.utils.status"
require "core.utils.updater"
require "core.utils.mason"
require "core.utils.lsp"

return astronvim
