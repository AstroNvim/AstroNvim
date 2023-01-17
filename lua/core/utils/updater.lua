--- ### AstroNvim Updater
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.updater`
--
-- This module can also be manually loaded with `local updater = require("core.utils").updater`
--
-- @module core.utils.updater
-- @see core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

local git = require "core.utils.git"
--- Updater settings overridden with any user provided configuration
local options = astronvim.user_opts("updater", { remote = "origin", channel = "stable" })

-- set the install channel
if options.branch and options.branch ~= "main" then options.channel = "nightly" end
if astronvim.install.is_stable ~= nil then options.channel = astronvim.install.is_stable and "stable" or "nightly" end

astronvim.updater = { options = options }
-- set default pin_plugins for stable branch
if options.pin_plugins == nil and options.channel == "stable" then options.pin_plugins = true end

--- the location of the snapshot of plugin commit pins for stable AstroNvim
astronvim.updater.snapshot = { module = "lazy_snapshot", path = vim.fn.stdpath "config" .. "/lua/lazy_snapshot.lua" }
astronvim.updater.rollback_file =
  { module = "astronvim_rollback", path = vim.fn.stdpath "cache" .. "/astronvim_rollback.lua" }
package.path = package.path .. ";" .. astronvim.updater.rollback_file.path

--- Helper function to generate AstroNvim snapshots (For internal use only)
-- @param write boolean whether or not to write to the snapshot file (default: false)
-- @return the plugin specification table of the snapshot
function astronvim.updater.generate_snapshot(write)
  local file
  local plugins = assert(require("lazy").plugins())
  local function git_commit(dir)
    return astronvim.trim_or_nil(assert(astronvim.cmd("git -C " .. dir .. " rev-parse HEAD", false)))
  end
  if write == true then
    file = assert(io.open(astronvim.updater.snapshot.path, "w"))
    file:write "return {\n"
  end
  local snapshot = vim.tbl_map(function(plugin)
    plugin = { plugin[1], commit = git_commit(plugin.dir), version = plugin.version }
    if file then
      file:write(("  { %q, "):format(plugin[1]))
      if plugin.version then
        file:write(("version = %q "):format(plugin.version))
      else
        file:write(("commit = %q "):format(plugin.commit))
      end
      file:write "},\n"
    end
    return plugin
  end, plugins)
  if file then
    file:write "}"
    file:close()
  end
  return snapshot
end

--- Get the current AstroNvim version
-- @param quiet boolean to quietly execute or send a notification
-- @return the current AstroNvim version string
function astronvim.updater.version(quiet)
  local version = astronvim.install.version or git.current_version(false)
  if options.channel ~= "stable" then version = ("nightly (%s)"):format(version) end
  if version and not quiet then astronvim.notify("Version: " .. version) end
  return version
end

--- Get the full AstroNvim changelog
-- @param quiet boolean to quietly execute or display the changelog
-- @return the current AstroNvim changelog table of commit messages
function astronvim.updater.changelog(quiet)
  local summary = {}
  vim.list_extend(summary, git.pretty_changelog(git.get_commit_range()))
  if not quiet then astronvim.echo(summary) end
  return summary
end

--- Attempt an update of AstroNvim
-- @param target the target if checking out a specific tag or commit or nil if just pulling
local function attempt_update(target, opts)
  -- if updating to a new stable version or a specific commit checkout the provided target
  if opts.channel == "stable" or opts.commit then
    return git.checkout(target, false)
    -- if no target, pull the latest
  else
    return git.pull(false)
  end
end

--- Cancelled update message
local cancelled_message = { { "Update cancelled", "WarningMsg" } }

--- Sync Packer and then update Mason
function astronvim.updater.update_packages()
  require("lazy").sync { wait = true }
  astronvim.mason.update_all()
end

--- Create a table of options for the currently installed AstroNvim version
-- @return the table of updater options
function astronvim.updater.create_rollback(write)
  local snapshot = { branch = git.current_branch(), commit = git.local_head() }
  snapshot.remote = git.branch_remote(snapshot.branch)
  snapshot.remotes = { [snapshot.remote] = git.remote_url(snapshot.remote) }

  if write == true then
    local file = assert(io.open(astronvim.updater.rollback_file.path, "w"))
    file:write("return " .. vim.inspect(snapshot, { newline = " ", indent = "" }))
    file:close()
  end

  return snapshot
end

--- AstroNvim's rollback to saved previous version function
function astronvim.updater.rollback()
  package.loaded[astronvim.updater.rollback_file.module] = nil
  local rollback_avail, rollback_opts = pcall(require, astronvim.updater.rollback_file.module)
  if not rollback_avail then
    astronvim.notify("No rollback file available", "error")
    return
  end
  astronvim.updater.update(rollback_opts)
end

--- AstroNvim's updater function
function astronvim.updater.update(opts)
  if not opts then opts = options end
  opts = astronvim.extend_tbl({ remote = "origin", show_changelog = true, auto_quit = false }, opts)
  -- if the git command is not available, then throw an error
  if not git.available() then
    astronvim.notify(
      "git command is not available, please verify it is accessible in a command line. This may be an issue with your PATH",
      "error"
    )
    return
  end

  -- if installed with an external package manager, disable the internal updater
  if not git.is_repo() then
    astronvim.notify("Updater not available for non-git installations", "error")
    return
  end
  -- set up any remotes defined by the user if they do not exist
  for remote, entry in pairs(opts.remotes and opts.remotes or {}) do
    local url = git.parse_remote_url(entry)
    local current_url = git.remote_url(remote, false)
    local check_needed = false
    if not current_url then
      git.remote_add(remote, url)
      check_needed = true
    elseif
      current_url ~= url
      and astronvim.confirm_prompt {
        { "Remote " },
        { remote, "Title" },
        { " is currently set to " },
        { current_url, "WarningMsg" },
        { "\nWould you like us to set it to " },
        { url, "String" },
        { "?" },
      }
    then
      git.remote_update(remote, url)
      check_needed = true
    end
    if check_needed and git.remote_url(remote, false) ~= url then
      vim.api.nvim_err_writeln("Error setting up remote " .. remote .. " to " .. url)
      return
    end
  end
  local is_stable = opts.channel == "stable"
  if is_stable then
    opts.branch = "main"
  elseif not opts.branch then
    opts.branch = "nightly"
  end
  -- fetch the latest remote
  if not git.fetch(opts.remote) then
    vim.api.nvim_err_writeln("Error fetching remote: " .. opts.remote)
    return
  end
  -- switch to the necessary branch only if not on the stable channel
  if not is_stable then
    local local_branch = (opts.remote == "origin" and "" or (opts.remote .. "_")) .. opts.branch
    if git.current_branch() ~= local_branch then
      astronvim.echo {
        { "Switching to branch: " },
        { opts.remote .. "/" .. opts.branch .. "\n\n", "String" },
      }
      if not git.checkout(local_branch, false) then
        git.checkout("-b " .. local_branch .. " " .. opts.remote .. "/" .. opts.branch, false)
      end
    end
    -- check if the branch was switched to successfully
    if git.current_branch() ~= local_branch then
      vim.api.nvim_err_writeln("Error checking out branch: " .. opts.remote .. "/" .. opts.branch)
      return
    end
  end
  local source = git.local_head() -- calculate current commit
  local target -- calculate target commit
  if is_stable then -- if stable get tag commit
    local version_search = opts.version or "latest"
    opts.version = git.latest_version(git.get_versions(version_search))
    if not opts.version then -- continue only if stable version is found
      vim.api.nvim_err_writeln("Error finding version: " .. version_search)
      return
    end
    target = git.tag_commit(opts.version)
  elseif opts.commit then -- if commit specified use it
    target = git.branch_contains(opts.remote, opts.branch, opts.commit) and opts.commit or nil
  else -- get most recent commit
    target = git.remote_head(opts.remote, opts.branch)
  end
  if not source or not target then -- continue if current and target commits were found
    vim.api.nvim_err_writeln "Error checking for updates"
    return
  elseif source == target then
    astronvim.echo { { "No updates available", "String" } }
    return
  elseif -- prompt user if they want to accept update
    not opts.skip_prompts
    and not astronvim.confirm_prompt {
      { "Update available to ", "Title" },
      { is_stable and opts.version or target, "String" },
      { "\nUpdating requires a restart, continue?" },
    }
  then
    astronvim.echo(cancelled_message)
    return
  else -- perform update
    astronvim.updater.create_rollback(true) -- create rollback file before updating
    -- calculate and print the changelog
    local changelog = git.get_commit_range(source, target)
    local breaking = git.breaking_changes(changelog)
    local breaking_prompt = { { "Update contains the following breaking changes:\n", "WarningMsg" } }
    vim.list_extend(breaking_prompt, git.pretty_changelog(breaking))
    vim.list_extend(breaking_prompt, { { "\nWould you like to continue?" } })
    if #breaking > 0 and not opts.skip_prompts and not astronvim.confirm_prompt(breaking_prompt) then
      astronvim.echo(cancelled_message)
      return
    end
    -- attempt an update
    local updated = attempt_update(target, opts)
    -- check for local file conflicts and prompt user to continue or abort
    if
      not updated
      and not opts.skip_prompts
      and not astronvim.confirm_prompt {
        { "Unable to pull due to local modifications to base files.\n", "ErrorMsg" },
        { "Reset local files and continue?" },
      }
    then
      astronvim.echo(cancelled_message)
      return
      -- if continued and there were errors reset the base config and attempt another update
    elseif not updated then
      git.hard_reset(source)
      updated = attempt_update(target, opts)
    end
    -- if update was unsuccessful throw an error
    if not updated then
      vim.api.nvim_err_writeln "Error ocurred performing update"
      return
    end
    -- print a summary of the update with the changelog
    local summary = {
      { "AstroNvim updated successfully to ", "Title" },
      { git.current_version(), "String" },
      { "!\n", "Title" },
      {
        opts.auto_quit and "AstroNvim will now update plugins and quit.\n\n"
          or "After plugins update, please restart.\n\n",
        "WarningMsg",
      },
    }
    if opts.show_changelog and #changelog > 0 then
      vim.list_extend(summary, { { "Changelog:\n", "Title" } })
      vim.list_extend(summary, git.pretty_changelog(changelog))
    end
    astronvim.echo(summary)

    -- if the user wants to auto quit, create an autocommand to quit AstroNvim on the update completing
    if opts.auto_quit then
      vim.api.nvim_create_autocmd("User", { pattern = "AstroUpdateComplete", command = "quitall" })
    end

    require("lazy.core.plugin").load() -- force immediate reload of lazy
    require("lazy").sync { wait = true } -- sync new plugin spec changes
    astronvim.event "UpdateComplete"
  end
end
