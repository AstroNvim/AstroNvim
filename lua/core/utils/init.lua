_G.astronvim = {}
local stdpath = vim.fn.stdpath
local tbl_insert = table.insert
local map = vim.keymap.set

astronvim.install = astronvim_installation or { home = stdpath "config" }
astronvim.install.config = stdpath("config"):gsub("nvim$", "astronvim")
vim.opt.rtp:append(astronvim.install.config)
local supported_configs = { astronvim.install.home, astronvim.install.config }

local function load_module_file(module)
  local found_module = nil
  for _, config_path in ipairs(supported_configs) do
    local module_path = config_path .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
    if vim.fn.filereadable(module_path) == 1 then found_module = module_path end
  end
  if found_module then
    local status_ok, loaded_module = pcall(require, module)
    if status_ok then
      found_module = loaded_module
    else
      astronvim.notify("Error loading " .. found_module, "error")
    end
  end
  return found_module
end

astronvim.user_settings = load_module_file "user.init"
astronvim.default_compile_path = stdpath "data" .. "/packer_compiled.lua"
astronvim.user_terminals = {}
astronvim.url_matcher =
  "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

local function func_or_extend(overrides, default, extend)
  if extend then
    if type(overrides) == "table" then
      default = vim.tbl_deep_extend("force", default, overrides)
    elseif type(overrides) == "function" then
      default = overrides(default)
    end
  elseif overrides ~= nil then
    default = overrides
  end
  return default
end

function astronvim.conditional_func(func, condition, ...)
  if (condition == nil and true or condition) and type(func) == "function" then return func(...) end
end

function astronvim.trim_or_nil(str) return type(str) == "string" and vim.trim(str) or nil end

function astronvim.notify(msg, type, opts)
  vim.notify(msg, type, vim.tbl_deep_extend("force", { title = "AstroNvim" }, opts or {}))
end

function astronvim.echo(messages)
  messages = messages or { { "\n" } }
  if type(messages) == "table" then vim.api.nvim_echo(messages, false, {}) end
end

function astronvim.confirm_prompt(messages)
  if messages then astronvim.echo(messages) end
  local confirmed = string.lower(vim.fn.input "(y/n) ") == "y"
  astronvim.echo()
  astronvim.echo()
  return confirmed
end

local function user_setting_table(module)
  local settings = astronvim.user_settings or {}
  for tbl in string.gmatch(module, "([^%.]+)") do
    settings = settings[tbl]
    if settings == nil then break end
  end
  return settings
end

function astronvim.initialize_packer()
  local packer_avail, _ = pcall(require, "packer")
  if not packer_avail then
    local packer_path = stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    vim.fn.delete(packer_path, "rf")
    vim.fn.system {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      packer_path,
    }
    astronvim.echo { { "Initializing Packer...\n\n" } }
    vim.cmd "packadd packer.nvim"
    packer_avail, _ = pcall(require, "packer")
    if not packer_avail then vim.api.nvim_err_writeln("Failed to load packer at:" .. packer_path) end
  end
  if packer_avail then
    local run_me, _ = loadfile(
      astronvim.user_plugin_opts("plugins.packer", { compile_path = astronvim.default_compile_path }).compile_path
    )
    if run_me then
      run_me()
    else
      astronvim.echo { { "Please run " }, { ":PackerSync", "Title" } }
    end
  end
end

function astronvim.vim_opts(options)
  for scope, table in pairs(options) do
    for setting, value in pairs(table) do
      vim[scope][setting] = value
    end
  end
end

function astronvim.user_plugin_opts(module, default, extend, prefix)
  if extend == nil then extend = true end
  default = default or {}
  local user_settings = load_module_file((prefix or "user") .. "." .. module)
  if user_settings == nil and prefix == nil then user_settings = user_setting_table(module) end
  if user_settings ~= nil then default = func_or_extend(user_settings, default, extend) end
  return default
end

function astronvim.url_opener()
  if vim.fn.has "mac" == 1 then
    vim.fn.jobstart({ "open", vim.fn.expand "<cfile>" }, { detach = true })
  elseif vim.fn.has "unix" == 1 then
    vim.fn.jobstart({ "xdg-open", vim.fn.expand "<cfile>" }, { detach = true })
  else
    astronvim.notify("gx is not supported on this OS!", "error")
  end
end

-- term_details can be either a string for just a command or
-- a complete table to provide full access to configuration when calling Terminal:new()
function astronvim.toggle_term_cmd(term_details)
  if type(term_details) == "string" then term_details = { cmd = term_details, hidden = true } end
  local term_key = term_details.cmd
  if vim.v.count > 0 and term_details.count == nil then
    term_details.count = vim.v.count
    term_key = term_key .. vim.v.count
  end
  if astronvim.user_terminals[term_key] == nil then
    astronvim.user_terminals[term_key] = require("toggleterm.terminal").Terminal:new(term_details)
  end
  astronvim.user_terminals[term_key]:toggle()
end

function astronvim.add_cmp_source(source)
  local cmp_avail, cmp = pcall(require, "cmp")
  if cmp_avail then
    local config = cmp.get_config()
    tbl_insert(config.sources, source)
    cmp.setup(config)
  end
end

function astronvim.get_user_cmp_source(source)
  source = type(source) == "string" and { name = source } or source
  local priority = astronvim.user_plugin_opts("cmp.source_priority", {
    nvim_lsp = 1000,
    luasnip = 750,
    buffer = 500,
    path = 250,
  })[source.name]
  if priority then source.priority = priority end
  return source
end

function astronvim.add_user_cmp_source(source) astronvim.add_cmp_source(astronvim.get_user_cmp_source(source)) end

function astronvim.null_ls_providers(filetype)
  local registered = {}
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    for _, source in ipairs(sources.get_available(filetype)) do
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        tbl_insert(registered[method], source.name)
      end
    end
  end
  return registered
end

function astronvim.null_ls_sources(filetype, source)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and astronvim.null_ls_providers(filetype)[methods.internal[source]] or {}
end

function astronvim.alpha_button(sc, txt)
  local sc_ = sc:gsub("%s", ""):gsub("LDR", "<leader>")
  if vim.g.mapleader then sc = sc:gsub("LDR", vim.g.mapleader == " " and "SPC" or vim.g.mapleader) end
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

function astronvim.is_available(plugin) return packer_plugins ~= nil and packer_plugins[plugin] ~= nil end

function astronvim.set_mappings(map_table, base)
  for mode, maps in pairs(map_table) do
    for keymap, options in pairs(maps) do
      if options then
        local cmd = options
        if type(options) == "table" then
          cmd = options[1]
          options[1] = nil
        else
          options = {}
        end
        map(mode, keymap, cmd, vim.tbl_deep_extend("force", options, base or {}))
      end
    end
  end
end

function astronvim.delete_url_match()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == "HighlightURL" then vim.fn.matchdelete(match.id) end
  end
end

function astronvim.set_url_match()
  astronvim.delete_url_match()
  if vim.g.highlighturl_enabled then vim.fn.matchadd("HighlightURL", astronvim.url_matcher, 15) end
end

function astronvim.toggle_url_match()
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  astronvim.set_url_match()
end

function astronvim.cmd(cmd, show_error)
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil and true or show_error) then
    vim.api.nvim_err_writeln("Error running command: " .. cmd .. "\nError message:\n" .. result)
  end
  return success and result or nil
end

require "core.utils.updater"

return astronvim
