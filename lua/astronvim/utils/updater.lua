--- ### AstroNvim Updater
--
-- AstroNvim Updater utilities to use within AstroNvim and user configurations.
--
-- This module can also loaded with `local updater = require("astronvim.utils.updater")`
--
-- @module astronvim.utils.updater
-- @see astronvim.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

local git = require "astronvim.utils.git"

local M = {}

local utils = require "astronvim.utils"
local notify = utils.notify

local function echo(messages)
  -- if no parameter provided, echo a new line
  messages = messages or { { "\n" } }
  if type(messages) == "table" then vim.api.nvim_echo(messages, false, {}) end
end

local function confirm_prompt(messages)
  if messages then echo(messages) end
  local confirmed = string.lower(vim.fn.input "(y/n) ") == "y"
  echo()
  echo()
  return confirmed
end

--- Helper function to generate AstroNvim snapshots (For internal use only)
-- @param write boolean whether or not to write to the snapshot file (default: false)
-- @return the plugin specification table of the snapshot
function M.generate_snapshot(write)
  local file
  local prev_snapshot = require(astronvim.updater.snapshot.module)
  for _, plugin in ipairs(prev_snapshot) do
    prev_snapshot[plugin[1]] = plugin
  end
  local plugins = assert(require("lazy").plugins())
  local function git_commit(dir)
    local commit = assert(utils.cmd("git -C " .. dir .. " rev-parse HEAD", false))
    if commit then return vim.trim(commit) end
  end
  if write == true then
    file = assert(io.open(astronvim.updater.snapshot.path, "w"))
    file:write "return {\n"
  end
  local snapshot = vim.tbl_map(function(plugin)
    if not plugin[1] and plugin.name == "lazy.nvim" then plugin[1] = "folke/lazy.nvim" end
    plugin = { plugin[1], commit = git_commit(plugin.dir), version = plugin.version }
    if prev_snapshot[plugin[1]] and prev_snapshot[plugin[1]].version then
      plugin.version = prev_snapshot[plugin[1]].version
    end
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
function M.version(quiet)
  local version = astronvim.install.version or git.current_version(false) or "unknown"
  if astronvim.updater.options.channel ~= "stable" then version = ("nightly (%s)"):format(version) end
  if version and not quiet then notify("Version: " .. version) end
  return version
end

--- Get the full AstroNvim changelog
-- @param quiet boolean to quietly execute or display the changelog
-- @return the current AstroNvim changelog table of commit messages
function M.changelog(quiet)
  local summary = {}
  vim.list_extend(summary, git.pretty_changelog(git.get_commit_range()))
  if not quiet then echo(summary) end
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
function M.update_packages()
  require("lazy").sync { wait = true }
  require("astronvim.utils.mason").update_all()
end

--- Create a table of options for the currently installed AstroNvim version
-- @return the table of updater options
function M.create_rollback(write)
  local snapshot = { branch = git.current_branch(), commit = git.local_head() }
  if snapshot.branch == "HEAD" then snapshot.branch = "main" end
  snapshot.remote = git.branch_remote(snapshot.branch)
  snapshot.remotes = { [snapshot.remote] = git.remote_url(snapshot.remote) }

  if write == true then
    local file = assert(io.open(astronvim.updater.rollback_file, "w"))
    file:write("return " .. vim.inspect(snapshot, { newline = " ", indent = "" }))
    file:close()
  end

  return snapshot
end

--- AstroNvim's rollback to saved previous version function
function M.rollback()
  local rollback_avail, rollback_opts = pcall(dofile, astronvim.updater.rollback_file)
  if not rollback_avail then
    notify("No rollback file available", "error")
    return
  end
  M.update(rollback_opts)
end

--- AstroNvim's updater function
function M.update(opts)
  if not opts then opts = astronvim.updater.options end
  opts = require("astronvim.utils").extend_tbl({ remote = "origin", show_changelog = true, auto_quit = false }, opts)
  -- if the git command is not available, then throw an error
  if not git.available() then
    notify(
      "git command is not available, please verify it is accessible in a command line. This may be an issue with your PATH",
      "error"
    )
    return
  end

  -- if installed with an external package manager, disable the internal updater
  if not git.is_repo() then
    notify("Updater not available for non-git installations", "error")
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
      and confirm_prompt {
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
      echo {
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
    echo { { "No updates available", "String" } }
    return
  elseif -- prompt user if they want to accept update
    not opts.skip_prompts
    and not confirm_prompt {
      { "Update available to ", "Title" },
      { is_stable and opts.version or target, "String" },
      { "\nUpdating requires a restart, continue?" },
    }
  then
    echo(cancelled_message)
    return
  else -- perform update
    M.create_rollback(true) -- create rollback file before updating
    -- calculate and print the changelog
    local changelog = git.get_commit_range(source, target)
    local breaking = git.breaking_changes(changelog)
    local breaking_prompt = { { "Update contains the following breaking changes:\n", "WarningMsg" } }
    vim.list_extend(breaking_prompt, git.pretty_changelog(breaking))
    vim.list_extend(breaking_prompt, { { "\nWould you like to continue?" } })
    if #breaking > 0 and not opts.skip_prompts and not confirm_prompt(breaking_prompt) then
      echo(cancelled_message)
      return
    end
    -- attempt an update
    local updated = attempt_update(target, opts)
    -- check for local file conflicts and prompt user to continue or abort
    if
      not updated
      and not opts.skip_prompts
      and not confirm_prompt {
        { "Unable to pull due to local modifications to base files.\n", "ErrorMsg" },
        { "Reset local files and continue?" },
      }
    then
      echo(cancelled_message)
      return
    -- if continued and there were errors reset the base config and attempt another update
    elseif not updated then
      git.hard_reset(source)
      updated = attempt_update(target, opts)
    end
    -- if update was unsuccessful throw an error
    if not updated then
      vim.api.nvim_err_writeln "Error occurred performing update"
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
    echo(summary)

    -- if the user wants to auto quit, create an autocommand to quit AstroNvim on the update completing
    if opts.auto_quit then
      vim.api.nvim_create_autocmd("User", { pattern = "AstroUpdateComplete", command = "quitall" })
    end

    require("lazy.core.plugin").load() -- force immediate reload of lazy
    require("lazy").sync { wait = true } -- sync new plugin spec changes
    utils.event "UpdateComplete"
  end
end

return M
