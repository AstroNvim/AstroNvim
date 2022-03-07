local M = {}

local config = require("core.utils").user_settings()

local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- Remap space as leader key
map("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
map("n", "<C-Up>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Navigate buffers
map("n", "<S-l>", "<cmd>bnext<CR>", opts)
map("n", "<S-h>", "<cmd>bprevious<CR>", opts)

-- Move text up and down
map("n", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", opts)
map("n", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", opts)

-- Standard Operations
map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>q", "<cmd>q<CR>", opts)
map("n", "<leader>c", "<cmd>Bdelete!<CR>", opts)
map("n", "<leader>h", "<cmd>noholsearch<CR>", opts)

-- Packer
map("n", "<leader>pc", "<cmd>PackerCompile<cr>", opts)
map("n", "<leader>pi", "<cmd>PackerInstall<cr>", opts)
map("n", "<leader>ps", "<cmd>PackerSync<cr>", opts)
map("n", "<leader>pS", "<cmd>PackerStatus<cr>", opts)
map("n", "<leader>pu", "<cmd>PackerUpdate<cr>", opts)

-- LSP
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting_sync()<cr>", opts)
map("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
map("n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)

-- NvimTree
if config.enabled.nvim_tree then
  map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", opts)
  map("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", opts)
end

-- Dashboard
if config.enabled.dashboard then
  map("n", "<leader>d", "<cmd>Dashboard<CR>", opts)
  map("n", "<leader>fn", "<cmd>DashboardNewFile<CR>", opts)
  map("n", "<leader>db", "<cmd>Dashboard<CR>", opts)
  map("n", "<leader>bm", "<cmd>DashboardJumpMarks<CR>", opts)
  map("n", "<leader>sl", "<cmd>SessionLoad<CR>", opts)
  map("n", "<leader>ss", "<cmd>SessionSave<CR>", opts)
end

-- GitSigns
if config.enabled.gitsigns then
  map("n", "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", opts)
  map("n", "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", opts)
  map("n", "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", opts)
  map("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", opts)
  map("n", "<leader>gh", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", opts)
  map("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", opts)
  map("n", "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", opts)
  map("n", "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", opts)
  map("n", "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", opts)
end

-- Telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", opts)
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", opts)
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", opts)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", opts)
map("n", "<leader>sb", "<cmd>Telescope git_branches<CR>", opts)
map("n", "<leader>sh", "<cmd>Telescope help_tags<CR>", opts)
map("n", "<leader>sm", "<cmd>Telescope man_pages<CR>", opts)
map("n", "<leader>sr", "<cmd>Telescope registers<CR>", opts)
map("n", "<leader>sk", "<cmd>Telescope keymaps<CR>", opts)
map("n", "<leader>sc", "<cmd>Telescope commands<CR>", opts)
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", opts)

-- Lspsaga
if config.enabled.lspsaga then
  map("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  map("n", "ca", "<cmd>Lspsaga code_action<CR>", opts)
  map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
  map("n", "rn", "<cmd>Lspsaga rename<CR>", opts)
  map("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
  map("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
  map("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", opts)
  map("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", opts)
  map("n", "<leader>la", "<cmd>Lspsaga code_action<CR>", opts)
  map("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", opts)
end

-- Comment
if config.enabled.comment then
  map("n", "<leader>/", "<cmd>lua require('Comment.api').toggle_current_linewise()<cr>", opts)
  map("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opts)
end

-- ForceWrite
map("n", "<C-w>", "<cmd>w!<CR>", opts)

-- ForceQuit
map("n", "<C-q>", "<cmd>q!<CR>", opts)

-- Terminal
if config.enabled.toggle_term then
  map("n", "<C-\\>", "<cmd>ToggleTerm<CR>", opts)
  map("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)
  map("n", "<leader>tn", "<cmd>lua _NODE_TOGGLE()<CR>", opts)
  map("n", "<leader>tu", "<cmd>lua _NCDU_TOGGLE()<CR>", opts)
  map("n", "<leader>tt", "<cmd>lua _HTOP_TOGGLE()<CR>", opts)
  map("n", "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<CR>", opts)
  map("n", "<leader>tl", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
  map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", opts)
  map("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", opts)
end

-- SymbolsOutline
if config.enabled.symbols_outline then
  map("n", "<leader>s", "<cmd>SymbolsOutline<CR>", opts)
end

-- Visual --
-- Stay in indent mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move text up and down
map("v", "<A-j>", "<cmd>m .+1<CR>==", opts)
map("v", "<A-k>", "<cmd>m .-2<CR>==", opts)
map("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
map("x", "J", "<cmd>move '>+1<CR>gv-gv", opts)
map("x", "K", "<cmd>move '<-2<CR>gv-gv", opts)
map("x", "<A-j>", "<cmd>move '>+1<CR>gv-gv", opts)
map("x", "<A-k>", "<cmd>move '<-2<CR>gv-gv", opts)

-- disable Ex mode:
map("n", "Q", "<Nop>", opts)

return M
