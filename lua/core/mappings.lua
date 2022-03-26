local M = {}

local utils = require "core.utils"

local map = vim.keymap.set
local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Remap space as leader key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "

-- Normal --
if utils.is_available "smart-splits.nvim" then
  -- Better window navigation
  map("n", "<C-h>", function()
    require("smart-splits").move_cursor_left()
  end)
  map("n", "<C-j>", function()
    require("smart-splits").move_cursor_down()
  end)
  map("n", "<C-k>", function()
    require("smart-splits").move_cursor_up()
  end)
  map("n", "<C-l>", function()
    require("smart-splits").move_cursor_right()
  end)

  -- Resize with arrows
  map("n", "<C-Up>", function()
    require("smart-splits").resize_up()
  end)
  map("n", "<C-Down>", function()
    require("smart-splits").resize_down()
  end)
  map("n", "<C-Left>", function()
    require("smart-splits").resize_left()
  end)
  map("n", "<C-Right>", function()
    require("smart-splits").resize_right()
  end)
end

-- Navigate buffers
if utils.is_available "bufferline.nvim" then
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
-- <leader>rn: legacy binding here for backwards compatibility but not in which-key (see <leader>lr)
map("n", "<leader>rn", vim.lsp.buf.rename)

-- ForceWrite
map("n", "<C-s>", "<cmd>w!<CR>")

-- ForceQuit
map("n", "<C-q>", "<cmd>q!<CR>")

-- Terminal
if utils.is_available "nvim-toggleterm.lua" then
  map("n", "<C-\\>", "<cmd>ToggleTerm<CR>")
end

