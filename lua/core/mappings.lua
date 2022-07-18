local is_available = astronvim.is_available

local maps = { n = {}, v = {}, t = {}, [""] = {} }

local bool2str = function(bool)
  return bool and "on" or "off"
end

-- Toggle background="dark"|"light"
local toggle_background = function()
  local background = vim.go.background  -- global
  if background == "light" then
    vim.go.background = "dark"
  else
    vim.go.background = "light"
  end
  print(string.format("background=%s", vim.go.background))
end

-- Toggle completion (by running cmp setup again). 
-- https://github.com/hrsh7th/nvim-cmp/issues/429
-- https://neovim.discourse.group/t/toggle-nvim-cmp/2520/2
-- https://www.reddit.com/r/neovim/comments/rh0ohq/nvimcmp_temporarily_disable_autocompletion/
-- https://www.littlehart.net/atthekeyboard/2021/11/12/grumpy-nvim-setup/
-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/init.lua
-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques

-- toggle_completion() -- <leader>tc -- toggle completion
-- https://github.com/hrsh7th/nvim-cmp/issues/261
-- My own old solution
-- https://github.com/hrsh7th/nvim-cmp/issues/106
-- require('cmp').setup.buffer { enabled = false } -- new calling convention
vim.g.cmp_toggle_flag = true -- initialize
local normal_buftype = function()
  return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt'
end
local toggle_completion = function()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    local next_cmp_toggle_flag = not vim.g.cmp_toggle_flag
    if next_cmp_toggle_flag then
      print("completion on")
    else
      print("completion off")
    end
    cmp.setup.buffer {
      enabled = function()
        vim.g.cmp_toggle_flag = next_cmp_toggle_flag
        if next_cmp_toggle_flag then
          return normal_buftype
        else
          return next_cmp_toggle_flag
        end
      end
    }
  else
    print("completion not available")
  end
end

-- 
-- 
-- Toggle signcolumn="auto"|"no"
local toggle_signcolumn = function()
  local signcolumn = vim.wo.signcolumn  -- local to window
  if signcolumn == "no" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  print(string.format("signcolumn=%s", vim.wo.signcolumn))
end

