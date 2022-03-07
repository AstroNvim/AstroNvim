local M = {}

function M.config()
  local status_ok, which_key = pcall(require, "which-key")
  if not status_ok then
    return
  end

  local default_setup = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    key_labels = {},
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    popup_mappings = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    window = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    ignore_missing = true,
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    show_help = true,
    triggers = "auto",
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
  }

  local opts = {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
  }

  local mappings = {
    ["d"] = { "Dashboard" },
    ["e"] = { "Explorer" },
    ["w"] = { "Save" },
    ["q"] = { "Quit" },
    ["c"] = { "Close Buffer" },
    ["h"] = { "No Highlight" },
    ["/"] = { "Comment" },

    p = {
      name = "Packer",
      c = { "Compile" },
      i = { "Install" },
      s = { "Sync" },
      S = { "Status" },
      u = { "Update" },
    },

    g = {
      name = "Git",
      g = { "Lazygit" },
      j = { "Next Hunk" },
      k = { "Prev Hunk" },
      l = { "Blame" },
      p = { "Preview Hunk" },
      h = { "Reset Hunk" },
      r = { "Reset Buffer" },
      s = { "Stage Hunk" },
      u = { "Undo Stage Hunk" },
      t = { "Open changed file" },
      b = { "Checkout branch" },
      c = { "Checkout commit" },
      d = { "Diff" },
    },

    l = {
      name = "LSP",
      a = { "Code Action" },
      f = { "Format" },
      i = { "Info" },
      I = { "Installer Info" },
      r = { "Rename" },
      s = { "Document Symbols" },
    },

    s = {
      name = "Search",
      b = { "Checkout branch" },
      h = { "Find Help" },
      m = { "Man Pages" },
      r = { "Registers" },
      k = { "Keymaps" },
      c = { "Commands" },
    },

    t = {
      name = "Terminal",
      n = { "Node" },
      u = { "NCDU" },
      t = { "Htop" },
      p = { "Python" },
      l = { "LazyGit" },
      f = { "Float" },
      h = { "Horizontal" },
      v = { "Vertical" },
    },
  }

  which_key.setup(require("core.utils").user_plugin_opts("which-key", default_setup))
  which_key.register(require("core.utils").user_plugin_opts("which-key-mappings", mappings), opts)
end

return M
