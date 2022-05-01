local M = {}

function M.config()
  local status_ok, persisted = pcall(require, "persisted")
  if status_ok then
    persisted.setup(require("core.utils").user_plugin_opts("plugins.notify", {
      dir = vim.fn.expand(vim.fn.stdpath "data" .. "/sessions/"), -- directory where session files are saved
      use_git_branch = false, -- create session files based on the branch of the git enabled repository
      autosave = true, -- automatically save session files when exiting Neovim
      autoload = true, -- automatically load the session for the cwd on Neovim startup
      allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
      ignored_dirs = nil, -- table of dirs that are ignored when auto-saving and auto-loading
      before_save = function()
        vim.api.nvim_create_augroup("before_save", {})
        vim.api.nvim_create_autocmd("BufWinLeave", {
          desc = "close neotree and aerial when saving a session",
          group = "before_save",
          pattern = "*",
          command = "Neotree close | AerialClose",
        })
      end, -- function to run before the session is saved to disk
    }))
  end
end

return M
