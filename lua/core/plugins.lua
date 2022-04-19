local M = {}

local packer_status_ok, packer = pcall(require, "packer")
if packer_status_ok then
  local utils = require "core.utils"
  local config = utils.user_settings()

  local astro_plugins = {
    -- Plugin manager
    {
      "wbthomason/packer.nvim",
    },

    -- Optimiser
    { "lewis6991/impatient.nvim" },

    -- Lua functions
    { "nvim-lua/plenary.nvim" },

    -- Popup API
    { "nvim-lua/popup.nvim" },

    -- Indent detection
    {
      "Darazaki/indent-o-matic",
      event = "BufRead",
      config = function()
        require("configs.indent-o-matic").config()
      end,
    },

    -- Notification Enhancer
    {
      "rcarriga/nvim-notify",
      config = function()
        require("configs.notify").config()
      end,
    },

    -- Neovim UI Enhancer
    {
      "MunifTanjim/nui.nvim",
      module = "nui",
    },

    -- Cursorhold fix
    {
      "antoinemadec/FixCursorHold.nvim",
      event = { "BufRead", "BufNewFile" },
      config = function()
        vim.g.cursorhold_updatetime = 100
      end,
    },

    -- Smarter Splits
    {
      "mrjones2014/smart-splits.nvim",
      module = "smart-splits",
      config = function()
        require("configs.smart-splits").config()
      end,
    },

    -- Icons
    {
      "kyazdani42/nvim-web-devicons",
      config = function()
        require("configs.icons").config()
      end,
    },

    -- Bufferline
    {
      "akinsho/bufferline.nvim",
      after = "nvim-web-devicons",
      config = function()
        require("configs.bufferline").config()
      end,
      disable = not config.enabled.bufferline,
    },

    -- Better buffer closing
    {
      "moll/vim-bbye",
    },

    -- File explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      module = "neo-tree",
      cmd = "Neotree",
      requires = "MunifTanjim/nui.nvim",
      config = function()
        require("configs.neo-tree").config()
      end,
      disable = not config.enabled.neo_tree,
    },

    -- Statusline
    {
      "nvim-lualine/lualine.nvim",
      config = function()
        require("configs.lualine").config()
      end,
      disable = not config.enabled.lualine,
    },

    -- Parenthesis highlighting
    {
      "p00f/nvim-ts-rainbow",
      after = "nvim-treesitter",
      disable = not config.enabled.ts_rainbow,
    },

    -- Autoclose tags
    {
      "windwp/nvim-ts-autotag",
      after = "nvim-treesitter",
      disable = not config.enabled.ts_autotag,
    },

    -- Context based commenting
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      after = "nvim-treesitter",
    },

    -- Syntax highlighting
    {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      event = { "BufRead", "BufNewFile" },
      cmd = {
        "TSInstall",
        "TSInstallInfo",
        "TSInstallSync",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSDisableAll",
        "TSEnableAll",
      },
      config = function()
        require("configs.treesitter").config()
      end,
    },

    -- Snippet collection
    {
      "rafamadriz/friendly-snippets",
      after = "nvim-cmp",
    },

    -- Snippet engine
    {
      "L3MON4D3/LuaSnip",
      after = "friendly-snippets",
      config = function()
        require("configs.luasnip").config()
      end,
    },

    -- Completion engine
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      config = function()
        require("configs.cmp").config()
      end,
    },

    -- Snippet completion source
    {
      "saadparwaiz1/cmp_luasnip",
      after = "nvim-cmp",
      config = function()
        require("core.utils").add_user_cmp_source "luasnip"
      end,
    },

    -- Buffer completion source
    {
      "hrsh7th/cmp-buffer",
      after = "nvim-cmp",
      config = function()
        require("core.utils").add_user_cmp_source "buffer"
      end,
    },

    -- Path completion source
    {
      "hrsh7th/cmp-path",
      after = "nvim-cmp",
      config = function()
        require("core.utils").add_user_cmp_source "path"
      end,
    },

    -- LSP completion source
    {
      "hrsh7th/cmp-nvim-lsp",
      after = "nvim-cmp",
      config = function()
        require("core.utils").add_user_cmp_source "nvim_lsp"
      end,
    },

    -- LSP manager
    {
      "williamboman/nvim-lsp-installer",
      module = "nvim-lsp-installer",
      cmd = {
        "LspInstall",
        "LspInstallInfo",
        "LspPrintInstalled",
        "LspRestart",
        "LspStart",
        "LspStop",
        "LspUninstall",
        "LspUninstallAll",
      },
    },

    -- Built-in LSP
    {
      "neovim/nvim-lspconfig",
      tag = "v0.1.3",
      event = "BufWinEnter",
      config = function()
        require "configs.lsp"
      end,
    },

    -- LSP symbols
    {
      "simrat39/symbols-outline.nvim",
      cmd = "SymbolsOutline",
      setup = function()
        require("configs.symbols-outline").setup()
      end,
      disable = not config.enabled.symbols_outline,
    },

    -- Formatting and linting
    {
      "jose-elias-alvarez/null-ls.nvim",
      event = { "BufRead", "BufNewFile" },
      config = function()
        local null_ls = require("core.utils").user_plugin_opts "null-ls"
        if type(null_ls) == "function" then
          null_ls()
        end
      end,
    },

    -- Fuzzy finder
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      module = "telescope",
      config = function()
        require("configs.telescope").config()
      end,
    },

    -- Fuzzy finder syntax support
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      after = "telescope.nvim",
      run = "make",
      config = function()
        require("telescope").load_extension "fzf"
      end,
    },

    -- Git integration
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufRead", "BufNewFile" },
      config = function()
        require("configs.gitsigns").config()
      end,
      disable = not config.enabled.gitsigns,
    },

    -- Start screen
    {
      "glepnir/dashboard-nvim",
      config = function()
        require("configs.dashboard").config()
      end,
      disable = not config.enabled.dashboard,
    },

    -- Color highlighting
    {
      "norcalli/nvim-colorizer.lua",
      event = { "BufRead", "BufNewFile" },
      config = function()
        require("configs.colorizer").config()
      end,
      disable = not config.enabled.colorizer,
    },

    -- Autopairs
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("configs.autopairs").config()
      end,
    },

    -- Terminal
    {
      "akinsho/nvim-toggleterm.lua",
      cmd = "ToggleTerm",
      module = { "toggleterm", "toggleterm.terminal" },
      config = function()
        require("configs.toggleterm").config()
      end,
      disable = not config.enabled.toggle_term,
    },

    -- Commenting
    {
      "numToStr/Comment.nvim",
      event = { "BufRead", "BufNewFile" },
      config = function()
        require("configs.comment").config()
      end,
      disable = not config.enabled.comment,
    },

    -- Indentation
    {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require("configs.indent-line").config()
      end,
      disable = not config.enabled.indent_blankline,
    },

    -- Keymaps popup
    {
      "folke/which-key.nvim",
      config = function()
        require("configs.which-key").config()
      end,
      disable = not config.enabled.which_key,
    },

    -- Smooth scrolling
    {
      "karb94/neoscroll.nvim",
      event = { "BufRead", "BufNewFile" },
      config = function()
        require("configs.neoscroll").config()
      end,
      disable = not config.enabled.neoscroll,
    },

    -- Smooth escaping
    {
      "max397574/better-escape.nvim",
      event = { "InsertEnter" },
      config = function()
        require("configs.better_escape").config()
      end,
    },

    -- Get extra JSON schemas
    { "b0o/SchemaStore.nvim" },
  }

  packer.startup {
    function(use)
      -- Load plugins!
      for _, plugin in
        pairs(
          require("core.utils").user_plugin_opts("plugins.init", require("core.utils").label_plugins(astro_plugins))
        )
      do
        use(plugin)
      end
    end,
    config = require("core.utils").user_plugin_opts("plugins.packer", {
      compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
      display = {
        open_fn = function()
          return require("packer.util").float { border = "rounded" }
        end,
      },
      profile = {
        enable = true,
        threshold = 0.0001,
      },
      git = {
        clone_timeout = 300,
        subcommands = {
          update = "pull --ff-only --progress --rebase",
        },
      },
      auto_clean = true,
      compile_on_sync = true,
    }),
  }
end

return M
