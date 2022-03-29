-- Configure plugins
-- set your packer nvim plugins
local M = {

  -- { "andweeb/presence.nvim" },
  -- color scheme plugin
  { "EdenEast/nightfox.nvim" },
  { "ellisonleao/gruvbox.nvim" },
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "projekt0n/github-nvim-theme" },
  -- tree sitter plugin
  {
    'nvim-treesitter/playground',
  },
  {
    "crispgm/nvim-go",
    config = function()
      require("go").setup({
        lint_prompt_style = 'vt',
      })
    end
  },
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
}

return M
