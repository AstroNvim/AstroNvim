return {
  "windwp/nvim-ts-autotag",
  event = "User AstroFile",
  opts = {},
  config = function(...) require "astronvim.plugins.configs.ts-autotag"(...) end,
}
