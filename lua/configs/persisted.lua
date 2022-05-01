local M = {}

function M.config()
  local status_ok, persisted = pcall(require, "persisted")
  if status_ok then
    persisted.setup(require("core.utils").user_plugin_opts("plugins.notify", {
      dir = vim.fn.expand(vim.fn.stdpath "data" .. "/sessions/"), -- directory where session files are saved
      use_git_branch = true, -- create session files based on the branch of the git enabled repository
      autosave = false, -- automatically save session files when exiting Neovim
      autoload = false, -- automatically load the session for the cwd on Neovim startup
      allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
      ignored_dirs = nil, -- table of dirs that are ignored when auto-saving and auto-loading
    }))
  end
end

return M
