return {
  -- TODO: replace with nvim-highlight-colors: https://github.com/brenoprata10/nvim-highlight-colors
  "NvChad/nvim-colorizer.lua",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>uz"] = { "<Cmd>ColorizerToggle<CR>", desc = "Toggle color highlight" }
      end,
    },
  },
  event = "User AstroFile",
  cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
  opts = { user_default_options = { names = false } },
  config = function(...) require "astronvim.plugins.configs.colorizer"(...) end,
}