-- Set the indent and tab related numbers.
local set_indent = function()
  local indent = tonumber(
    vim.fn.input("Set indent value (>0 expandtab, <=0 noexpandtab, 0 vim defaults): ")
  )
  if not indent then
    indent = -8                         -- noexpandtab, tabstop=8
  end
  vim.bo.expandtab = (indent > 0)       -- local to buffer
  indent = math.abs(indent)
  vim.bo.tabstop = indent               -- local to buffer
  vim.bo.softtabstop = indent           -- local to buffer
  vim.bo.shiftwidth = indent            -- local to buffer
  print(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
end

-- Change the number display modes.
local change_number = function()
  local number = vim.wo.number          -- local to window
  local relativenumber = vim.wo.relativenumber  -- local to window
  if (number == false) and (relativenumber == false) then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif (number == true) and (relativenumber == false) then
    vim.wo.number = false
    vim.wo.relativenumber = true
  elseif (number == false) and (relativenumber == true) then
    vim.wo.number = true
    vim.wo.relativenumber = true
  else -- (number == true) and (relativenumber == true) then
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
  print(
    string.format("number=%s, relativenumber=%s",
      bool2str(vim.wo.number),
      bool2str(vim.wo.relativenumber)
    )
  )
end

-- Toggle spell.
local toggle_spell = function()
  vim.wo.spell = not vim.wo.spell       -- local to window
  print(string.format("spell=%s", bool2str(vim.wo.spell)))
end

-- Toggle syntax/treesitter
local change_syntax = function()
  local parsers = require("nvim-treesitter.parsers")
  if parsers.has_parser() then
    if vim.g.syntax_on then               -- local to buffer
      vim.cmd("TSBufDisable highlight")
      vim.cmd("syntax off")
    else
      vim.cmd("TSBufEnable highlight")
      vim.cmd("syntax on")
    end
    local state = bool2str(vim.g.syntax_on)
    print(string.format("treesitter %s", state))
  else
    if vim.g.syntax_on then
      vim.cmd("syntax off")
    else
      vim.cmd("syntax on")
    end
    local state = bool2str(vim.g.syntax_on)
    print(string.format("syntax %s", state))
  end
end


maps[""]["<Space>"] = "<Nop>"

-- Normal --
-- Standard Operations
maps.n["<leader>w"] = { "<cmd>w<cr>", desc = "Save" }
maps.n["<leader>q"] = { "<cmd>q<cr>", desc = "Quit" }
maps.n["<leader>h"] = { "<cmd>nohlsearch<cr>", desc = "No Highlight" }
maps.n["<leader>fn"] = { "<cmd>enew<cr>", desc = "New File" }
maps.n["gx"] = { function() astronvim.url_opener() end, desc = "Open the file under cursor with system app" }
maps.n["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" }
maps.n["<C-q>"] = { "<cmd>q!<cr>", desc = "Force quit" }
maps.n["Q"] = "<Nop>"

-- Packer
maps.n["<leader>pc"] = { "<cmd>PackerCompile<cr>", desc = "Packer Compile" }
maps.n["<leader>pi"] = { "<cmd>PackerInstall<cr>", desc = "Packer Install" }
maps.n["<leader>ps"] = { "<cmd>PackerSync<cr>", desc = "Packer Sync" }
maps.n["<leader>pS"] = { "<cmd>PackerStatus<cr>", desc = "Packer Status" }
maps.n["<leader>pu"] = { "<cmd>PackerUpdate<cr>", desc = "Packer Update" }

-- Alpha
if is_available "alpha-nvim" then maps.n["<leader>d"] = { "<cmd>Alpha<cr>", desc = "Alpha Dashboard" } end

-- Bufdelete
if is_available "bufdelete.nvim" then
  maps.n["<leader>c"] = { "<cmd>Bdelete<cr>", desc = "Close window" }
else
  maps.n["<leader>c"] = { "<cmd>bdelete<cr>", desc = "Close window" }
end

-- Navigate buffers
if is_available "bufferline.nvim" then
  maps.n["<S-l>"] = { "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer tab" }
  maps.n["<S-h>"] = { "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer tab" }
  maps.n[">b"] = { "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer tab right" }
  maps.n["<b"] = { "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer tab left" }
else
  maps.n["<S-l>"] = { "<cmd>bnext<cr>", desc = "Next buffer" }
  maps.n["<S-h>"] = { "<cmd>bprevious<cr>", desc = "Previous buffer" }
end

-- Comment
if is_available "Comment.nvim" then
  maps.n["<leader>/"] = { function() require("Comment.api").toggle_current_linewise() end, desc = "Comment line" }
  maps.v["<leader>/"] = {
    "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<cr>",
    desc = "Toggle comment line",
  }
end

-- GitSigns
if is_available "gitsigns.nvim" then
  maps.n["<leader>gj"] = { function() require("gitsigns").next_hunk() end, desc = "Next git hunk" }
  maps.n["<leader>gk"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk" }
  maps.n["<leader>gl"] = { function() require("gitsigns").blame_line() end, desc = "View git blame" }
  maps.n["<leader>gp"] = { function() require("gitsigns").preview_hunk() end, desc = "Preview git hunk" }
  maps.n["<leader>gh"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset git hunk" }
  maps.n["<leader>gr"] = { function() require("gitsigns").reset_buffer() end, desc = "Reset git buffer" }
  maps.n["<leader>gs"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage git hunk" }
  maps.n["<leader>gu"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Unstage git hunk" }
  maps.n["<leader>gd"] = { function() require("gitsigns").diffthis() end, desc = "View git diff" }
end

-- NeoTree
if is_available "neo-tree.nvim" then
  maps.n["<leader>e"] = { "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" }
  maps.n["<leader>o"] = { "<cmd>Neotree focus<cr>", desc = "Focus Explorer" }
end

-- Session Manager
if is_available "neovim-session-manager" then
  maps.n["<leader>Sl"] = { "<cmd>SessionManager! load_last_session<cr>", desc = "Load last session" }
  maps.n["<leader>Ss"] = { "<cmd>SessionManager! save_current_session<cr>", desc = "Save this session" }
  maps.n["<leader>Sd"] = { "<cmd>SessionManager! delete_session<cr>", desc = "Delete session" }
  maps.n["<leader>Sf"] = { "<cmd>SessionManager! load_session<cr>", desc = "Search sessions" }
  maps.n["<leader>S."] =
    { "<cmd>SessionManager! load_current_dir_session<cr>", desc = "Load current directory session" }
end

-- LSP Installer
if is_available "nvim-lsp-installer" then
  maps.n["<leader>li"] = { "<cmd>LspInfo<cr>", desc = "LSP information" }
  maps.n["<leader>lI"] = { "<cmd>LspInstallInfo<cr>", desc = "LSP installer" }
end

-- Smart Splits
if is_available "smart-splits.nvim" then
  -- Better window navigation
  maps.n["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
  maps.n["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
  maps.n["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
  maps.n["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }

  -- Resize with arrows
  maps.n["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
  maps.n["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
  maps.n["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
  maps.n["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
else
  maps.n["<C-h>"] = { "<C-w>h", desc = "Move to left split" }
  maps.n["<C-j>"] = { "<C-w>j", desc = "Move to below split" }
  maps.n["<C-k>"] = { "<C-w>k", desc = "Move to above split" }
  maps.n["<C-l>"] = { "<C-w>l", desc = "Move to right split" }
  maps.n["<C-Up>"] = { "<cmd>resize -2<CR>", desc = "Resize split up" }
  maps.n["<C-Down>"] = { "<cmd>resize +2<CR>", desc = "Resize split down" }
  maps.n["<C-Left>"] = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" }
  maps.n["<C-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" }
end

-- SymbolsOutline
if is_available "aerial.nvim" then maps.n["<leader>lS"] = { "<cmd>AerialToggle<cr>", desc = "Symbols outline" } end

-- Telescope
if is_available "telescope.nvim" then
  maps.n["<leader>fw"] = { function() require("telescope.builtin").live_grep() end, desc = "Search words" }
  maps.n["<leader>fW"] = {
    function()
      require("telescope.builtin").live_grep {
        additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
      }
    end,
    desc = "Search words in all files",
  }
  maps.n["<leader>gt"] = { function() require("telescope.builtin").git_status() end, desc = "Git status" }
  maps.n["<leader>gb"] = { function() require("telescope.builtin").git_branches() end, desc = "Git branches" }
  maps.n["<leader>gc"] = { function() require("telescope.builtin").git_commits() end, desc = "Git commits" }
  maps.n["<leader>ff"] = { function() require("telescope.builtin").find_files() end, desc = "Search files" }
  maps.n["<leader>fF"] = {
    function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
    desc = "Search all files",
  }
  maps.n["<leader>fb"] = { function() require("telescope.builtin").buffers() end, desc = "Search buffers" }
  maps.n["<leader>fh"] = { function() require("telescope.builtin").help_tags() end, desc = "Search help" }
  maps.n["<leader>fm"] = { function() require("telescope.builtin").marks() end, desc = "Search marks" }
  maps.n["<leader>fo"] = { function() require("telescope.builtin").oldfiles() end, desc = "Search history" }
  maps.n["<leader>fc"] =
    { function() require("telescope.builtin").grep_string() end, desc = "Search for word under cursor" }
  maps.n["<leader>sb"] = { function() require("telescope.builtin").git_branches() end, desc = "Git branches" }
  maps.n["<leader>sh"] = { function() require("telescope.builtin").help_tags() end, desc = "Search help" }
  maps.n["<leader>sm"] = { function() require("telescope.builtin").man_pages() end, desc = "Search man" }
  maps.n["<leader>sn"] =
    { function() require("telescope").extensions.notify.notify() end, desc = "Search notifications" }
  maps.n["<leader>sr"] = { function() require("telescope.builtin").registers() end, desc = "Search registers" }
  maps.n["<leader>sk"] = { function() require("telescope.builtin").keymaps() end, desc = "Search keymaps" }
  maps.n["<leader>sc"] = { function() require("telescope.builtin").commands() end, desc = "Search commands" }
  maps.n["<leader>ls"] = {
    function()
      local aerial_avail, _ = pcall(require, "aerial")
      if aerial_avail then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end,
    desc = "Search symbols",
  }
  maps.n["<leader>lR"] = { function() require("telescope.builtin").lsp_references() end, desc = "Search references" }
  maps.n["<leader>lD"] = { function() require("telescope.builtin").diagnostics() end, desc = "Search diagnostics" }
end

-- Terminal
if is_available "toggleterm.nvim" then
  local toggle_term_cmd = astronvim.toggle_term_cmd
  maps.n["<C-\\>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" }
  maps.n["<leader>gg"] = { function() toggle_term_cmd "lazygit" end, desc = "ToggleTerm lazygit" }
  maps.n["<leader>tn"] = { function() toggle_term_cmd "node" end, desc = "ToggleTerm node" }
  maps.n["<leader>tu"] = { function() toggle_term_cmd "ncdu" end, desc = "ToggleTerm NCDU" }
  maps.n["<leader>tt"] = { function() toggle_term_cmd "htop" end, desc = "ToggleTerm htop" }
  maps.n["<leader>tp"] = { function() toggle_term_cmd "python" end, desc = "ToggleTerm python" }
  maps.n["<leader>tl"] = { function() toggle_term_cmd "lazygit" end, desc = "ToggleTerm lazygit" }
  maps.n["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
  maps.n["<leader>th"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
  maps.n["<leader>tv"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
end

-- Stay in indent mode
maps.v["<"] = { "<gv", desc = "unindent line" }
maps.v[">"] = { ">gv", desc = "indent line" }

-- Improved Terminal Mappings
maps.t["<esc>"] = { "<C-\\><C-n>", desc = "Terminal normal mode" }
maps.t["jk"] = { "<C-\\><C-n>", desc = "Terminal normal mode" }
maps.t["<C-h>"] = { "<c-\\><c-n><c-w>h", desc = "Terminal left window navigation" }
maps.t["<C-j>"] = { "<c-\\><c-n><c-w>j", desc = "Terminal down window navigation" }
maps.t["<C-k>"] = { "<c-\\><c-n><c-w>k", desc = "Terminal up window navigation" }
maps.t["<C-l>"] = { "<c-\\><c-n><c-w>l", desc = "Terminal right window naviation" }

-- Custom menu for extra functionalities
maps.n["<leader>xb"] = { toggle_background, desc = "Toggle background" }
maps.n["<leader>xc"] = { toggle_completion, desc = "Toggle completion" }
maps.n["<leader>xg"] = { toggle_signcolumn, desc = "Toggle signcolumn" }
maps.n["<leader>xn"] = { change_number, desc = "Change line numbering" }
maps.n["<leader>xi"] = { set_indent, desc = "Change indent setting" }
maps.n["<leader>xp"] = { toggle_spell, desc = "Toggle spellcheck" }
maps.n["<leader>xu"] = { function() astronvim.toggle_url_match() end, desc = "Toggle URL Highlights" }
maps.n["<leader>xy"] = { change_syntax, desc = "Toggle syntax highlight" }

astronvim.set_mappings(astronvim.user_plugin_opts("mappings", maps))
