
-- Jupyter-Notebooks:
-- https://richban.tech/python-jupyter-notebooks-development-in-neo-vim
-- https://www.maxwellrules.com/misc/nvim_jupyter.html
-- https://pythonawesome.com/a-neovim-plugin-for-running-code-interactively-with-jupyter/
-- https://github.com/jupyter-vim/jupyter-vim

return {
  ------------------------------------------------------------------
  -- General
  ------------------------------------------------------------------
  {
    "romainl/vim-cool", -- disables search highlighting when you are done
    event = { "CursorMoved", "InsertEnter" },
  },

  {
    "andweeb/presence.nvim",
    config = function()
      require("user.plugins.presence").config()
    end,
  },

  {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("user.plugins.todo_comments").config()
    end,
    event = "BufRead",
  },

   -- Scrollbar.
  {
    "dstein64/nvim-scrollview",
    event = "BufRead",
    config = function()
      require("user/plugins/nvim-scroll")
    end,
  },


  ------------------------------------------------------------------
  -- Telescope
  ------------------------------------------------------------------

  {
    'tknightz/telescope-termfinder.nvim',
    config = function()
     require('telescope').load_extension("termfinder")
    end,
  },

  ------------------------------------------------------------------
  -- Git / diff
  ------------------------------------------------------------------

  {
    "sindrets/diffview.nvim",
    opt = true,
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    module = "diffview",
    keys = "<leader>gd",
    setup = function()
      -- require("which-key").register { ["<leader>gd"] = "diffview: diff HEAD" }
    end,
    config = function()
      require("diffview").setup {
        enhanced_diff_hl = true,
        key_bindings = {
          file_panel = { q = "<Cmd>DiffviewClose<CR>" },
          view = { q = "<Cmd>DiffviewClose<CR>" },
        },
      }
    end,
  },

  {
    "tpope/vim-fugitive",
    cmd = "Git",
  },

  ------------------------------------------------------------------
  -- LSP
  ------------------------------------------------------------------

  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    -- event = { "BufRead", "BufNew" },
    config = function()
      require("lsp_signature").setup()
      -- require("user.plugins.lsp_signature").config()
    end,
  },

  ------------------------------------------------------------------
  -- Start-up
  ------------------------------------------------------------------
  {
    "goolord/alpha-nvim",
    cmd = 'Alpha',
    config = function()
      require("user.plugins.alpha")
      vim.cmd("au! FileType alpha setl nospell")
    end,
    -- disable = 0,
  },

  -- -------------------------------------------------------
  -- Colorschemes
  -- -------------------------------------------------------
  { "Th3Whit3Wolf/one-nvim"}, -- lazy by nature
  { 'sonph/onehalf', rtp = 'vim', },
  { 'NLKNguyen/papercolor-theme' },

  -- -------------------------------------------------------

}

-- return plugins
