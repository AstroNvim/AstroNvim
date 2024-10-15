return {
  "neovim/nvim-lspconfig",
  specs = {
    {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>li"] =
          { "<Cmd>LspInfo<CR>", desc = "LSP information", cond = function() return vim.fn.exists ":LspInfo" > 0 end }
      end,
    },
  },
  dependencies = {
    { "folke/neoconf.nvim", lazy = true, opts = {} },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = {
        "williamboman/mason.nvim",
        { -- HACK: use separate fork until PR is merged
          -- https://github.com/williamboman/mason-lspconfig.nvim/pull/468
          "mehalter/mason-lspconfig.nvim",
          name = "mehalter-mason-lspconfig",
          lazy = true,
          config = function() vim.opt.rtp:remove(require("astrocore").get_plugin("mason-lspconfig.nvim").dir) end,
        },
      },
      cmd = { "LspInstall", "LspUninstall" },
      init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
      opts_extend = { "ensure_installed" },
      opts = {
        ensure_installed = {},
        handlers = { function(server) require("astrolsp").lsp_setup(server) end },
      },
    },
  },
  cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
    if require("lazy.core.config").spec.plugins["neoconf.nvim"] then table.insert(cmds, "Neoconf") end
    vim.list_extend(cmds, { "LspInfo", "LspLog", "LspStart" }) -- add normal `nvim-lspconfig` commands
  end,
  event = "User AstroFile",
  config = function(...) require "astronvim.plugins.configs.lspconfig"(...) end,
}
