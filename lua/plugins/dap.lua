return {
    {
      "mfussenegger/nvim-dap",
      enabled = vim.fn.has "win32" == 0,
      dependencies = {
        {
          "jay-babu/mason-nvim-dap.nvim",
          dependencies = { "nvim-dap" },
          cmd = { "DapInstall", "DapUninstall" },
          opts = { handlers = {} },
        },
        {
          "rcarriga/nvim-dap-ui",
          opts = { floating = { border = "rounded" } },
          config = require "plugins.configs.nvim-dap-ui",
        },
        {
          "rcarriga/cmp-dap",
          dependencies = { "nvim-cmp" },
          config = require "plugins.configs.cmp-dap",
        },
      },
      event = "User AstroFile",
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    event = "User AstroFile",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
  },
}

