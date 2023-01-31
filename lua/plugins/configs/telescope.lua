return function(_, opts)
  local telescope = require "telescope"
  telescope.setup(opts)
  astronvim.conditional_func(telescope.load_extension, pcall(require, "notify"), "notify")
  astronvim.conditional_func(telescope.load_extension, pcall(require, "aerial"), "aerial")
  astronvim.conditional_func(telescope.load_extension, astronvim.is_available "telescope-fzf-native.nvim", "fzf")
end
