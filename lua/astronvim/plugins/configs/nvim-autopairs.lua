return function(_, opts)
  local npairs = require "nvim-autopairs"
  npairs.setup(opts)

  local astrocore = require "astrocore"
  if not astrocore.config.features.autopairs then npairs.disable() end
end
