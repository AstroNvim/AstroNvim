local M = {}

function M.config()
  local status_ok, persisted = pcall(require, "persisted")
  if status_ok then
    persisted.setup(require("core.utils").user_plugin_opts("plugins.notify", {
      use_git_branch = true, -- create session files based on the branch of the git enabled repository
      autosave = false, -- automatically save session files when exiting Neovim
    }))
  end
end

return M
