local M = {}

local astrocore = require "astrocore"

--- Helper function to generate AstroNvim snapshots (For internal use only)
---@param write? false write to AstroNvim if in `dev` mode, false to force no write
---@return table # The plugin specification table of the snapshot
function M.generate_snapshot(write)
  local astronvim = assert(astrocore.get_plugin "AstroNvim")
  if write ~= false then write = astronvim.dev end
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
  local snapshot, module = {}, "return {\n"
  local untracked_plugins = {
    "AstroNvim/AstroNvim", -- Managed by user
    "Bilal2453/luvit-meta", -- Not a real plugin, used for type stubs only
  }
  for _, plugin in ipairs(plugins) do
    if not vim.tbl_contains(untracked_plugins, plugin[1]) then
      plugin = { plugin[1], commit = git_commit(plugin.dir), version = plugin.version }
      if prev_snapshot[plugin[1]] and prev_snapshot[plugin[1]].version then
        plugin.version = prev_snapshot[plugin[1]].version
      end
      module = module .. ("  { %q, "):format(plugin[1])
      if plugin.version then
        module = module .. ("version = %q"):format(plugin.version)
      else
        module = module .. ("commit = %q"):format(plugin.commit)
      end
      module = module .. ", optional = true },\n"
      table.insert(snapshot, plugin)
    end
  end
  module = module .. "}\n"
  if write then
    local snapshot_file = astronvim.dir .. "/lua/astronvim/lazy_snapshot.lua"
    astrocore.with_file(snapshot_file, "w+", function(file) file:write(module) end)
  end
  return snapshot
end

return M
