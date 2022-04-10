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
    a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
    d = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Hover Diagnostic" },
    f = { "<cmd>lua vim.lsp.buf.formatting_sync()<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
    r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
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
  mappings["/"] = { "<cmd>lua require('Comment.api').toggle_current_linewise()<cr>", "Comment" }
end

if utils.is_available "vim-bbye" then
  mappings.c = { "<cmd>Bdelete!<CR>", "Close Buffer" }
end

if utils.is_available "gitsigns.nvim" then
  init_table "g"
  mappings.g.j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" }
  mappings.g.k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" }
  mappings.g.l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" }
  mappings.g.p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" }
  mappings.g.h = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" }
  mappings.g.r = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" }
  mappings.g.s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" }
  mappings.g.u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" }
  mappings.g.d = { "<cmd>lua require 'gitsigns'.diffthis()<cr>", "Diff" }
end

if utils.is_available "nvim-toggleterm.lua" then
  init_table "g"
  mappings.g.g = { "<cmd>lua require('core.utils').toggle_term_cmd('lazygit')<CR>", "Lazygit" }

  init_table "t"
  mappings.t.n = { "<cmd>lua require('core.utils').toggle_term_cmd('node')<CR>", "Node" }
  mappings.t.u = { "<cmd>lua require('core.utils').toggle_term_cmd('ncdu')<CR>", "NCDU" }
  mappings.t.t = { "<cmd>lua require('core.utils').toggle_term_cmd('htop')<CR>", "Htop" }
  mappings.t.p = { "<cmd>lua require('core.utils').toggle_term_cmd('python')<CR>", "Python" }
  mappings.t.l = { "<cmd>lua require('core.utils').toggle_term_cmd('lazygit')<CR>", "Lazygit" }
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
  mappings.s.b = { "<cmd>Telescope git_branches<CR>", "Checkout branch" }
  mappings.s.h = { "<cmd>Telescope help_tags<CR>", "Find Help" }
  mappings.s.m = { "<cmd>Telescope man_pages<CR>", "Man Pages" }
  mappings.s.n = { "<cmd>Telescope notify<CR>", "Notifications" }
  mappings.s.r = { "<cmd>Telescope registers<CR>", "Registers" }
  mappings.s.k = { "<cmd>Telescope keymaps<CR>", "Keymaps" }
  mappings.s.c = { "<cmd>Telescope commands<CR>", "Commands" }

  init_table "g"
  mappings.g.t = { "<cmd>Telescope git_status<CR>", "Open changed file" }
  mappings.g.b = { "<cmd>Telescope git_branches<CR>", "Checkout branch" }
  mappings.g.c = { "<cmd>Telescope git_commits<CR>", "Checkout commit" }

  init_table "f"
  mappings.f.b = { "<cmd>Telescope buffers<CR>", "Find Buffers" }
  mappings.f.f = { "<cmd>Telescope find_files<CR>", "Find Files" }
  mappings.f.h = { "<cmd>Telescope help_tags<CR>", "Find Help" }
  mappings.f.m = { "<cmd>Telescope marks<CR>", "Find Marks" }
  mappings.f.o = { "<cmd>Telescope oldfiles<CR>", "Find Old Files" }
  mappings.f.w = { "<cmd>Telescope live_grep<CR>", "Find Words" }

  init_table "l"
  mappings.l.s = { "<cmd>Telescope lsp_document_symbols<CR>", "Document Symbols" }
  mappings.l.R = { "<cmd>Telescope lsp_references<CR>", "References" }
  mappings.l.D = { "<cmd>Telescope diagnostics<CR>", "All Diagnostics" }
end

which_key.register(require("core.utils").user_plugin_opts("which-key.register_n_leader", mappings), opts)

return M
