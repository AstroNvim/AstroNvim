local M = {}

local utils = require "core.utils"

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local opts = {
  mode = "n",
  prefix = "<leader>",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
}

local mappings = {
  ["w"] = { "Save" },
  ["q"] = { "Quit" },
  ["h"] = { "No Highlight" },

  p = {
    name = "Packer",
    c = { "Compile" },
    i = { "Install" },
    s = { "Sync" },
    S = { "Status" },
    u = { "Update" },
  },

  l = {
    name = "LSP",
    a = { "Code Action" },
    d = { "Hover Diagnostic" },
    f = { "Format" },
    i = { "Info" },
    I = { "Installer Info" },
    r = { "Rename" },
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
  mappings.e = { "Toggle Explorer" }
  mappings.o = { "Focus Explorer" }
end

if utils.is_available "dashboard-nvim" then
  mappings.d = { "Dashboard" }

  init_table "f"
  mappings.f.n = { "New File" }

  init_table "S"
  mappings.S.s = { "Save Session" }
  mappings.S.l = { "Load Session" }
end

if utils.is_available "Comment.nvim" then
  mappings["/"] = { "Comment" }
end

if utils.is_available "vim-bbye" then
  mappings.c = { "Close Buffer" }
end

if utils.is_available "gitsigns.nvim" then
  init_table "g"
  mappings.g.j = { "Next Hunk" }
  mappings.g.k = { "Prev Hunk" }
  mappings.g.l = { "Blame" }
  mappings.g.p = { "Preview Hunk" }
  mappings.g.h = { "Reset Hunk" }
  mappings.g.r = { "Reset Buffer" }
  mappings.g.s = { "Stage Hunk" }
  mappings.g.u = { "Undo Stage Hunk" }
  mappings.g.d = { "Diff" }
end

if utils.is_available "gitsigns.nvim" then
  init_table "g"
  mappings.g.t = { "Open changed file" }
  mappings.g.b = { "Checkout branch" }
  mappings.g.c = { "Checkout commit" }
end

if utils.is_available "nvim-toggleterm.lua" then
  init_table "g"
  mappings.g.g = { "Lazygit" }

  init_table "t"
  mappings.t.n = { "Node" }
  mappings.t.u = { "NCDU" }
  mappings.t.t = { "Htop" }
  mappings.t.p = { "Python" }
  mappings.t.f = { "Float" }
  mappings.t.h = { "Horizontal" }
  mappings.t.v = { "Vertical" }
end

if utils.is_available "symbols-outline.nvim" then
  init_table "l"
  mappings.l.S = { "Symbols Outline" }
end

if utils.is_available "nvim-telescope/telescope.nvim" then
  init_table "s"
  mappings.s.b = { "Checkout branch" }
  mappings.s.h = { "Find Help" }
  mappings.s.m = { "Man Pages" }
  mappings.s.n = { "Notifications" }
  mappings.s.r = { "Registers" }
  mappings.s.k = { "Keymaps" }
  mappings.s.c = { "Commands" }

  init_table "g"
  mappings.g.t = { "Open changed file" }
  mappings.g.b = { "Checkout branch" }
  mappings.g.c = { "Checkout commit" }

  init_table "f"
  mappings.f.b = { "Find Buffers" }
  mappings.f.f = { "Find Files" }
  mappings.f.h = { "Find Help" }
  mappings.f.m = { "Find Marks" }
  mappings.f.o = { "Find Old Files" }
  mappings.f.w = { "Find Words" }

  init_table "l"
  mappings.l.s = { "Document Symbols" }
  mappings.l.R = { "References" }
  mappings.l.D = { "All Diagnostics" }
end

which_key.register(require("core.utils").user_plugin_opts("which-key.register_n_leader", mappings), opts)

return M
