return function(_, opts)
  local npairs = require "nvim-autopairs"
  npairs.setup(opts)

  local astrocore = require "astrocore"
  if not astrocore.config.features.autopairs then npairs.disable() end
  astrocore.on_load(
    "nvim-cmp",
    function()
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false })
    end
  )
end
