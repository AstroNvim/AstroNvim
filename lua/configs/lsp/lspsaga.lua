local M = {}

function M.config()
  local status_ok, lspsaga = pcall(require, "lspsaga")
  if not status_ok then
    return
  end

  lspsaga.setup(require("core.utils").user_plugin_opts("lspsaga", {
    debug = false,
    use_saga_diagnostic_sign = false,
    -- Diagnostics
    error_sign = "",
    warn_sign = "",
    hint_sign = "",
    infor_sign = "",
    diagnostic_header_icon = "   ",
    -- Code actions
    code_action_icon = " ",
    code_action_prompt = {
      enable = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    finder_definition_icon = "  ",
    finder_reference_icon = "  ",
    max_preview_lines = 10,
    finder_action_keys = {
      open = "o",
      vsplit = "s",
      split = "i",
      quit = "q",
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },
    code_action_keys = {
      quit = "q",
      exec = "<CR>",
    },
    rename_action_keys = {
      quit = "<C-c>",
      exec = "<CR>",
    },
    definition_preview_icon = "  ",
    border_style = "round",
    rename_prompt_prefix = "➤ ",
    server_filetype_map = {},
    diagnostic_prefix_format = "%d. ",
  }))
end

return M