-- Normal Leader Mappings --
-- NOTICE: if changed, update configs/which-key-register.lua
-- Allows easy user modifications when just overriding which-key
-- But allows bindings to work for users without which-key
if not utils.is_available "which-key.nvim" then
  -- Standard Operations
  map("n", "<leader>w", "<cmd>w<CR>")
  map("n", "<leader>q", "<cmd>q<CR>")
  map("n", "<leader>h", "<cmd>nohlsearch<CR>")

  if utils.is_available "vim-bbye" then
    map("n", "<leader>c", "<cmd>Bdelete!<CR>")
  end

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
  map("n", "<leader>la", vim.lsp.buf.code_action)
  map("n", "<leader>lr", vim.lsp.buf.rename)
  map("n", "<leader>ld", vim.diagnostic.open_float)

  -- NeoTree
  if utils.is_available "neo-tree.nvim" then
    map("n", "<leader>e", "<cmd>Neotree toggle<CR>")
    map("n", "<leader>o", "<cmd>Neotree focus<CR>")
  end

  -- Dashboard
  if utils.is_available "dashboard-nvim" then
    map("n", "<leader>d", "<cmd>Dashboard<CR>")
    map("n", "<leader>fn", "<cmd>DashboardNewFile<CR>")
    map("n", "<leader>Sl", "<cmd>SessionLoad<CR>")
    map("n", "<leader>Ss", "<cmd>SessionSave<CR>")
  end

  -- GitSigns
  if utils.is_available "gitsigns.nvim" then
    map("n", "<leader>gj", function()
      require("gitsigns").next_hunk()
    end)
    map("n", "<leader>gk", function()
      require("gitsigns").prev_hunk()
    end)
    map("n", "<leader>gl", function()
      require("gitsigns").blame_line()
    end)
    map("n", "<leader>gp", function()
      require("gitsigns").preview_hunk()
    end)
    map("n", "<leader>gh", function()
      require("gitsigns").reset_hunk()
    end)
    map("n", "<leader>gr", function()
      require("gitsigns").reset_buffer()
    end)
    map("n", "<leader>gs", function()
      require("gitsigns").stage_hunk()
    end)
    map("n", "<leader>gu", function()
      require("gitsigns").undo_stage_hunk()
    end)
    map("n", "<leader>gd", function()
      require("gitsigns").diffthis()
    end)
  end

  -- Telescope
  if utils.is_available "telescope.nvim" then
    map("n", "<leader>fw", function()
      require("telescope.builtin").live_grep()
    end)
    map("n", "<leader>gt", function()
      require("telescope.builtin").git_status()
    end)
    map("n", "<leader>gb", function()
      require("telescope.builtin").git_branches()
    end)
    map("n", "<leader>gc", function()
      require("telescope.builtin").git_commits()
    end)
    map("n", "<leader>ff", function()
      require("telescope.builtin").find_files()
    end)
    map("n", "<leader>fb", function()
      require("telescope.builtin").buffers()
    end)
    map("n", "<leader>fh", function()
      require("telescope.builtin").help_tags()
    end)
    map("n", "<leader>fm", function()
      require("telescope.builtin").marks()
    end)
    map("n", "<leader>fo", function()
      require("telescope.builtin").oldfiles()
    end)
    map("n", "<leader>sb", function()
      require("telescope.builtin").git_branches()
    end)
    map("n", "<leader>sh", function()
      require("telescope.builtin").help_tags()
    end)
    map("n", "<leader>sm", function()
      require("telescope.builtin").man_pages()
    end)
    map("n", "<leader>sn", function()
      require("telescope").extensions.notify.notify()
    end)
    map("n", "<leader>sr", function()
      require("telescope.builtin").registers()
    end)
    map("n", "<leader>sk", function()
      require("telescope.builtin").keymaps()
    end)
    map("n", "<leader>sc", function()
      require("telescope.builtin").commands()
    end)
    map("n", "<leader>ls", function()
      require("telescope.builtin").lsp_document_symbols()
    end)
    map("n", "<leader>lR", function()
      require("telescope.builtin").lsp_references()
    end)
    map("n", "<leader>lD", function()
      require("telescope.builtin").diagnostics()
    end)
  end

  -- Comment
  if utils.is_available "Comment.nvim" then
    map("n", "<leader>/", function()
      require("Comment.api").toggle_current_linewise()
    end)
  end

  -- Terminal
  if utils.is_available "nvim-toggleterm.lua" then
    map("n", "<leader>gg", function()
      utils.toggle_term_cmd "lazygit"
    end)
    map("n", "<leader>tn", function()
      utils.toggle_term_cmd "node"
    end)
    map("n", "<leader>tu", function()
      utils.toggle_term_cmd "ncdu"
    end)
    map("n", "<leader>tt", function()
      utils.toggle_term_cmd "htop"
    end)
    map("n", "<leader>tp", function()
      utils.toggle_term_cmd "python"
    end)
    map("n", "<leader>tl", function()
      utils.toggle_term_cmd "lazygit"
    end)
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>")
    map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>")
    map("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>")
  end

  -- SymbolsOutline
  if utils.is_available "symbols-outline.nvim" then
    map("n", "<leader>lS", "<cmd>SymbolsOutline<CR>")
  end
end

-- Visual --
-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move text up and down
map("v", "<A-j>", "<cmd>m .+1<CR>==")
map("v", "<A-k>", "<cmd>m .-2<CR>==")

-- Comment
if utils.is_available "Comment.nvim" then
  map("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>")
end

-- Visual Block --
-- Move text up and down
map("x", "J", "<cmd>move '>+1<CR>gv-gv")
map("x", "K", "<cmd>move '<-2<CR>gv-gv")
map("x", "<A-j>", "<cmd>move '>+1<CR>gv-gv")
map("x", "<A-k>", "<cmd>move '<-2<CR>gv-gv")

-- disable Ex mode:
map("n", "Q", "<Nop>")

function _G.set_terminal_keymaps()
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], {})
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], {})
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], {})
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], {})
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], {})
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], {})
end

augroup("TermMappings", {})
cmd("TermOpen", {
  desc = "Set terminal keymaps",
  group = "TermMappings",
  callback = _G.set_terminal_keymaps,
})

return M
