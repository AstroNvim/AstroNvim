local M = {}

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

-- NvimTree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", opts)
map("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", opts)

-- Dashboard
map("n", "<leader>fn", "<cmd>DashboardNewFile<CR>", opts)
map("n", "<leader>db", "<cmd>Dashboard<CR>", opts)
map("n", "<leader>bm", "<cmd>DashboardJumpMarks<CR>", opts)
map("n", "<leader>sl", "<cmd>SessionLoad<CR>", opts)
map("n", "<leader>ss", "<cmd>SessionSave<CR>", opts)

-- Telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", opts)
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", opts)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", opts)

-- Lspsaga
map("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
map("n", "ca", "<cmd>Lspsaga code_action<CR>", opts)
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
map("n", "rn", "<cmd>Lspsaga rename<CR>", opts)
map("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
map("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
map("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", opts)
map("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", opts)

-- Comment
map("n", "<leader>/", "<cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opts)
map("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opts)

-- ForceWrite
map("n", "<C-w>", "<cmd>w!<CR>", opts)

-- ForceQuit
map("n", "<C-q>", "<cmd>q!<CR>", opts)

-- Terminal
map("n", "<C-\\>", "<cmd>ToggleTerm<CR>", opts)

-- SymbolsOutline
map("n", "<leader>s", "<cmd>SymbolsOutline<CR>", opts)

-- SaveSession
map("n", "<leader>ss", "<cmd>SessionSave<CR>", opts)

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

return M
