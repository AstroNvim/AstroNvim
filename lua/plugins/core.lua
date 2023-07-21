return {
  "nvim-lua/plenary.nvim",
  "echasnovski/mini.bufremove",
  { "AstroNvim/astrotheme", opts = { plugins = { ["dashboard-nvim"] = true } } },
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { timeout = 300 } },
  { "NMAC427/guess-indent.nvim", event = "User AstroFile", config = require "plugins.configs.guess-indent" },
  {
    "stevearc/resession.nvim",
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "resession.nvim" then
            maps.n["<leader>S"] = opts._map_section.S
            maps.n["<leader>Sl"] =
              { function() require("resession").load "Last Session" end, desc = "Load last session" }
            maps.n["<leader>Ss"] = { function() require("resession").save() end, desc = "Save this session" }
            maps.n["<leader>St"] = { function() require("resession").save_tab() end, desc = "Save this tab's session" }
            maps.n["<leader>Sd"] = { function() require("resession").delete() end, desc = "Delete a session" }
            maps.n["<leader>Sf"] = { function() require("resession").load() end, desc = "Load a session" }
            maps.n["<leader>S."] = {
              function() require("resession").load(vim.fn.getcwd(), { dir = "dirsession" }) end,
              desc = "Load current directory session",
            }
          end
        end,
      },
    },
    opts = {
      buf_filter = function(bufnr) return require("astrocore.buffer").is_restorable(bufnr) end,
      tab_buf_filter = function(tabpage, bufnr) return vim.tbl_contains(vim.t[tabpage].bufs, bufnr) end,
      extensions = { astrocore = {} },
    },
  },
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    opts = { picker_config = { statusline_winbar_picker = { use_winbar = "smart" } } },
  },
  {
    "mrjones2014/smart-splits.nvim",
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "smart-splits.nvim" then
            maps.n["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
            maps.n["<C-j>"] =
              { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
            maps.n["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
            maps.n["<C-l>"] =
              { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
            maps.n["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
            maps.n["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
            maps.n["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
            maps.n["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
          end
        end,
      },
    },
    opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = { java = false },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = require "plugins.configs.nvim-autopairs",
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { group = vim.g.icons_enabled and "" or "+", separator = "" },
      disable = { filetypes = { "TelescopePrompt" } },
    },
    config = require "plugins.configs.which-key",
  },
  {
    "kevinhwang91/nvim-ufo",
    event = { "User AstroFile", "InsertEnter" },
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "nvim-ufo" then
            maps.n["zR"] = { function() require("ufo").openAllFolds() end, desc = "Open all folds" }
            maps.n["zM"] = { function() require("ufo").closeAllFolds() end, desc = "Close all folds" }
            maps.n["zr"] = { function() require("ufo").openFoldsExceptKinds() end, desc = "Fold less" }
            maps.n["zm"] = { function() require("ufo").closeFoldsWith() end, desc = "Fold more" }
            maps.n["zp"] = { function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" }
          end
        end,
      },
    },
    opts = {
      preview = {
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      provider_selector = function(_, filetype, buftype)
        local function handleFallbackException(bufnr, err, providerName)
          if type(err) == "string" and err:match "UfoFallbackException" then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
          or function(bufnr)
            return require("ufo")
              .getFolds(bufnr, "lsp")
              :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
              :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
          end
      end,
    },
  },
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          if require("astrocore.utils").is_available "Comment.nvim" then
            maps.n["<leader>/"] = {
              function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
              desc = "Toggle comment line",
            }
            maps.v["<leader>/"] = {
              "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
              desc = "Toggle comment for selection",
            }
          end
        end,
      },
    },
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local utils = require "astrocore.utils"
          if utils.is_available "toggleterm.nvim" then
            maps.n["<leader>t"] = opts._map_section.t
            if vim.fn.executable "lazygit" == 1 then
              maps.n["<leader>g"] = opts._map_section.g
              maps.n["<leader>gg"] = {
                function()
                  local worktree = require("astrocore.git").file_worktree()
                  local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir)
                    or ""
                  utils.toggle_term_cmd("lazygit " .. flags)
                end,
                desc = "ToggleTerm lazygit",
              }
              maps.n["<leader>tl"] = maps.n["<leader>gg"]
            end
            if vim.fn.executable "node" == 1 then
              maps.n["<leader>tn"] = { function() utils.toggle_term_cmd "node" end, desc = "ToggleTerm node" }
            end
            if vim.fn.executable "gdu" == 1 then
              maps.n["<leader>tu"] = { function() utils.toggle_term_cmd "gdu" end, desc = "ToggleTerm gdu" }
            end
            if vim.fn.executable "btm" == 1 then
              maps.n["<leader>tt"] = { function() utils.toggle_term_cmd "btm" end, desc = "ToggleTerm btm" }
            end
            local python = vim.fn.executable "python" == 1 and "python"
              or vim.fn.executable "python3" == 1 and "python3"
            if python then
              maps.n["<leader>tp"] = { function() utils.toggle_term_cmd(python) end, desc = "ToggleTerm python" }
            end
            maps.n["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
            maps.n["<leader>th"] =
              { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
            maps.n["<leader>tv"] =
              { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
            maps.n["<F7>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" }
            maps.t["<F7>"] = maps.n["<F7>"]
            maps.n["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
            maps.t["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
          end
        end,
      },
    },
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = "0"
        vim.opt.signcolumn = "no"
      end,
      open_mapping = [[<F7>]],
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },
}
