return function(_, opts)
  require("which-key").setup(opts)
  require("core.utils").which_key_register()
end
