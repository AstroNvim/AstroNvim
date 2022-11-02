local astro_plugins = {
  -- Plugin manager
  ["wbthomason/packer.nvim"] = {},

  -- Optimiser
  ["lewis6991/impatient.nvim"] = {},

  -- Lua functions
  ["nvim-lua/plenary.nvim"] = { module = "plenary" },

  -- Indent detection
  ["Darazaki/indent-o-matic"] = {
    event = "BufEnter",
    config = function() require "configs.indent-o-matic" end,
  },

  -- Notification Enhancer
  ["rcarriga/nvim-notify"] = {
    event = "UIEnter",
    config = function() require "configs.notify" end,
  },

  -- Neovim UI Enhancer
  ["stevearc/dressing.nvim"] = {
    event = "UIEnter",
    config = function() require "configs.dressing" end,
  },

  -- Smarter Splits
  ["mrjones2014/smart-splits.nvim"] = {
    module = "smart-splits",
    config = function() require "configs.smart-splits" end,
  },

  -- Icons
  ["nvim-tree/nvim-web-devicons"] = {
    disable = not vim.g.icons_enabled,
    module = "nvim-web-devicons",
    config = function() require "configs.nvim-web-devicons" end,
  },

  -- LSP Icons
  ["onsails/lspkind.nvim"] = {
    disable = not vim.g.icons_enabled,
    module = "lspkind",
    config = function() require "configs.lspkind" end,
  },

  -- Bufferline
  ["akinsho/bufferline.nvim"] = {
    module = "bufferline",
    event = "UIEnter",
    config = function() require "configs.bufferline" end,
  },

  -- Better buffer closing
  ["famiu/bufdelete.nvim"] = { module = "bufdelete", cmd = { "Bdelete", "Bwipeout" } },

  ["s1n7ax/nvim-window-picker"] = {
    tag = "v1.*",
    module = "window-picker",
    config = function() require "configs.window-picker" end,
  },

  -- File explorer
  ["nvim-neo-tree/neo-tree.nvim"] = {
    branch = "v2.x",
    module = "neo-tree",
    cmd = "Neotree",
    requires = { { "MunifTanjim/nui.nvim", module = "nui" } },
    setup = function() vim.g.neo_tree_remove_legacy_commands = true end,
    config = function() require "configs.neo-tree" end,
  },

  -- Statusline
  ["rebelot/heirline.nvim"] = { config = function() require "configs.heirline" end },

  -- Parenthesis highlighting
  ["p00f/nvim-ts-rainbow"] = { after = "nvim-treesitter" },

  -- Autoclose tags
  ["windwp/nvim-ts-autotag"] = { after = "nvim-treesitter" },

  -- Context based commenting
  ["JoosepAlviste/nvim-ts-context-commentstring"] = { after = "nvim-treesitter" },

  -- Syntax highlighting
  ["nvim-treesitter/nvim-treesitter"] = {
    run = function() require("nvim-treesitter.install").update { with_sync = true } end,
    event = "BufEnter",
    config = function() require "configs.treesitter" end,
  },

  -- Snippet collection
  ["rafamadriz/friendly-snippets"] = { opt = true },

  -- Snippet engine
  ["L3MON4D3/LuaSnip"] = {
    module = "luasnip",
    wants = "friendly-snippets",
    config = function() require "configs.luasnip" end,
  },

  -- Completion engine
  ["hrsh7th/nvim-cmp"] = {
    event = "InsertEnter",
    config = function() require "configs.cmp" end,
  },

  -- Snippet completion source
  ["saadparwaiz1/cmp_luasnip"] = {
    after = "nvim-cmp",
    config = function() astronvim.add_user_cmp_source "luasnip" end,
  },

  -- Buffer completion source
  ["hrsh7th/cmp-buffer"] = {
    after = "nvim-cmp",
    config = function() astronvim.add_user_cmp_source "buffer" end,
  },

  -- Path completion source
  ["hrsh7th/cmp-path"] = {
    after = "nvim-cmp",
    config = function() astronvim.add_user_cmp_source "path" end,
  },

  -- LSP completion source
  ["hrsh7th/cmp-nvim-lsp"] = {
    after = "nvim-cmp",
    config = function() astronvim.add_user_cmp_source "nvim_lsp" end,
  },

  -- Built-in LSP
  ["neovim/nvim-lspconfig"] = { config = function() require "configs.lspconfig" end },

  -- Formatting and linting
  ["jose-elias-alvarez/null-ls.nvim"] = {
    event = "BufEnter",
    config = function() require "configs.null-ls" end,
  },

  -- Package Manager
  ["williamboman/mason.nvim"] = { config = function() require "configs.mason" end },

  -- LSP manager
  ["williamboman/mason-lspconfig.nvim"] = {
    after = { "mason.nvim", "nvim-lspconfig" },
    config = function() require "configs.mason-lspconfig" end,
  },

  -- null-ls manager
  ["jayp0521/mason-null-ls.nvim"] = {
    after = { "mason.nvim", "null-ls.nvim" },
    config = function() require "configs.mason-null-ls" end,
  },

  -- LSP symbols
  ["stevearc/aerial.nvim"] = {
    module = "aerial",
    config = function() require "configs.aerial" end,
  },

  -- Fuzzy finder
  ["nvim-telescope/telescope.nvim"] = {
    cmd = "Telescope",
    module = "telescope",
    config = function() require "configs.telescope" end,
  },

  -- Fuzzy finder syntax support
  ["nvim-telescope/telescope-fzf-native.nvim"] = {
    after = "telescope.nvim",
    disable = vim.fn.executable "make" == 0,
    run = "make",
    config = function() require("telescope").load_extension "fzf" end,
  },

  -- Git integration
  ["lewis6991/gitsigns.nvim"] = {
    event = "BufEnter",
    config = function() require "configs.gitsigns" end,
  },

  -- Start screen
  ["goolord/alpha-nvim"] = {
    cmd = "Alpha",
    module = "alpha",
    config = function() require "configs.alpha" end,
  },

  -- Color highlighting
  ["NvChad/nvim-colorizer.lua"] = {
    event = "BufEnter",
    config = function() require "configs.colorizer" end,
  },

  -- Autopairs
  ["windwp/nvim-autopairs"] = {
    event = "InsertEnter",
    config = function() require "configs.autopairs" end,
  },

  -- Terminal
  ["akinsho/toggleterm.nvim"] = {
    cmd = "ToggleTerm",
    module = { "toggleterm", "toggleterm.terminal" },
    config = function() require "configs.toggleterm" end,
  },

  -- Commenting
  ["numToStr/Comment.nvim"] = {
    module = { "Comment", "Comment.api" },
    keys = { "gc", "gb" },
    config = function() require "configs.Comment" end,
  },

  -- Indentation
  ["lukas-reineke/indent-blankline.nvim"] = {
    event = "BufEnter",
    config = function() require "configs.indent-line" end,
  },

  -- Keymaps popup
  ["folke/which-key.nvim"] = {
    module = "which-key",
    config = function() require "configs.which-key" end,
  },

  -- Smooth escaping
  ["max397574/better-escape.nvim"] = {
    event = "InsertCharPre",
    config = function() require "configs.better_escape" end,
  },

  -- Get extra JSON schemas
  ["b0o/SchemaStore.nvim"] = { module = "schemastore" },

  -- Session manager
  ["Shatur/neovim-session-manager"] = {
    module = "session_manager",
    cmd = "SessionManager",
    event = "BufWritePost",
    config = function() require "configs.session_manager" end,
  },
}

if astronvim.updater.snapshot then
  for plugin, options in pairs(astro_plugins) do
    local pin = astronvim.updater.snapshot[plugin:match "/([^/]*)$"]
    options.commit = pin and pin.commit or options.commit
  end
end

local user_plugin_opts = astronvim.user_plugin_opts
local status_ok, packer = pcall(require, "packer")
if status_ok then
  packer.startup {
    function(use)
      for key, plugin in pairs(user_plugin_opts("plugins.init", astro_plugins)) do
        if type(key) == "string" and not plugin[1] then plugin[1] = key end
        use(plugin)
      end
    end,
    config = user_plugin_opts("plugins.packer", {
      compile_path = astronvim.default_compile_path,
      display = {
        open_fn = function() return require("packer.util").float { border = "rounded" } end,
      },
      profile = {
        enable = true,
        threshold = 0.0001,
      },
      git = {
        clone_timeout = 300,
        subcommands = {
          update = "pull --rebase",
        },
      },
      auto_clean = true,
      compile_on_sync = true,
    }),
  }
end
