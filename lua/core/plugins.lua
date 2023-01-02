local astro_plugins = {
  -- Plugin manager
  ["wbthomason/packer.nvim"] = {
    setup = function()
      astronvim.lazy_load_commands("packer.nvim", {
        "PackerSnapshot",
        "PackerSnapshotRollback",
        "PackerSnapshotDelete",
        "PackerInstall",
        "PackerUpdate",
        "PackerSync",
        "PackerClean",
        "PackerCompile",
        "PackerStatus",
        "PackerProfile",
        "PackerLoad",
      })
    end,
    config = function() require "core.plugins" end,
  },

  -- Optimiser
  ["lewis6991/impatient.nvim"] = {},

  -- Lua functions
  ["nvim-lua/plenary.nvim"] = { module = "plenary" },

  -- Indent detection
  ["Darazaki/indent-o-matic"] = {
    opt = true,
    setup = function() table.insert(astronvim.file_plugins, "indent-o-matic") end,
    config = function() require "configs.indent-o-matic" end,
  },

  -- Notification Enhancer
  ["rcarriga/nvim-notify"] = {
    module = "notify",
    setup = function() astronvim.load_plugin_with_func("nvim-notify", vim, "notify") end,
    config = function() require "configs.notify" end,
  },

  -- Neovim UI Enhancer
  ["stevearc/dressing.nvim"] = {
    opt = true,
    setup = function() astronvim.load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" }) end,
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
  ["akinsho/bufferline.nvim"] = { -- TODO v3: remove this plugin
    disable = vim.g.heirline_bufferline,
    module = "bufferline",
    event = "UIEnter",
    config = function() require "configs.bufferline" end,
  },

  -- Better buffer closing
  ["famiu/bufdelete.nvim"] = {
    module = "bufdelete",
    setup = function() astronvim.lazy_load_commands("bufdelete.nvim", { "Bdelete", "Bwipeout" }) end,
  },

  ["s1n7ax/nvim-window-picker"] = {
    tag = "v1.*",
    module = "window-picker",
    config = function() require "configs.window-picker" end,
  },

  -- File explorer
  ["nvim-neo-tree/neo-tree.nvim"] = {
    branch = "v2.x",
    module = "neo-tree",
    requires = { { "MunifTanjim/nui.nvim", module = "nui" } },
    setup = function()
      astronvim.lazy_load_commands("neo-tree.nvim", "Neotree")
      vim.g.neo_tree_remove_legacy_commands = true
    end,
    config = function() require "configs.neo-tree" end,
  },

  -- Statusline
  ["rebelot/heirline.nvim"] = { event = "VimEnter", config = function() require "configs.heirline" end },

  -- Syntax highlighting
  ["nvim-treesitter/nvim-treesitter"] = {
    module = "nvim-treesitter",
    setup = function()
      table.insert(astronvim.file_plugins, "nvim-treesitter")
      astronvim.lazy_load_commands("nvim-treesitter", {
        "TSBufDisable",
        "TSBufEnable",
        "TSBufToggle",
        "TSDisable",
        "TSEnable",
        "TSToggle",
        "TSInstall",
        "TSInstallInfo",
        "TSInstallSync",
        "TSModuleInfo",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
      })
    end,
    run = function() require("nvim-treesitter.install").update { with_sync = true }() end,
    config = function() require "configs.treesitter" end,
  },

  -- Parenthesis highlighting
  ["p00f/nvim-ts-rainbow"] = { after = "nvim-treesitter" },

  -- Autoclose tags
  ["windwp/nvim-ts-autotag"] = { after = "nvim-treesitter" },

  -- Context based commenting
  ["JoosepAlviste/nvim-ts-context-commentstring"] = { after = "nvim-treesitter" },

  -- Snippet collection
  ["rafamadriz/friendly-snippets"] = { opt = true },

  -- Snippet engine
  ["L3MON4D3/LuaSnip"] = {
    module = "luasnip",
    wants = "friendly-snippets",
    config = function() require "configs.luasnip" end,
  },

  -- Completion engine
  ["hrsh7th/nvim-cmp"] = { event = "InsertEnter", config = function() require "configs.cmp" end },

  -- Snippet completion source
  ["saadparwaiz1/cmp_luasnip"] = {
    after = "nvim-cmp",
    config = function() astronvim.add_user_cmp_source "luasnip" end,
  },

  -- Buffer completion source
  ["hrsh7th/cmp-buffer"] = { after = "nvim-cmp", config = function() astronvim.add_user_cmp_source "buffer" end },

  -- Path completion source
  ["hrsh7th/cmp-path"] = { after = "nvim-cmp", config = function() astronvim.add_user_cmp_source "path" end },

  -- LSP completion source
  ["hrsh7th/cmp-nvim-lsp"] = { after = "nvim-cmp", config = function() astronvim.add_user_cmp_source "nvim_lsp" end },

  -- Built-in LSP
  ["neovim/nvim-lspconfig"] = {
    module = "lspconfig",
    setup = function() table.insert(astronvim.file_plugins, "nvim-lspconfig") end,
    config = function() require "configs.lspconfig" end,
  },

  -- Formatting and linting
  ["jose-elias-alvarez/null-ls.nvim"] = {
    module = "null-ls",
    setup = function() table.insert(astronvim.file_plugins, "null-ls.nvim") end,
    config = function() require "configs.null-ls" end,
  },

  -- Debugger
  ["mfussenegger/nvim-dap"] = {
    disable = vim.fn.has "win32" == 1,
    module = "dap",
    config = function() require "configs.dap" end,
  },

  -- Debugger UI
  ["rcarriga/nvim-dap-ui"] = {
    disable = vim.fn.has "win32" == 1,
    after = "nvim-dap",
    config = function() require "configs.dapui" end,
  },

  -- Package Manager
  ["williamboman/mason.nvim"] = {
    module = "mason",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate", -- astronvim command
      "MasonUpdateAll", -- astronvim command
    },
    config = function()
      require "configs.mason"
      vim.tbl_map(function(plugin) pcall(require, plugin) end, { "lspconfig", "null-ls", "dap" })
    end,
  },

  -- LSP manager
  ["williamboman/mason-lspconfig.nvim"] = {
    after = "nvim-lspconfig",
    config = function() require "configs.mason-lspconfig" end,
  },

  -- null-ls manager
  ["jayp0521/mason-null-ls.nvim"] = { after = "null-ls.nvim", config = function() require "configs.mason-null-ls" end },

  -- dap manager
  ["jayp0521/mason-nvim-dap.nvim"] = {
    disable = vim.fn.has "win32" == 1,
    after = "nvim-dap",
    config = function() require "configs.mason-nvim-dap" end,
  },

  -- LSP symbols
  ["stevearc/aerial.nvim"] = {
    module = "aerial",
    after = { "nvim-treesitter", "nvim-lspconfig" },
    ft = { "man", "markdown" },
    config = function() require "configs.aerial" end,
  },

  -- Fuzzy finder
  ["nvim-telescope/telescope.nvim"] = {
    module = "telescope",
    setup = function() astronvim.lazy_load_commands("telescope.nvim", "Telescope") end,
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
    disable = vim.fn.executable "git" == 0,
    ft = "gitcommit",
    setup = function() table.insert(astronvim.git_plugins, "gitsigns.nvim") end,
    config = function() require "configs.gitsigns" end,
  },

  -- Start screen
  ["goolord/alpha-nvim"] = {
    module = "alpha",
    setup = function() astronvim.lazy_load_commands("alpha-nvim", "Alpha") end,
    config = function() require "configs.alpha" end,
  },

  -- Color highlighting
  ["NvChad/nvim-colorizer.lua"] = {
    opt = true,
    setup = function()
      astronvim.lazy_load_commands(
        "nvim-colorizer.lua",
        { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" }
      )
      table.insert(astronvim.file_plugins, "nvim-colorizer.lua")
    end,
    config = function() require "configs.colorizer" end,
  },

  -- Autopairs
  ["windwp/nvim-autopairs"] = { event = "InsertEnter", config = function() require "configs.autopairs" end },

  -- Terminal
  ["akinsho/toggleterm.nvim"] = {
    module = "toggleterm",
    setup = function() astronvim.lazy_load_commands("toggleterm.nvim", { "ToggleTerm", "TermExec" }) end,
    config = function() require "configs.toggleterm" end,
  },

  -- Commenting
  ["numToStr/Comment.nvim"] = {
    module = "Comment",
    keys = { "gc", "gb" },
    config = function() require "configs.Comment" end,
  },

  -- Indentation
  ["lukas-reineke/indent-blankline.nvim"] = {
    opt = true,
    setup = function() table.insert(astronvim.file_plugins, "indent-blankline.nvim") end,
    config = function() require "configs.indent-line" end,
  },

  -- Keymaps popup
  ["folke/which-key.nvim"] = { module = "which-key", config = function() require "configs.which-key" end },

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
    event = "BufWritePost",
    setup = function() astronvim.lazy_load_commands("neovim-session-manager", "SessionManager") end,
    config = function() require "configs.session_manager" end,
  },
}

if astronvim.updater.snapshot then
  for plugin, options in pairs(astro_plugins) do
    local pin = astronvim.updater.snapshot[plugin:match "/([^/]*)$"]
    if pin and pin.commit then
      options.commit = pin.commit
      options.tag = nil
    end
  end
end

local user_plugin_opts = astronvim.user_plugin_opts
local status_ok, packer = pcall(require, "packer")
if status_ok then
  packer.startup {
    function(use)
      local plugins = user_plugin_opts("plugins.init", astro_plugins)
      for key, plugin in pairs(plugins) do
        if type(key) == "string" and not plugin[1] then plugin[1] = key end
        if key == "williamboman/mason.nvim" and plugin.cmd then
          for mason_plugin, commands in pairs { -- lazy load mason plugin commands with Mason
            ["jayp0521/mason-null-ls.nvim"] = { "NullLsInstall", "NullLsUninstall" },
            ["williamboman/mason-lspconfig.nvim"] = { "LspInstall", "LspUninstall" },
            ["jayp0521/mason-nvim-dap.nvim"] = { "DapInstall", "DapUninstall" },
          } do
            if plugins[mason_plugin] and not plugins[mason_plugin].disable then
              vim.list_extend(plugin.cmd, commands)
            end
          end
        end
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
