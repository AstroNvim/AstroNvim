return {
  "stevearc/dressing.nvim",
  lazy = true,
  init = function() require("astrocore").load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" }) end,
  opts = function()
    local get_icon = require("astroui").get_icon
    return {
      input = { default_prompt = get_icon("Selected", 1) },
    }
  end,
}
