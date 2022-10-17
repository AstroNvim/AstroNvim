--- ### Git LUA API
--
-- This module can be loaded with `local git = require "core.utils.git"`
--
-- @module core.utils.git
-- @copyright 2022
-- @license GNU General Public License v3.0

local git = { url = "https://github.com/" }

--- Run a git command from the AstroNvim installation directory
-- @param args the git arguments
-- @return the result of the command or nil if unsuccessful
function git.cmd(args, ...) return astronvim.cmd("git -C " .. astronvim.install.home .. " " .. args, ...) end

--- Check if the AstroNvim is able to reach the `git` command
-- @return the result of running `git --help`
function git.available() return git.cmd("--help", false) end

--- Check if the AstroNvim home is a git repo
-- @return the result of the command
function git.is_repo() return git.cmd("rev-parse --is-inside-work-tree", false) end

--- Fetch git remote
-- @param remote the remote to fetch
-- @return the result of the command
function git.fetch(remote, ...) return git.cmd("fetch " .. remote, ...) end

--- Pull the git repo
-- @return the result of the command
function git.pull(...) return git.cmd("pull --rebase", ...) end

--- Checkout git target
-- @param dest the target to checkout
-- @return the result of the command
function git.checkout(dest, ...) return git.cmd("checkout " .. dest, ...) end

--- Hard reset to a git target
-- @param dest the target to hard reset to
-- @return the result of the command
function git.hard_reset(dest, ...) return git.cmd("reset --hard " .. dest, ...) end

--- Check if a branch contains a commit
-- @param remote the git remote to check
-- @param branch the git branch to check
-- @param commit the git commit to check for
-- @return the result of the command
function git.branch_contains(remote, branch, commit, ...)
  return git.cmd("merge-base --is-ancestor " .. commit .. " " .. remote .. "/" .. branch, ...) ~= nil
end

--- Add a git remote
-- @param remote the remote to add
-- @param url the url of the remote
-- @return the result of the command
function git.remote_add(remote, url, ...) return git.cmd("remote add " .. remote .. " " .. url, ...) end

--- Update a git remote URL
-- @param remote the remote to update
-- @param url the new URL of the remote
-- @return the result of the command
function git.remote_update(remote, url, ...) return git.cmd("remote set-url " .. remote .. " " .. url, ...) end

--- Get the URL of a given git remote
-- @param remote the remote to get the URL of
-- @return the url of the remote
function git.remote_url(remote, ...) return astronvim.trim_or_nil(git.cmd("remote get-url " .. remote, ...)) end

--- Get the current version with git describe including tags
-- @return the current git describe string
function git.current_version(...) return astronvim.trim_or_nil(git.cmd("describe --tags", ...)) end

--- Get the current branch
-- @return the branch of the AstroNvim installation
function git.current_branch(...) return astronvim.trim_or_nil(git.cmd("rev-parse --abbrev-ref HEAD", ...)) end

--- Get the current head of the git repo
-- @return the head string
function git.local_head(...) return astronvim.trim_or_nil(git.cmd("rev-parse HEAD", ...)) end

--- Get the current head of a git remote
-- @param remote the remote to check
-- @param branch the branch to check
-- @return the head string of the remote branch
function git.remote_head(remote, branch, ...)
  return astronvim.trim_or_nil(git.cmd("rev-list -n 1 " .. remote .. "/" .. branch, ...))
end

--- Get the commit hash of a given tag
-- @param tag the tag to resolve
-- @return the commit hash of a git tag
function git.tag_commit(tag, ...) return astronvim.trim_or_nil(git.cmd("rev-list -n 1 " .. tag, ...)) end

--- Get the commit log between two commit hashes
-- @param start_hash the start commit hash
-- @param end_hash the end commit hash
-- @return an array like table of commit messages
function git.get_commit_range(start_hash, end_hash, ...)
  local range = ""
  if start_hash and end_hash then range = start_hash .. ".." .. end_hash end
  local log = git.cmd('log --no-merges --pretty="format:[%h] %s" ' .. range, ...)
  return log and vim.fn.split(log, "\n") or {}
end

--- Get a list of all tags with a regex filter
-- @param search a regex to search the tags with (defaults to "v*" for version tags)
-- @return an array like table of tags that match the search
function git.get_versions(search, ...)
  local tags = git.cmd('tag -l --sort=version:refname "' .. (search == "latest" and "v*" or search) .. '"', ...)
  return tags and vim.fn.split(tags, "\n") or {}
end

--- Get the latest version of a list of versions
-- @param versions a list of versions to search (defaults to all versions available)
-- @return the latest version from the array
function git.latest_version(versions, ...)
  if not versions then versions = git.get_versions(...) end
  return versions[#versions]
end

--- Parse a remote url
-- @param str the remote to parse to a full git url
-- @return the full git url for the given remote string
function git.parse_remote_url(str)
  return vim.fn.match(str, astronvim.url_matcher) == -1
      and git.url .. str .. (vim.fn.match(str, "/") == -1 and "/AstroNvim.git" or ".git")
    or str
end

--- Check if a Conventional Commit commit message is breaking or not
-- @param commit a commit message
-- @return boolean true if the message is breaking, false if the commit message is not breaking
function git.is_breaking(commit) return vim.fn.match(commit, "\\[.*\\]\\s\\+\\w\\+\\((\\w\\+)\\)\\?!:") ~= -1 end

--- Get a list of breaking commits from commit messages using Conventional Commit standard
-- @param commits an array like table of commit messages
-- @return an array like table of commits that are breaking
function git.breaking_changes(commits) return vim.tbl_filter(git.is_breaking, commits) end

--- Generate a table of commit messages for neovim's echo API with highlighting
-- @param commits an array like table of commit messages
-- @return an array like table of echo messages to provide to nvim_echo or astronvim.echo
function git.pretty_changelog(commits)
  local changelog = {}
  for _, commit in ipairs(commits) do
    local hash, type, msg = commit:match "(%[.*%])(.*:)(.*)"
    if hash and type and msg then
      vim.list_extend(
        changelog,
        { { hash, "DiffText" }, { type, git.is_breaking(commit) and "DiffDelete" or "DiffChange" }, { msg }, { "\n" } }
      )
    end
  end
  return changelog
end

return git
