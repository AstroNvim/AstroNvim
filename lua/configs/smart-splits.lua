local M = {}

function M.config()
  local present, smart_splits = pcall(require, "smart-splits")
  if present then
    smart_splits.setup(require("core.utils").user_plugin_opts("plugins.smart-splits", {
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = {
        "nofile",
        "quickfix",
        "qf",
        "prompt",
      },
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = { "nofile" },
      -- when moving cursor between splits left or right,
      -- place the cursor on the same row of the *screen*
      -- regardless of line numbers.
      -- Can be overridden via function parameter, see Usage.
      move_cursor_same_row = false,
    }))
  end
end

return M
