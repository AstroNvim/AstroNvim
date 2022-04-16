local M = {}

M.config = function()
  local status_ok, presence = pcall(require, "presence")
  if not status_ok then
    return
  end

  presence:setup {
    auto_update = true,
    neovim_image_text = "LunarVim to the moon",
    main_image = "file",
    client_id = "793271441293967371",
    log_level = nil,
    debounce_timeout = 10,
    enable_line_number = true, -- Displays the current line number instead of the current project
    editing_text = "Editing %s", -- string rendered when an editable file is loaded in the buffer
    file_explorer_text = "Browsing %s", -- Format string rendered when browsing a file explorer
    git_commit_text = "Committing changes", -- string rendered when commiting changes in git
    plugin_manager_text = "Managing plugins", -- Format string rendered when managing plugins
    reading_text = "Reading %s", -- string rendered when a read-only file is loaded in the buffer
    workspace_text = "Working on %s", -- Workspace format string (either string or function(git_project_name: string|nil, buffer: string): string)
    line_number_text = "Line %s out of %s", -- Line number string (for when enable_line_number is set to true)
  }
end

return M
