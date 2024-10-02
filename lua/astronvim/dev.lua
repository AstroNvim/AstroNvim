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
  local pinners = {
    ["*"] = function(plugin)
      return (plugin.version and ("version = %q"):format(plugin.version)) or ("commit = %q"):format(plugin.commit)
    end,
    ["AstroNvim/AstroNvim"] = false, -- Managed by user
    ["Bilal2453/luvit-meta"] = false, -- Not a real plugin, used for type stubs only
    -- example for pinning a plugin to a specific commit for older version of neovim
    -- ["neovim/nvim-lspconfig"] = function(plugin)
    --   return ('commit = vim.fn.has "nvim-0.10" ~= 1 and "76e7c8b029e6517f3689390d6599e9b446551704" or %q'):format(
    --     plugin.commit
    --   )
    -- end,
  } --[=[@as { [string]: false|fun(plugin: LazyPlugin): string?} ]=]
  local snapshot, module = {}, "return {\n"
  for _, plugin in ipairs(plugins) do
    local pinner = vim.F.if_nil(pinners[plugin[1]], pinners["*"])
    if pinner ~= false then
      plugin = { plugin[1], commit = git_commit(plugin.dir), version = plugin.version }
      local prev_version = vim.tbl_get(prev_snapshot, plugin[1], "version")
      if prev_version then plugin.version = prev_version end
      local pin = pinner and pinner(plugin)
      if pin then
        module = module .. ("  { %q, "):format(plugin[1]) .. pin .. ", optional = true },\n"
        table.insert(snapshot, plugin)
      end
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
