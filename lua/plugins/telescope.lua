return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
  },
  cmd = "Telescope",
  opts = function()
    local actions = require "telescope.actions"
    local get_icon = require("astronvim.utils").get_icon
    local mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = { ["q"] = actions.close },
    }
    -- HACK: remove after Telescope mode issue is resolved: https://github.com/nvim-telescope/telescope.nvim/issues/2501
    if vim.fn.has "nvim-0.10" == 1 then
      for _, key in ipairs { "<CR>", "<C-x>", "<C-v>", "<C-t>", "<C-q>", "<M-q>" } do
        mappings.i[key] = function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>" .. key, true, false, true), "i", false)
        end
      end
    end
    return {
      defaults = {
        prompt_prefix = get_icon("Selected", 1),
        selection_caret = get_icon("Selected", 1),
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = mappings,
      },
    }
  end,
  config = require "plugins.configs.telescope",
}
