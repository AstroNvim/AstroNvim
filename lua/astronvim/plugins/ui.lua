return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    enabled = vim.g.icons_enabled ~= false,
    opts = function()
      return {
        override = {
          default_icon = { icon = require("astroui").get_icon "DefaultFile" },
          deb = { icon = "", name = "Deb" },
          lock = { icon = "󰌾", name = "Lock" },
          mp3 = { icon = "󰎆", name = "Mp3" },
          mp4 = { icon = "", name = "Mp4" },
          out = { icon = "", name = "Out" },
          ["robots.txt"] = { icon = "󰚩", name = "Robots" },
          ttf = { icon = "", name = "TrueTypeFont" },
          rpm = { icon = "", name = "Rpm" },
          woff = { icon = "", name = "WebOpenFontFormat" },
          woff2 = { icon = "", name = "WebOpenFontFormat2" },
          xz = { icon = "", name = "Xz" },
          zip = { icon = "", name = "Zip" },
        },
      }
    end,
  },
  {
    "onsails/lspkind.nvim",
    lazy = true,
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    enabled = vim.g.icons_enabled ~= false,
    config = function(...) require "astronvim.plugins.configs.lspkind"(...) end,
  },
  {
    "rcarriga/nvim-notify",
    lazy = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>uD"] = {
            function() require("notify").dismiss { pending = true, silent = true } end,
            desc = "Dismiss notifications",
          }
        end,
      },
    },
    init = function() require("astrocore").load_plugin_with_func("nvim-notify", vim, "notify") end,
    opts = {
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      on_open = function(win)
        local astrocore = require "astrocore"
        vim.api.nvim_win_set_config(win, { zindex = 175 })
        if not astrocore.config.features.notifications then vim.api.nvim_win_close(win, true) end
        if astrocore.is_available "nvim-treesitter" then require("lazy").load { plugins = { "nvim-treesitter" } } end
        vim.wo[win].conceallevel = 3
        local buf = vim.api.nvim_win_get_buf(win)
        if not pcall(vim.treesitter.start, buf, "markdown") then vim.bo[buf].syntax = "markdown" end
        vim.wo[win].spell = false
      end,
    },
    config = function(...) require "astronvim.plugins.configs.notify"(...) end,
  },
  {
    "RRethy/vim-illuminate",
    event = "User AstroFile",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["]r"] = { function() require("illuminate")["goto_next_reference"](false) end, desc = "Next reference" }
          maps.n["[r"] =
            { function() require("illuminate")["goto_prev_reference"](false) end, desc = "Previous reference" }
          maps.n["<Leader>ur"] =
            { function() require("illuminate").toggle() end, desc = "Toggle reference highlighting" }
          maps.n["<Leader>uR"] =
            { function() require("illuminate").toggle_buf() end, desc = "Toggle reference highlighting (buffer)" }
        end,
      },
    },
    opts = function()
      return {
        delay = 200,
        min_count_to_highlight = 2,
        large_file_cutoff = require("astrocore").config.features.max_file.lines,
        large_file_overrides = { providers = { "lsp" } },
        should_enable = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
      }
    end,
    config = function(...) require "astronvim.plugins.configs.vim-illuminate"(...) end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function() require("astrocore").load_plugin_with_func("dressing.nvim", vim.ui, "input", "select") end,
    opts = {
      input = { default_prompt = "➤ " },
      select = { backend = { "telescope", "builtin" } },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>uz"] = { "<Cmd>ColorizerToggle<CR>", desc = "Toggle color highlight" }
        end,
      },
    },
    event = "User AstroFile",
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
    opts = { user_default_options = { names = false } },
  },
}
