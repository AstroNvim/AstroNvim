return {
  "nvim-lua/plenary.nvim",
  { "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout" } },
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    },
    default_config = function(opts) require("smart-splits").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "Shatur/neovim-session-manager",
    event = "BufWritePost",
    cmd = "SessionManager",
    default_config = function(opts) require("session_manager").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "s1n7ax/nvim-window-picker",
    opts = function() return { use_winbar = "smart", other_win_hl_color = require("astronvim.colors").grey_4 } end,
    default_config = function(opts) require("window-picker").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
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
    default_config = function(opts)
      local npairs = require "nvim-autopairs"
      npairs.setup(opts)

      if not vim.g.autopairs_enabled then npairs.disable() end
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false })
      end
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "folke/which-key.nvim",
    event = "UIEnter",
    opts = {
      plugins = { spelling = { enabled = true }, presets = { operators = false } },
      window = { border = "rounded", padding = { 2, 2, 2, 2 } },
      disable = { filetypes = { "TelescopePrompt" } },
    },
    default_config = function(opts) require("which-key").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufEnter",
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
        return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
          or { "treesitter", "indent" } -- if file opened, try to use treesitter if available
      end,
    },
    default_config = function(opts) require("ufo").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "numToStr/Comment.nvim",
    keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
    opts = function()
      local utils = require "Comment.utils"
      return {
        pre_hook = function(ctx)
          local location = nil
          if ctx.ctype == utils.ctype.blockwise then
            location = require("ts_context_commentstring.utils").get_cursor_location()
          elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
          end

          return require("ts_context_commentstring.internal").calculate_commentstring {
            key = ctx.ctype == utils.ctype.linewise and "__default" or "__multiline",
            location = location,
          }
        end,
      }
    end,
    default_config = function(opts) require("Comment").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 10,
      open_mapping = [[<F7>]],
      shading_factor = 2,
      direction = "float",
      float_opts = {
        border = "curved",
        highlights = { border = "Normal", background = "Normal" },
      },
    },
    default_config = function(opts) require("toggleterm").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "NMAC427/guess-indent.nvim",
    init = function() table.insert(astronvim.file_plugins, "guess-indent.nvim") end,
    default_config = function(opts)
      require("guess-indent").setup(opts)
      vim.cmd.lua { args = { "require('guess-indent').set_from_buffer('auto_cmd')" }, mods = { silent = true } }
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertCharPre",
    opts = { timeout = 300 },
    default_config = function(opts) require("better_escape").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
}
