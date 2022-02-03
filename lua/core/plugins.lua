local M = {}

local utils = require "core.utils"
local config = utils.user_settings()

local packer_status_ok, packer = pcall(require, "packer")
if not packer_status_ok then
  return
end

packer.startup {
  function(use)
    -- Plugin manager
    use {
      "wbthomason/packer.nvim",
    }

    -- Optimiser
    use {
      "lewis6991/impatient.nvim",
    }

    -- Lua functions
    use {
      "nvim-lua/plenary.nvim",
    }

    -- Popup API
    use {
      "nvim-lua/popup.nvim",
    }

    -- Boost startup time
    use {
      "nathom/filetype.nvim",
      config = function()
        vim.g.did_load_filetypes = 1
      end,
    }

    -- Cursorhold fix
    use {
      "antoinemadec/FixCursorHold.nvim",
      event = "BufRead",
      config = function()
        vim.g.cursorhold_updatetime = 100
      end,
    }

    -- Icons
    use {
      "kyazdani42/nvim-web-devicons",
      config = function()
        require("configs.icons").config()
      end,
    }

    -- Bufferline
    use {
      "akinsho/bufferline.nvim",
      after = "nvim-web-devicons",
      config = function()
        require("configs.bufferline").config()
      end,
    }

    -- Better buffer closing
    use {
      "moll/vim-bbye",
      after = "bufferline.nvim",
    }

    -- File explorer
    use {
      "kyazdani42/nvim-tree.lua",
      cmd = "NvimTreeToggle",
      config = function()
        require("configs.nvim-tree").config()
      end,
      disable = not config.enabled.nvim_tree,
    }

    -- Statusline
    use {
      "nvim-lualine/lualine.nvim",
      after = "bufferline.nvim",
      config = function()
        require("configs.lualine").config()
      end,
      disable = not config.enabled.lualine,
    }

    -- Syntax highlighting
    use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      event = "BufRead",
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
      requires = {
        {
          -- Parenthesis highlighting
          "p00f/nvim-ts-rainbow",
          after = "nvim-treesitter",
          disable = not config.enabled.ts_rainbow,
        },
        {
          -- Autoclose tags
          "windwp/nvim-ts-autotag",
          after = "nvim-treesitter",
          disable = not config.enabled.ts_autotag,
        },
        {
          -- Context based commenting
          "JoosepAlviste/nvim-ts-context-commentstring",
          after = "nvim-treesitter",
        },
      },
    }

    -- Snippet engine
    use {
      "L3MON4D3/LuaSnip",
      config = function()
        require("luasnip/loaders/from_vscode").lazy_load()
      end,
      requires = {
        -- Snippet collections
        "rafamadriz/friendly-snippets",
      },
    }

    -- Completion engine
    use {
      "hrsh7th/nvim-cmp",
      event = "BufRead",
      config = function()
        require("configs.cmp").config()
      end,
    }

    -- Snippet completion source
    use {
      "saadparwaiz1/cmp_luasnip",
      after = "nvim-cmp",
    }

    -- Buffer completion source
    use {
      "hrsh7th/cmp-buffer",
      after = "nvim-cmp",
    }

    -- Path completion source
    use {
      "hrsh7th/cmp-path",
      after = "nvim-cmp",
    }

    -- LSP completion source
    use {
      "hrsh7th/cmp-nvim-lsp",
    }

    -- LSP manager
    use {
      "williamboman/nvim-lsp-installer",
      event = "BufRead",
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
    }

    -- Built-in LSP
    use {
      "neovim/nvim-lspconfig",
      event = "BufRead",
      config = function()
        require "configs.lsp"
      end,
    }

    -- LSP enhancer
    use {
      "tami5/lspsaga.nvim",
      event = "BufRead",
      config = function()
        require("configs.lsp.lspsaga").config()
      end,
      disable = not config.enabled.lspsaga,
    }

    -- LSP symbols
    use {
      "simrat39/symbols-outline.nvim",
      cmd = "SymbolsOutline",
      setup = function()
        require("configs.symbols-outline").setup()
      end,
      disable = not config.enabled.symbols_outline,
    }

    -- Formatting and linting
    use {
      "jose-elias-alvarez/null-ls.nvim",
      event = "BufRead",
      config = function()
        require "user.null-ls".config()
      end,
    }

    -- Fuzzy finder
    use {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      config = function()
        require("configs.telescope").config()
      end,
    }

    -- Fuzzy finder syntax support
    use {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
      cmd = "Telescope",
    }

    -- Git integration
    use {
      "lewis6991/gitsigns.nvim",
      event = "BufRead",
      config = function()
        require("configs.gitsigns").config()
      end,
      disable = not config.enabled.gitsigns,
    }

    -- Start screen
    use {
      "glepnir/dashboard-nvim",
      config = function()
        require("configs.dashboard").config()
      end,
    }

    -- Color highlighting
    use {
      "norcalli/nvim-colorizer.lua",
      event = "BufRead",
      config = function()
        require("configs.colorizer").config()
      end,
      disable = not config.enabled.colorizer,
    }

    -- Autopairs
    use {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("configs.autopairs").config()
      end,
    }

    -- Terminal
    use {
      "akinsho/nvim-toggleterm.lua",
      cmd = "ToggleTerm",
      config = function()
        require("configs.toggleterm").config()
      end,
      disable = not config.enabled.toggle_term,
    }

    -- Commenting
    use {
      "numToStr/Comment.nvim",
      event = "BufRead",
      config = function()
        require("configs.comment").config()
      end,
      disable = not config.enabled.comment,
    }

    -- Indentation
    use {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require("configs.indent-line").config()
      end,
      disable = not config.enabled.indent_blankline,
    }

    -- Keymaps popup
    use {
      "folke/which-key.nvim",
      config = function()
        require("configs.which-key").config()
      end,
      disable = not config.enabled.which_key,
    }

    -- Smooth scrolling
    use {
      "karb94/neoscroll.nvim",
      event = "BufRead",
      config = function()
        require("configs.neoscroll").config()
      end,
      disable = not config.enabled.neoscroll,
    }

    -- Smooth escaping
    use {
      "max397574/better-escape.nvim",
      event = { "InsertEnter" },
      config = function()
        require("better_escape").setup {
          mapping = { "ii", "jj", "jk", "kj" },
          timeout = vim.o.timeoutlen,
          keys = "<ESC>",
        }
      end,
    }

    -- User defined plugins
    if config.plugins and not vim.tbl_isempty(config.plugins) then
      for _, plugin in pairs(config.plugins) do
        use(plugin)
      end
    end
  end,
  config = {
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
    },
    auto_clean = true,
    compile_on_sync = true,
  },
}

return M
