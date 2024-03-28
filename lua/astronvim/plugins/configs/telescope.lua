return function(_, opts)
  local telescope = require "telescope"
  telescope.setup(opts)
  local is_available = require("astrocore").is_available
  if is_available "nvim-notify" then telescope.load_extension "notify" end
  if is_available "aerial.nvim" then telescope.load_extension "aerial" end
  if is_available "telescope-fzf-native.nvim" then telescope.load_extension "fzf" end
end
