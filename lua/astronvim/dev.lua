local M = {}

local astrocore = require "astrocore"

--- Helper function to generate AstroNvim snapshots (For internal use only)
---@param write? false write to AstroNvim if in `dev` mode, false to force no write
---@return table # The plugin specification table of the snapshot
function M.generate_snapshot(write)
  local astronvim = assert(astrocore.get_plugin "AstroNvim")
  if write ~= false then write = astronvim.dev end
  local file
  local prev_snapshot = require "astronvim.lazy_snapshot"
  for _, plugin in ipairs(prev_snapshot) do
    prev_snapshot[plugin[1]] = plugin
  end
  local plugins = assert(require("lazy").plugins())
  table.sort(plugins, function(l, r) return l[1] < r[1] end)
  local function git_commit(dir)
    local commit = assert(astrocore.cmd({ "git", "-C", dir, "rev-parse", "HEAD" }, false))
    if commit then return vim.trim(commit) end
  end
  if write then
    file = assert(io.open(astronvim.dir .. "/lua/astronvim/lazy_snapshot.lua", "w"))
    file:write "return {\n"
  end
  local snapshot = {}
  for _, plugin in ipairs(plugins) do
    if plugin[1] ~= "AstroNvim/AstroNvim" then
      plugin = { plugin[1], commit = git_commit(plugin.dir), version = plugin.version }
      if prev_snapshot[plugin[1]] and prev_snapshot[plugin[1]].version then
        plugin.version = prev_snapshot[plugin[1]].version
      end
      if file then
        file:write(("  { %q, "):format(plugin[1]))
        if plugin.version then
          local version_format = "version = %q"
          file:write(version_format:format(plugin.version))
        else
          local commit_format = "commit = %q"
          file:write(commit_format:format(plugin.commit))
        end
        file:write ", optional = true },\n"
      end
      table.insert(snapshot, plugin)
    end
  end
  if file then
    file:write "}\n"
    file:close()
  end
  return snapshot
end

return M
