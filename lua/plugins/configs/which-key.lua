return function(_, opts)
  require("which-key").setup(opts)
  require("astronvim.utils").which_key_register()
end
