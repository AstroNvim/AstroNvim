return function(_, opts)
  require("which-key").setup(opts)
  require("astrocore.utils").which_key_register()
end
