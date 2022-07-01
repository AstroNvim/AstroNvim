return {
  colorscheme = "duskfox",
  -- Set dashboard header
  header = {
    " ",
    " ",
    " ",
    " ",
    " ",
    "██████ ██████    ███    ██████  ██      ██████  ██████  ██████",
    "██     ██       ██ ██   ██  ██  ██      ██      ██      ██    ",
    "█████  █████   ███████  ██████  ██      █████   ██████  ██████",
    "██     ██      ██   ██  ██ ██   ██      ██          ██      ██",
    "██     ██████  ██   ██  ██  ██  ██████  ██████  ██████  ██████",
    " ",
    "              ███    ██ ██    ██ ██ ███    ███",
    "              ████   ██ ██    ██ ██ ████  ████",
    "              ██ ██  ██ ██    ██ ██ ██ ████ ██",
    "              ██  ██ ██  ██  ██  ██ ██  ██  ██",
    "              ██   ████   ████   ██ ██      ██",
    " ",
    " ",
    " ",
  },
  plugins = {
    init = {
      {
        "EdenEast/nightfox.nvim",
        config = function()
          require("nightfox").setup {
            -- disable extra plugins that AstroNvim doesn't use (this is optional)
            modules = { 
              barbar = false,
              dashboard = false,
              fern = false,
              fidget = false,
              gitgutter = false,
              glyph_palette = false,
              illuminate = false,
              lightspeed = false,
              lsp_saga = false,
              lsp_trouble = false,
              modes = false,
              neogit = false,
              nvimtree = false,
              pounce = false,
              sneak = false,
              symbols_outline = false,
            },
            groups = {
              all = {
                -- add highlight group for AstroNvim's built in URL highlighting
                HighlightURL = { style = "underline" },
              },
            },
          }
        end,
      },
    },
    treesitter = {
      ensure_installed = {
        "lua",
        "python",
        "java",
        "javascript",
        "typescript",
        "c",
        "cpp",
        "rust",
        "scss",
        "swift",
        "ruby",
        "php",
        "make",
        "json",
        "html",
        "graphql",
        "go",
        "erlang",
        "elixir",
        "dockerfile"
      },
    },
    ["nvim-lsp-installer"] = {
      ensure_installed = {
        "sumneko_lua",
        "clangd",
        "dockerls",
        "eslint",
        "elixirls",
        "erlangls",
        "golangci_lint_ls",
        "graphql",
        "html",
        "jsonls",
        "jdtls",
        "intelephense",
        "pyright",
        "solargraph",
        "rust_analyzer",
        "sourcekit"
      },
    },
  },
}
