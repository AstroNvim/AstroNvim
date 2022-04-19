local M = {}

local utils = require "core.utils"

local status_ok, which_key = pcall(require, "which-key")
if status_ok then
  local opts = {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
  }

  local mappings = {
    ["w"] = { "<cmd>w<CR>", "Save" },
    ["q"] = { "<cmd>q<CR>", "Quit" },
    ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },

    p = {
      name = "Packer",
      c = { "<cmd>PackerCompile<cr>", "Compile" },
      i = { "<cmd>PackerInstall<cr>", "Install" },
      s = { "<cmd>PackerSync<cr>", "Sync" },
      S = { "<cmd>PackerStatus<cr>", "Status" },
      u = { "<cmd>PackerUpdate<cr>", "Update" },
    },

    l = {
      name = "LSP",
      a = { vim.lsp.buf.code_action, "Code Action" },
      d = { vim.diagnostic.open_float, "Hover Diagnostic" },
      f = { vim.lsp.buf.formatting_sync, "Format" },
      i = { "<cmd>LspInfo<cr>", "Info" },
      I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
      r = { vim.lsp.buf.rename, "Rename" },
    },
  }

  local extra_sections = {
    f = "File",
    g = "Git",
    l = "LSP",
    s = "Search",
    t = "Terminal",
    S = "Session",
  }

  local function init_table(idx)
    if not mappings[idx] then
      mappings[idx] = { name = extra_sections[idx] }
    end
  end

  if utils.is_available "neo-tree.nvim" then
    mappings.e = { "<cmd>Neotree toggle<CR>", "Toggle Explorer" }
    mappings.o = { "<cmd>Neotree focus<CR>", "Focus Explorer" }
  end

  if utils.is_available "dashboard-nvim" then
    mappings.d = { "<cmd>Dashboard<CR>", "Dashboard" }

    init_table "f"
    mappings.f.n = { "<cmd>DashboardNewFile<CR>", "New File" }

    init_table "S"
    mappings.S.s = { "<cmd>SessionLoad<CR>", "Save Session" }
    mappings.S.l = { "<cmd>SessionSave<CR>", "Load Session" }
  end

  if utils.is_available "Comment.nvim" then
    mappings["/"] = {
      function()
        require("Comment.api").toggle_current_linewise()
      end,
      "Comment",
    }
  end

  if utils.is_available "vim-bbye" then
    mappings.c = { "<cmd>Bdelete!<CR>", "Close Buffer" }
  end

  if utils.is_available "gitsigns.nvim" then
    init_table "g"
    mappings.g.j = {
      function()
        require("gitsigns").next_hunk()
      end,
      "Next Hunk",
    }
    mappings.g.k = {
      function()
        require("gitsigns").prev_hunk()
      end,
      "Prev Hunk",
    }
    mappings.g.l = {
      function()
        require("gitsigns").blame_line()
      end,
      "Blame",
    }
    mappings.g.p = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview Hunk",
    }
    mappings.g.h = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset Hunk",
    }
    mappings.g.r = {
      function()
        require("gitsigns").reset_buffer()
      end,
      "Reset Buffer",
    }
    mappings.g.s = {
      function()
        require("gitsigns").stage_hunk()
      end,
      "Stage Hunk",
    }
    mappings.g.u = {
      function()
        require("gitsigns").undo_stage_hunk()
      end,
      "Undo Stage Hunk",
    }
    mappings.g.d = {
      function()
        require("gitsigns").diffthis()
      end,
      "Diff",
    }
  end

  if utils.is_available "nvim-toggleterm.lua" then
    init_table "g"
    mappings.g.g = {
      function()
        require("core.utils").toggle_term_cmd "lazygit"
      end,
      "Lazygit",
    }

    init_table "t"
    mappings.t.n = {
      function()
        require("core.utils").toggle_term_cmd "node"
      end,
      "Node",
    }
    mappings.t.u = {
      function()
        require("core.utils").toggle_term_cmd "ncdu"
      end,
      "NCDU",
    }
    mappings.t.t = {
      function()
        require("core.utils").toggle_term_cmd "htop"
      end,
      "Htop",
    }
    mappings.t.p = {
      function()
        require("core.utils").toggle_term_cmd "python"
      end,
      "Python",
    }
    mappings.t.l = {
      function()
        require("core.utils").toggle_term_cmd "lazygit"
      end,
      "Lazygit",
    }
    mappings.t.f = { "<cmd>ToggleTerm direction=float<cr>", "Float" }
    mappings.t.h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" }
    mappings.t.v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" }
  end

  if utils.is_available "symbols-outline.nvim" then
    init_table "l"
    mappings.l.S = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" }
  end

  if utils.is_available "telescope.nvim" then
    init_table "s"
    mappings.s.b = {
      function()
        require("telescope.builtin").git_branches()
      end,
      "Checkout branch",
    }
    mappings.s.h = {
      function()
        require("telescope.builtin").help_tags()
      end,
      "Find Help",
    }
    mappings.s.m = {
      function()
        require("telescope.builtin").man_pages()
      end,
      "Man Pages",
    }
    mappings.s.n = {
      function()
        require("telescope").extensions.notify.notify()
      end,
      "Notifications",
    }
    mappings.s.r = {
      function()
        require("telescope.builtin").registers()
      end,
      "Registers",
    }
    mappings.s.k = {
      function()
        require("telescope.builtin").keymaps()
      end,
      "Keymaps",
    }
    mappings.s.c = {
      function()
        require("telescope.builtin").commands()
      end,
      "Commands",
    }

    init_table "g"
    mappings.g.t = {
      function()
        require("telescope.builtin").git_status()
      end,
      "Open changed file",
    }
    mappings.g.b = {
      function()
        require("telescope.builtin").git_branches()
      end,
      "Checkout branch",
    }
    mappings.g.c = {
      function()
        require("telescope.builtin").git_commits()
      end,
      "Checkout commit",
    }

    init_table "f"
    mappings.f.b = {
      function()
        require("telescope.builtin").buffers()
      end,
      "Find Buffers",
    }
    mappings.f.f = {
      function()
        require("telescope.builtin").find_files()
      end,
      "Find Files",
    }
    mappings.f.h = {
      function()
        require("telescope.builtin").help_tags()
      end,
      "Find Help",
    }
    mappings.f.m = {
      function()
        require("telescope.builtin").marks()
      end,
      "Find Marks",
    }
    mappings.f.o = {
      function()
        require("telescope.builtin").oldfiles()
      end,
      "Find Old Files",
    }
    mappings.f.w = {
      function()
        require("telescope.builtin").live_grep()
      end,
      "Find Words",
    }

    init_table "l"
    mappings.l.s = {
      function()
        require("telescope.builtin").lsp_document_symbols()
      end,
      "Document Symbols",
    }
    mappings.l.R = {
      function()
        require("telescope.builtin").lsp_references()
      end,
      "References",
    }
    mappings.l.D = {
      function()
        require("telescope.builtin").diagnostics()
      end,
      "All Diagnostics",
    }
  end

  which_key.register(require("core.utils").user_plugin_opts("which-key.register_n_leader", mappings), opts)
end

return M
