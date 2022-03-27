local M = {}

local config = require("core.utils").user_settings()

local map = vim.keymap.set

-- Remap space as leader key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
-- Better window navigation
map("n", "<C-h>", require("smart-splits").move_cursor_left)
map("n", "<C-j>", require("smart-splits").move_cursor_down)
map("n", "<C-j>", require("smart-splits").move_cursor_up)
map("n", "<C-l>", require("smart-splits").move_cursor_right)

-- Resize with arrows
map("n", "<C-Up>", require("smart-splits").resize_up)
map("n", "<C-Down>", require("smart-splits").resize_down)
map("n", "<C-Left>", require("smart-splits").resize_left)
map("n", "<C-Right>", require("smart-splits").resize_right)

-- Navigate buffers
if config.enabled.bufferline then
  map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>")
  map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>")
  map("n", "}", "<cmd>BufferLineMoveNext<cr>")
  map("n", "{", "<cmd>BufferLineMovePrev<cr>")
else
  map("n", "<S-l>", "<cmd>bnext<CR>")
  map("n", "<S-h>", "<cmd>bprevious<CR>")
end

-- Move text up and down
map("n", "<A-j>", "<Esc><cmd>m .+1<CR>==gi")
map("n", "<A-k>", "<Esc><cmd>m .-2<CR>==gi")

-- Standard Operations
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")
map("n", "<leader>c", "<cmd>Bdelete!<CR>")
map("n", "<leader>h", "<cmd>nohlsearch<CR>")

-- Packer
map("n", "<leader>pc", "<cmd>PackerCompile<cr>")
map("n", "<leader>pi", "<cmd>PackerInstall<cr>")
map("n", "<leader>ps", "<cmd>PackerSync<cr>")
map("n", "<leader>pS", "<cmd>PackerStatus<cr>")
map("n", "<leader>pu", "<cmd>PackerUpdate<cr>")

-- LSP
map("n", "<leader>lf", vim.lsp.buf.formatting_sync)
map("n", "<leader>li", "<cmd>LspInfo<cr>")
map("n", "<leader>lI", "<cmd>LspInstallInfo<cr>")

-- NvimTree
if config.enabled.nvim_tree then
  map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
  map("n", "<leader>o", "<cmd>NvimTreeFocus<CR>")
end

-- Dashboard
if config.enabled.dashboard then
  map("n", "<leader>d", "<cmd>Dashboard<CR>")
  map("n", "<leader>fn", "<cmd>DashboardNewFile<CR>")
  map("n", "<leader>db", "<cmd>Dashboard<CR>")
  map("n", "<leader>bm", "<cmd>DashboardJumpMarks<CR>")
  map("n", "<leader>sl", "<cmd>SessionLoad<CR>")
  map("n", "<leader>ss", "<cmd>SessionSave<CR>")
end

-- GitSigns
if config.enabled.gitsigns then
  map("n", "<leader>gj", require("gitsigns").next_hunk)
  map("n", "<leader>gk", require("gitsigns").prev_hunk)
  map("n", "<leader>gl", require("gitsigns").blame_line)
  map("n", "<leader>gp", require("gitsigns").preview_hunk)
  map("n", "<leader>gh", require("gitsigns").reset_hunk)
  map("n", "<leader>gr", require("gitsigns").reset_buffer)
  map("n", "<leader>gs", require("gitsigns").stage_hunk)
  map("n", "<ledaer>gu", require("gitsigns").undo_stage_hunk)
  map("n", "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>")
end

-- Telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>")
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>")
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>")
map("n", "<leader>sb", "<cmd>Telescope git_branches<CR>")
map("n", "<leader>sh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>sm", "<cmd>Telescope man_pages<CR>")
map("n", "<leader>sn", "<cmd>Telescope notify<CR>")
map("n", "<leader>sr", "<cmd>Telescope registers<CR>")
map("n", "<leader>sk", "<cmd>Telescope keymaps<CR>")
map("n", "<leader>sc", "<cmd>Telescope commands<CR>")
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>")
map("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>")
map("n", "<leader>lD", "<cmd>Telescope diagnostics<CR>")

-- LSP
map("n", "gD", vim.lsp.buf.declaration)
map("n", "gd", vim.lsp.buf.definition, { desc = "Show the definition of current function" })
map("n", "gI", vim.lsp.buf.implementation)
map("n", "gr", vim.lsp.buf.references)
map("n", "go", vim.diagnostic.open_float)
map("n", "gl", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "gk", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "gj", vim.diagnostic.goto_next)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>la", vim.lsp.buf.code_action)
map("n", "<leader>lr", vim.lsp.buf.rename)
map("n", "<leader>ld", vim.diagnostic.open_float)

-- Comment
if config.enabled.comment then
  map("n", "<leader>/", require("Comment.api").toggle_current_linewise)
  map("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>")
end

-- ForceWrite
map("n", "<C-s>", "<cmd>w!<CR>")

-- ForceQuit
map("n", "<C-q>", "<cmd>q!<CR>")

-- Terminal
if config.enabled.toggle_term then
  map("n", "<C-\\>", "<cmd>ToggleTerm<CR>")
  map("n", "<leader>gg", function()
    return _LAZYGIT_TOGGLE()
  end)
  map("n", "<leader>tn", function()
    return _NODE_TOGGLE()
  end)
  map("n", "leader>tu", function()
    return _NCDU_TOGGLE()
  end)
  map("n", "<leader>tt", function()
    return _HTOP_TOGGLE()
  end)
  map("n", "<ledaer>tp", function()
    return _PYTHON_TOGGLE()
  end)
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>")
  map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>")
  map("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>")
end

-- SymbolsOutline
if config.enabled.symbols_outline then
  map("n", "<leader>lS", "<cmd>SymbolsOutline<CR>")
end

-- Visual --
-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move text up and down
map("v", "<A-j>", "<cmd>m .+1<CR>==")
map("v", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "p", '"_dP')

-- Visual Block --
-- Move text up and down
map("x", "J", "<cmd>move '>+1<CR>gv-gv")
map("x", "K", "<cmd>move '<-2<CR>gv-gv")
map("x", "<A-j>", "<cmd>move '>+1<CR>gv-gv")
map("x", "<A-k>", "<cmd>move '<-2<CR>gv-gv")

-- disable Ex mode:
map("n", "Q", "<Nop>")

function _G.set_terminal_keymaps()
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]])
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]])
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]])
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]])
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]])
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]])
end

vim.cmd [[
  augroup TermMappings
    autocmd! TermOpen term://* lua set_terminal_keymaps()
  augroup END
]]

return M
