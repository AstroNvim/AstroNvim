local M = {}

local g = vim.g
local set = vim.opt

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
  g.loaded_gzip = false
  g.loaded_netrwPlugin = false
  g.loaded_netrwSettngs = false
  g.loaded_netrwFileHandlers = false
  g.loaded_tar = false
  g.loaded_tarPlugin = false
  g.zipPlugin = false
  g.loaded_zipPlugin = false
  g.loaded_2html_plugin = false
  g.loaded_remote_plugins = false
  set.shadafile = "NONE"
end

function M.user_settings()
  local default = require "core.defaults"
  local user_status_ok, user_settings = pcall(require, "user.settings")
  if user_status_ok then
    default = vim.tbl_deep_extend("force", default, user_settings)
  end
  return default
end

function M.impatient()
  local impatient_ok, _ = pcall(require, "impatient")
  if impatient_ok then
    require("impatient").enable_profile()
  end
end

function M.compiled()
  local compiled_ok, _ = pcall(require, "packer_compiled")
  if compiled_ok then
    require "packer_compiled"
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

function M.update()
  local Job = require('plenary.job')
  local errors = {}

  Job
    :new({
      command = "git",
      args = { "pull", "--ff-only" },
      cwd = vim.fn.stdpath('config'),
      on_start = function()
        print("Updating...")
      end,
      on_exit = function()
        if vim.tbl_isempty(errors) then
          print("Updated!")
        else
          table.insert(errors, 1, "Something went wrong! Please pull changes manually.")
          table.insert(errors, 2, "")
          print("Update failed!", { timeout = 30000 })
        end
      end,
      on_stderr = function(_, err)
        table.insert(errors, err)
      end,
    })
    :sync()
end

return M
