return {
  "nvimtools/none-ls.nvim",
  main = "null-ls",
  dependencies = {
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
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = { "williamboman/mason.nvim", { "nvimtools/none-ls-extras.nvim", lazy = true } },
      cmd = { "NullLsInstall", "NullLsUninstall" },
      init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
      opts = {
        handlers = {
          function(source, types)
            local null_ls = require "null-ls"
            if not null_ls.is_registered(source) then
              if next(types) then
                vim.tbl_map(function(type) null_ls.register(null_ls.builtins[type][source]) end, types)
              elseif require("astrocore").is_available "none-ls-extras.nvim" then
                for method, enabled in pairs(require("mason-null-ls.settings").current.methods) do
                  if enabled then table.insert(types, method) end
                end
                for _, type in ipairs(types) do
                  local builtin_avail, builtin = pcall(require, ("none-ls.%s.%s"):format(type, source))
                  if builtin_avail then null_ls.register(builtin) end
                end
              end
            end
          end,
        },
      },
    },
  },
  event = "User AstroFile",
  opts = function() return { on_attach = require("astrolsp").on_attach } end,
}
