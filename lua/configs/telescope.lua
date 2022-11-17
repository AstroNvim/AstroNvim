local telescope = require "telescope"
local actions = require "telescope.actions"

telescope.setup(astronvim.user_plugin_opts("plugins.telescope", {
  defaults = {

    prompt_prefix = string.format("%s ", astronvim.get_icon "Search"),
    selection_caret = string.format("%s ", astronvim.get_icon "Selected"),
    path_display = { "truncate" },
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },

    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = { ["q"] = actions.close },
    },
  },
}))

astronvim.conditional_func(telescope.load_extension, pcall(require, "notify"), "notify")
astronvim.conditional_func(telescope.load_extension, pcall(require, "aerial"), "aerial")
