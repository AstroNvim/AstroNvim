local fn = vim.fn
local git = require "core.utils.git"
local options = astronvim.user_plugin_opts(
  "updater",
  { remote = "origin", branch = "main", channel = "nightly", pin_plugins = true, show_changelog = true }
)

astronvim.updater = { options = options }
options.pin_plugins = options.pin_plugins == true and options.channel == "stable" and git.current_version()
  or options.pin_plugins
if type(options.pin_plugins) == "string" then
  local loaded, snapshot_file = pcall(fn.readfile, fn.stdpath "config" .. "/snapshots/" .. options.pin_plugins)
  if loaded then
    local _, snapshot = pcall(fn.json_decode, snapshot_file)
    astronvim.updater.snapshot = type(snapshot) == "table" and snapshot or nil
  end
end

function astronvim.updater.version()
  local version = git.current_version()
  if version then
    vim.notify("Version: " .. version, "info", astronvim.base_notification)
  end
end

local function echo_cancelled()
  astronvim.echo { { "Update cancelled", "WarningMsg" } }
end

local function pretty_changelog(commits)
  local changelog = {}
  for _, commit in ipairs(commits) do
    local hash, type, title = commit:match "(%[.*%])(.*:)(.*)"
    if hash and type and title then
      vim.list_extend(changelog, { { hash, "DiffText" }, { type, "Typedef" }, { title, "Title" }, { "\n" } })
    end
  end
  return changelog
end

function astronvim.updater.update()
  for remote, entry in pairs(options.remotes and options.remotes or {}) do
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
  local is_stable = options.channel == "stable"
  options.branch = is_stable and "main" or options.branch
  if not git.fetch(options.remote) then
    vim.api.nvim_err_writeln("Error fetching remote: " .. options.remote)
  end
  local local_branch = (options.remote == "origin" and "" or (options.remote .. "_")) .. options.branch
  if git.current_branch() ~= local_branch then
    astronvim.echo {
      { "Switching to branch: " },
      { options.remote .. "/" .. options.branch .. "\n\n", "String" },
    }
    if not git.checkout(local_branch, false) then
      git.checkout("-b " .. local_branch .. " " .. options.remote .. "/" .. options.branch, false)
    end
  end
  if git.current_branch() ~= local_branch then
    vim.api.nvim_err_writeln("Error checking out branch: " .. options.remote .. "/" .. options.branch)
    return
  end
  local source = git.local_head() -- calculate current commit
  local target -- calculate target commit
  if is_stable then -- if stable get tag commit
    options.version = git.latest_version(git.get_versions(options.version or "latest"))
    target = git.tag_commit(options.version)
  elseif options.commit then -- if commit specified use it
    target = git.branch_contains(options.remote, options.branch, options.commit) and options.commit or nil
  else -- get most recent commit
    target = git.remote_head(options.remote, options.branch)
  end
  if source and target then -- continue if current and target commits were found
    if source == target then
      astronvim.echo { { "No updates available", "String" } }
    elseif -- prompt user if they want to accept update
      not options.skip_prompts
      and not astronvim.confirm_prompt {
        { "Update available to ", "Title" },
        { is_stable and options.version or target, "String" },
        { "\nContinue?" },
      }
    then
      echo_cancelled()
      return
    else -- perform update
      local changelog = git.get_commit_range(source, target)
      local breaking = git.breaking_changes(changelog)
      local breaking_prompt = { { "Update contains the following breaking changes:\n", "WarningMsg" } }
      vim.list_extend(breaking_prompt, pretty_changelog(breaking))
      vim.list_extend(breaking_prompt, { { "\nWould you like to continue?" } })
      if #breaking > 0 and not options.skip_prompts and not astronvim.confirm_prompt(breaking_prompt) then
        echo_cancelled()
        return
      end
      local function attempt_update() -- helper function to attempt an update
        if is_stable or options.commit then
          return git.checkout(target, false)
        else
          return git.pull(false)
        end
      end
      local updated = attempt_update()
      if
        not updated
        and not options.skip_prompts
        and not astronvim.confirm_prompt {
          { "Unable to pull due to local modifications to base files.\n", "ErrorMsg" },
          { "Reset local files and continue?" },
        }
      then
        echo_cancelled()
        return
      elseif not updated then
        git.hard_reset(source)
        updated = attempt_update()
      end
      if not updated then
        vim.api.nvim_err_writeln "Error ocurred performing update"
        return
      end
      local summary = {
        { "AstroNvim updated successfully to ", "Title" },
        { git.current_version(), "String" },
        { "!\n", "Title" },
        { "Please restart and run :PackerSync.\n\n", "WarningMsg" },
      }
      if #changelog > 0 then
        vim.list_extend(summary, { { "Changelog:\n" } })
        vim.list_extend(summary, pretty_changelog(changelog))
      end
      astronvim.echo(summary)
    end
  end
end
