local M = {}

local g = vim.g

local function load_user_settings()
  local status_ok, user_settings = pcall(require, "user")
  local defaults = require "core.defaults"
  if status_ok and type(user_settings) == "table" then
    defaults = vim.tbl_deep_extend("force", defaults, user_settings)
  end
  return defaults
end

local _user_settings = load_user_settings()

local function func_or_extend(overrides, default)
  if default == nil then
    default = overrides
  elseif type(overrides) == "table" then
    default = vim.tbl_deep_extend("force", default, overrides)
  elseif type(overrides) == "function" then
    default = overrides(default)
  end
  return default
end

local function user_setting_table(module)
  local settings = _user_settings
  for tbl in string.gmatch(module, "([^%.]+)") do
    settings = settings[tbl]
    if settings == nil then
      break
    end
  end
  return settings
end

local function load_options(module, default)
  local status_ok, user_settings = pcall(require, "user." .. module)
  if not status_ok then
    user_settings = user_setting_table(module)
  end
  if user_settings ~= nil then
    default = func_or_extend(user_settings, default)
  end
  return default
end

M.base_notification = { title = "AstroVim" }

function M.bootstrap()
  local fn = vim.fn
  local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    }
    print "Cloning packer...\nSetup AstroVim"
    vim.cmd [[packadd packer.nvim]]
  end
end

function M.disabled_builtins()
  g.loaded_2html_plugin = false
  g.loaded_getscript = false
  g.loaded_getscriptPlugin = false
  g.loaded_gzip = false
  g.loaded_logipat = false
  g.loaded_netrwFileHandlers = false
  g.loaded_netrwPlugin = false
  g.loaded_netrwSettngs = false
  g.loaded_remote_plugins = false
  g.loaded_tar = false
  g.loaded_tarPlugin = false
  g.loaded_zip = false
  g.loaded_zipPlugin = false
  g.loaded_vimball = false
  g.loaded_vimballPlugin = false
  g.zipPlugin = false
end

function M.user_settings()
  return _user_settings
end

function M.user_plugin_opts(plugin, default)
  return load_options(plugin, default)
end

function M.compiled()
  local run_me, _ = loadfile(M.user_plugin_opts("plugins.packer", {}).compile_path)
  if run_me then
    run_me()
  else
    print "Please run :PackerSync"
  end
end

function M.list_registered_providers_names(filetype)
  local s = require "null-ls.sources"
  local available_sources = s.get_available(filetype)
  local registered = {}
  for _, source in ipairs(available_sources) do
    for method in pairs(source.methods) do
      registered[method] = registered[method] or {}
      table.insert(registered[method], source.name)
    end
  end
  return registered
end

function M.list_registered_formatters(filetype)
  local null_ls_methods = require "null-ls.methods"
  local formatter_method = null_ls_methods.internal["FORMATTING"]
  local registered_providers = M.list_registered_providers_names(filetype)
  return registered_providers[formatter_method] or {}
end

function M.list_registered_linters(filetype)
  local null_ls_methods = require "null-ls.methods"
  local formatter_method = null_ls_methods.internal["DIAGNOSTICS"]
  local registered_providers = M.list_registered_providers_names(filetype)
  return registered_providers[formatter_method] or {}
end

function M.add_cmp_source(source)
  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    local config = cmp.get_config()
    table.insert(config.sources, { name = source })
    cmp.setup(config)
  end
end

function M.label_plugins(plugins)
  local labelled = {}
  for _, plugin in ipairs(plugins) do
    labelled[plugin[1]] = plugin
  end
  return labelled
end

function M.update()
  local Job = require "plenary.job"

  Job
    :new({
      command = "git",
      args = { "pull", "--ff-only" },
      cwd = vim.fn.stdpath "config",
      on_exit = function(_, return_val)
        if return_val == 0 then
          vim.notify("Updated!", "info", M.base_notification)
        else
          vim.notify("Update failed! Please try pulling manually.", "error", M.base_notification)
        end
      end,
    })
    :sync()
end

return M
