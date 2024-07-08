return {
  "nvimtools/none-ls.nvim",
  main = "null-ls",
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>lI"] = {
          "<Cmd>NullLsInfo<CR>",
          desc = "Null-ls information",
          cond = function() return vim.fn.exists ":NullLsInfo" > 0 end,
        }
      end,
    },
  },
  dependencies = {
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = { "williamboman/mason.nvim" },
      cmd = { "NullLsInstall", "NullLsUninstall" },
      init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
      opts_extend = { "ensure_installed" },
      opts = { ensure_installed = {}, handlers = {} },
    },
  },
  event = "User AstroFile",
  opts = function() return { on_attach = require("astrolsp").on_attach } end,
}
