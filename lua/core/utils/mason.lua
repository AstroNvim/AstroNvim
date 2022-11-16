--- ### AstroNvim Mason Utils
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.mason`
--
-- This module can also be manually loaded with `local updater = require("core.utils").mason`
--
-- @module core.utils.mason
-- @see core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

astronvim.mason = {}

--- Update a mason package
-- @param pkg_name string of the name of the package as defined in Mason (Not mason-lspconfig or mason-null-ls)
-- @param auto_install boolean of whether or not to install a package that is not currently installed (default: True)
function astronvim.mason.update(pkg_name, auto_install)
  if auto_install == nil then auto_install = true end
  local registry_avail, registry = pcall(require, "mason-registry")
  if not registry_avail then
    vim.api.nvim_err_writeln "Unable to access mason registry"
    return
  end

  local pkg_avail, pkg = pcall(registry.get_package, pkg_name)
  if not pkg_avail then
    astronvim.notify(("Mason: %s is not available"):format(pkg_name), "error")
  else
    if not pkg:is_installed() then
      if auto_install then
        astronvim.notify(("Mason: Installing %s"):format(pkg.name))
        pkg:install()
      else
        astronvim.notify(("Mason: %s not installed"):format(pkg.name), "warn")
      end
    else
      pkg:check_new_version(function(update_available, version)
        if update_available then
          astronvim.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
          pkg:install():on("closed", function() astronvim.notify(("Mason: Updated %s"):format(pkg.name)) end)
        else
          astronvim.notify(("Mason: No updates available for %s"):format(pkg.name))
        end
      end)
    end
  end
end

--- Update all packages in Mason
function astronvim.mason.update_all()
  local registry_avail, registry = pcall(require, "mason-registry")
  if not registry_avail then
    vim.api.nvim_err_writeln "Unable to access mason registry"
    return
  end

  local any_pkgs = false
  local running = 0
  local updated = false
  astronvim.notify "Mason: Checking for package updates..."

  for _, pkg in ipairs(registry.get_installed_packages()) do
    any_pkgs = true
    running = running + 1
    pkg:check_new_version(function(update_available, version)
      if update_available then
        updated = true
        running = running - 1
        astronvim.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
        pkg:install():on("closed", function()
          running = running - 1
          if running == 0 then
            astronvim.notify "Mason: Update Complete"
            astronvim.event "MasonUpdateComplete"
          end
        end)
      else
        running = running - 1
        if running == 0 then
          if updated then
            astronvim.notify "Mason: Update Complete"
          else
            astronvim.notify "Mason: No updates available"
          end
          astronvim.event "MasonUpdateComplete"
        end
      end
    end)
  end
  if not any_pkgs then
    astronvim.notify "Mason: No updates available"
    astronvim.event "MasonUpdateComplete"
  end
end

return astronvim.mason
