local astronvim = require "astronvim"
astronvim.init()

return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  {
    "AstroNvim/AstroNvim",
    build = function()
      if astronvim.config.pin_plugins and astronvim.config.update_notification ~= false then
        local astrocore_avail, astrocore = pcall(require, "astrocore")
        if astrocore_avail then
          vim.schedule(
            function()
              astrocore.notify(
                "Pinned versions of core plugins may have been updated\nRun `:Lazy update` again to get these updates.",
                vim.log.levels.WARN
              )
            end
          )
        end
      end
    end,
    priority = 10000,
    lazy = false,
  },
  { import = "astronvim.lazy_snapshot", cond = astronvim.config.pin_plugins },
  {
    "AstroNvim/astrocore",
    dependencies = { "AstroNvim/astroui" },
    opts_extend = { "treesitter.ensure_installed" },
    lazy = false,
    priority = 10000,
    opts = function(_, opts)
      local get_icon = require("astroui").get_icon
      return require("astrocore").extend_tbl(opts, {
        features = {
          large_buf = {
            enabled = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
            notify = true,
            size = 1.5 * 1024 * 1024,
            lines = 100000,
            line_length = 1000,
          },
          autopairs = true, -- enable autopairs at start
          cmp = true, -- enable completion at start
          diagnostics = true, -- enable diagnostics by default
          highlighturl = true, -- highlight URLs by default
          notifications = true, -- disable notifications
        },
        diagnostics = {
          virtual_text = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = get_icon "DiagnosticError",
              [vim.diagnostic.severity.HINT] = get_icon "DiagnosticHint",
              [vim.diagnostic.severity.WARN] = get_icon "DiagnosticWarn",
              [vim.diagnostic.severity.INFO] = get_icon "DiagnosticInfo",
            },
          },
          update_in_insert = false,
          underline = true,
          severity_sort = true,
          float = {
            focused = false,
            style = "minimal",
            source = true,
            header = "",
            prefix = "",
          },
          jump = { float = true },
        },
        rooter = {
          enabled = true,
          detector = { "lsp", { ".git", "_darcs", ".hg", ".bzr", ".svn" }, { "lua", "MakeFile", "package.json" } },
          ignore = {
            servers = {},
            dirs = {},
          },
          autochdir = false,
          scope = "global",
          notify = false,
        },
        sessions = {
          autosave = { last = true, cwd = true },
          ignore = {
            dirs = {},
            filetypes = { "gitcommit", "gitrebase" },
            buftypes = {},
          },
        },
        treesitter = {
          enabled = function(_, bufnr) return not require("astrocore.buffer").is_large(bufnr) end,
          highlight = true,
          indent = true,
          auto_install = true,
          ensure_installed = { "bash", "c", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" },
          textobjects = {
            select = {
              select_textobject = {
                ["ak"] = { query = "@block.outer", desc = "around block" },
                ["ik"] = { query = "@block.inner", desc = "inside block" },
                ["ac"] = { query = "@class.outer", desc = "around class" },
                ["ic"] = { query = "@class.inner", desc = "inside class" },
                ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
                ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
                ["af"] = { query = "@function.outer", desc = "around function" },
                ["if"] = { query = "@function.inner", desc = "inside function" },
                ["ao"] = { query = "@loop.outer", desc = "around loop" },
                ["io"] = { query = "@loop.inner", desc = "inside loop" },
                ["aa"] = { query = "@parameter.outer", desc = "around argument" },
                ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
              },
            },
            move = {
              goto_next_start = {
                ["]k"] = { query = "@block.outer", desc = "Next block start" },
                ["]f"] = { query = "@function.outer", desc = "Next function start" },
                ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
              },
              goto_next_end = {
                ["]K"] = { query = "@block.outer", desc = "Next block end" },
                ["]F"] = { query = "@function.outer", desc = "Next function end" },
                ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
              },
              goto_previous_start = {
                ["[k"] = { query = "@block.outer", desc = "Previous block start" },
                ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
              },
              goto_previous_end = {
                ["[K"] = { query = "@block.outer", desc = "Previous block end" },
                ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
              },
            },
            swap = {
              swap_next = {
                [">K"] = { query = "@block.outer", desc = "Swap next block" },
                [">F"] = { query = "@function.outer", desc = "Swap next function" },
                [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
              },
              swap_previous = {
                ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
                ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
                ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
              },
            },
          },
        },
      } --[[@as AstroCoreOpts]])
    end,
  },
}
