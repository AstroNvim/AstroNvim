local M = {}

function M.config()
  local status_ok, bufferline = pcall(require, "bufferline")
  if status_ok then
    bufferline.setup(require("core.utils").user_plugin_opts("plugins.bufferline", {
      options = {
        offsets = {
          { filetype = "NvimTree", text = "", padding = 1 },
          { filetype = "neo-tree", text = "", padding = 1 },
          { filetype = "Outline", text = "", padding = 1 },
        },
        buffer_close_icon = "",
        modified_icon = "",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 14,
        max_prefix_length = 13,
        tab_size = 20,
        view = "multiwindow",
        separator_style = "thin",
      },
    }))
  end
end

return M
