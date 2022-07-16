local git = { url = "https://github.com/" }

function git.cmd(args, ...) return astronvim.cmd("git -C " .. astronvim.install.home .. " " .. args, ...) end

function git.is_repo() return git.cmd("rev-parse --is-inside-work-tree", false) end

function git.fetch(remote, ...) return git.cmd("fetch " .. remote, ...) end

function git.pull(...) return git.cmd("pull --rebase", ...) end

function git.checkout(dest, ...) return git.cmd("checkout " .. dest, ...) end

function git.hard_reset(dest, ...) return git.cmd("reset --hard " .. dest, ...) end

function git.branch_contains(remote, branch, commit, ...)
  return git.cmd("merge-base --is-ancestor " .. commit .. " " .. remote .. "/" .. branch, ...) ~= nil
end

function git.remote_add(remote, url, ...) return git.cmd("remote add " .. remote .. " " .. url, ...) end

function git.remote_update(remote, url, ...) return git.cmd("remote set-url " .. remote .. " " .. url, ...) end

function git.remote_url(remote, ...) return astronvim.trim_or_nil(git.cmd("remote get-url " .. remote, ...)) end

function git.current_version(...) return astronvim.trim_or_nil(git.cmd("describe --tags", ...)) end

function git.current_branch(...) return astronvim.trim_or_nil(git.cmd("rev-parse --abbrev-ref HEAD", ...)) end

function git.local_head(...) return astronvim.trim_or_nil(git.cmd("rev-parse HEAD", ...)) end

function git.remote_head(remote, branch, ...)
  return astronvim.trim_or_nil(git.cmd("rev-list -n 1 " .. remote .. "/" .. branch, ...))
end

function git.tag_commit(tag, ...) return astronvim.trim_or_nil(git.cmd("rev-list -n 1 " .. tag, ...)) end

function git.get_commit_range(start_hash, end_hash, ...)
  local log = git.cmd("log --no-merges --pretty='format:[%h] %s' " .. start_hash .. ".." .. end_hash, ...)
  return log and vim.fn.split(log, "\n") or {}
end

function git.get_versions(search, ...)
  local tags = git.cmd("tag -l --sort=version:refname '" .. (search == "latest" and "v*" or search) .. "'", ...)
  return tags and vim.fn.split(tags, "\n") or {}
end

function git.latest_version(versions, ...)
  versions = versions and versions or git.get_versions(...)
  return versions[#versions]
end

function git.parse_remote_url(str)
  return vim.fn.match(str, astronvim.url_matcher) == -1
      and git.url .. str .. (vim.fn.match(str, "/") == -1 and "/AstroNvim.git" or ".git")
    or str
end

function git.breaking_changes(commits)
  return vim.tbl_filter(
    function(v) return vim.fn.match(v, "\\[.*\\]\\s\\+\\w\\+\\((\\w\\+)\\)\\?!:") ~= -1 end,
    commits
  )
end

function git.pretty_changelog(commits)
  local changelog = {}
  for _, commit in ipairs(commits) do
    local hash, type, msg = commit:match "(%[.*%])(.*:)(.*)"
    if hash and type and msg then
      vim.list_extend(changelog, { { hash, "DiffText" }, { type, "Typedef" }, { msg }, { "\n" } })
    end
  end
  return changelog
end

return git
