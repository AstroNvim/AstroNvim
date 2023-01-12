return {
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.icons_enabled,
    opts = {
      deb = { icon = "", name = "Deb" },
      lock = { icon = "", name = "Lock" },
      mp3 = { icon = "", name = "Mp3" },
      mp4 = { icon = "", name = "Mp4" },
      out = { icon = "", name = "Out" },
      ["robots.txt"] = { icon = "ﮧ", name = "Robots" },
      ttf = { icon = "", name = "TrueTypeFont" },
      rpm = { icon = "", name = "Rpm" },
      woff = { icon = "", name = "WebOpenFontFormat" },
      woff2 = { icon = "", name = "WebOpenFontFormat2" },
      xz = { icon = "", name = "Xz" },
      zip = { icon = "", name = "Zip" },
    },
    default_config = function(opts)
      require("nvim-web-devicons").set_default_icon(astronvim.get_icon "DefaultFile", "#6d8086", "66")
      require("nvim-web-devicons").set_icon(opts)
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol",
      symbol_map = {
        NONE = "",
        Array = "",
        Boolean = "⊨",
        Class = "",
        Constructor = "",
        Key = "",
        Namespace = "",
        Null = "NULL",
        Number = "#",
        Object = "⦿",
        Package = "",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "𝓐",
        TypeParameter = "",
        Unit = "",
      },
    },
    enabled = vim.g.icons_enabled,
    default_config = function(opts)
      astronvim.lspkind = opts
      require("lspkind").init(opts)
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "rcarriga/nvim-notify",
    init = function() astronvim.load_plugin_with_func("nvim-notify", vim, "notify") end,
    opts = { stages = "fade" },
    default_config = function(opts)
      local notify = require "notify"
      notify.setup(opts)
      vim.notify = notify
    end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "stevearc/dressing.nvim",
    init = function() astronvim.load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" }) end,
    opts = {
      input = {
        default_prompt = "➤ ",
        win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
      },
      select = {
        backend = { "telescope", "builtin" },
        builtin = { win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" } },
      },
    },
    default_config = function(opts) require("dressing").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    init = function() table.insert(astronvim.file_plugins, "nvim-colorizer.lua") end,
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
    opts = { user_default_options = { names = false } },
    default_config = function(opts) require("colorizer").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    init = function() table.insert(astronvim.file_plugins, "indent-blankline.nvim") end,
    opts = {
      buftype_exclude = {
        "nofile",
        "terminal",
      },
      filetype_exclude = {
        "help",
        "startify",
        "aerial",
        "alpha",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "neo-tree",
        "Trouble",
      },
      context_patterns = {
        "class",
        "return",
        "function",
        "method",
        "^if",
        "^while",
        "jsx_element",
        "^for",
        "^object",
        "^table",
        "block",
        "arguments",
        "if_statement",
        "else_clause",
        "jsx_element",
        "jsx_self_closing_element",
        "try_statement",
        "catch_clause",
        "import_statement",
        "operation_type",
      },
      show_trailing_blankline_indent = false,
      use_treesitter = true,
      char = "▏",
      context_char = "▏",
      show_current_context = true,
    },
    default_config = function(opts) require("indent_blankline").setup(opts) end,
    config = function(plugin, opts) plugin.default_config(opts) end,
  },
}
