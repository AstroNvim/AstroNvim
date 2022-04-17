local M = {}

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

M.unmapKeys = function ()
  keymap("", "<leader>c", "<Nop>", opts)
  keymap("", "<leader>w", "<Nop>", opts)
  keymap("", "<leader>w", "<Nop>", opts)
  keymap("", "<leader>q", "<Nop>", opts)
  keymap("", "q", "<Nop>", opts)
  keymap("", "<c-s>", "<Nop>", opts)
  keymap("n", "gx", "<Nop>", opts)
  keymap("n", "<F6>", "<Nop>", opts)
  keymap('', '<', '<Nop>', opts)
  keymap('', '>', '<Nop>', opts)
end

------------------------------------------------------------------
-- General Keys
------------------------------------------------------------------

M.generalVimKeys = function()

  -- TODO: map Q to recording
  keymap("n", "<C-u>", ":undo<cr>", {})
  keymap("", "<C-s>", ":w!<cr>", {})
  keymap("n", "q", "<cmd>quit<cr>", {})
  keymap("", "<C-q>", ":bd<cr>", {})

  keymap("n", "Q", "q", opts)
  keymap("n", "gQ", "@q", opts)

  keymap('', '<c-PageUp>', "<Cmd>BufferLineCyclePrev<CR>", opts)
  keymap('', '<c-PageDown>', "<Cmd>BufferLineCycleNext<CR>", opts)
  -- vim.api.nvim_set_keymap('', '<A-j>', "<Cmd>bp<CR>", {})
  -- vim.api.nvim_set_keymap('', '<A-k>', "<Cmd>bn<CR>", {})

  -- toggle highlights (switch higlight no matter the previous state)
  keymap("n", "<leader>h", "<cmd>set hls!<cr>", {})
  vim.api.nvim_set_keymap('n', '/',':set hlsearch<cr>/',  {noremap = true})
  vim.api.nvim_set_keymap("n", "<Esc>", [[&hls && v:hlsearch ? ":nohls<CR>" : "<Esc>"]], {noremap=true, silent=true, expr=true})
  -- keymap("n", "<Esc>", ":noh <CR>", {noremap=true, silent=true})

  -- Include Time Stamps
  keymap("n" ,"<F4>", '=strftime("%Y-%m-%d")<CR>P', opts)
  keymap("i", "<F4>", '<C-R>=strftime("%Y-%m-%d")<CR>', opts)
  keymap("n" ,"<leader><F4>", '=strftime("%H:%M")<CR>P', opts)
  -- vim.api.nvim_set_keymap('', '<F4>', ':lua vim.api.nvim_buf_set_lines(0, vim.api.nvim_win_get_cursor(win)[1], vim.api.nvim_win_get_cursor(win)[1], false, {os.date("%Y-%m-%d")})<cr>', { })

  vim.cmd([[
    cnoremap <expr> <Up>  pumvisible() ? "\<C-p>" : "\<Up>"
    cnoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
  ]])

  -- TODO: potentially as the current behaviour has its own advantages
  -- vim.api.nvim_set_keymap("", "\\<Up>", "require('cmp').mapping.select_prev_item()", { expr = true, noremap = true })
  -- vim.api.nvim_set_keymap("", "\\<Down>", "require('cmp').mapping.select_next_item()", { expr = true, noremap = true })
  -- lvim.keys.normal_mode["wg"]  = '<cmd>call utils#toggle_background()<CR>'


  -- spelling and dictionary suggestions ---
  vim.cmd([[
    noremap [z [sz=
    noremap ]z ]sz=
  ]])

  -- ======================================================================================================
  -- -- OPEN file, url, or directory

  commandsOpen = {unix="xdg-open", mac="open"}
  if vim.fn.has "mac" == 1 then osKey = "mac" elseif vim.fn.has "unix" == 1 then osKey = "unix" end
  local openDir = [[<cmd>lua os.execute(commandsOpen[osKey] .. ' ' .. vim.fn.shellescape(vim.fn.fnamemodify(vim.fn.expand('<sfile>'), ':p'))); vim.cmd "redraw!"<cr>]]
  --
  -- local openAll = [[<cmd>lua cword = vim.fn.expand("<cWORD>"); if string.len(cword) ~= 0 then arg = vim.fn.shellescape(cword); else arg = vim.fn.shellescape(vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":p")) end; print(arg); os.execute(commandsOpen[osKey] .. ' ' .. arg); vim.cmd "redraw!"<cr>]]
  -- local openFileUrl = [[<cmd>lua os.execute(commandsOpen[osKey] .. " " .. vim.fn.shellescape(vim.fn.expand("<cWORD>"))); vim.cmd "redraw!"<cr>]]

  keymap("n", "<F6>", openDir, {})
  -- keymap("n", "gx", [[<cmd> lua Open()<CR>]], {})
  keymap("n", "gx", [[<cmd> lua require("user.utils").openExtApp()<CR>]], {})

  -- keymap("n", "gx", openAll, {})
  -- lvim.keys.normal_mode["gx"] = openFileUrl
  -- ======================================================================================================

  keymap('x', '<', '<gv', opts)
  keymap('x', '>', '>gv|', opts)
  keymap('x', '<S-Tab>', '<gv', opts)
  keymap('x', '<Tab>', '>gv|', opts)
  keymap('n', '<', '<<_', opts)
  keymap('n', '>', '>>_', opts)

  -- EXAMPLES:
  -- v  <Space>/    * <Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>
  -- lvim.keys.normal_mode["gcc"] = "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op()<CR>"
  -- lvim.keys.visual_mode["gcc"] = "* <Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>"
  -- nnoremap <Leader>cw
  -- vim.api.nvim_set_keymap('n', '<c-c>', "<cmd>BufferClose!<CR>", {})
end



M.comment = function()
  -- keymap("n", "<c-§>", "<cmd>lua require('Comment.api').toggle_current_linewise()<cr>", opts)
  -- keymap("v", "<c-§>", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opts)
  -- keymap("i", "<c-§>", '<cmd> * v:count == 0 ? <Cmd>lua require("Comment.api").call("toggle_current_linewise_op")<CR>g@$ : <Cmd>lua require("Comment.api").call("toggle_linewise_count_op")<CR>g@$', opts)
  -- keymap("x", "<c-§>", '<cmd> * <Esc><Cmd>lua require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())<CR>', opts)

  -- ctrl does not seem to work
  keymap("n", [[<C-§>]], [[v:count == 0 ? '<CMD>lua require("Comment.api").call("toggle_current_linewise_op")<CR>g@$' : '<CMD>lua require("Comment.api").call("toggle_linewise_count_op")<CR>g@$']], { noremap = true, silent = true, expr = true })

end

------------------------------------------------------------------
-- Telescope
------------------------------------------------------------------

M.floating_win = function()
  vim.api.nvim_set_keymap('', '<M-7>', '<Cmd>execute v:count . "ToggleTerm"<CR>', {noremap=false})
  vim.api.nvim_set_keymap('', '<M-/>', '<Cmd>execute v:count . "ToggleTerm"<CR>', {noremap=false})
  vim.api.nvim_set_keymap('', '<F2>', '<Cmd>execute v:count . "ToggleTerm"<CR>', {noremap=false})

  -- close telescope and toggleterm with q
  vim.cmd([[
    au! Filetype TelescopePrompt nmap q <esc>'
    au! Filetype toggleterm nmap q <esc>'
    ]]
  )
end

------------------------------------------------------------------
-- bullets.vim
------------------------------------------------------------------

-- M.bulletsVim = function()
--   -- mappings:
--   lvim.keys.normal_mode["<C-Space>"] = false
--   lvim.keys.normal_mode["<C-Space>"] = "<cmd>ToggleCheckbox<CR>"
--
--     -- " automatic bullets
--     -- call s:add_local_mapping('inoremap', '<cr>', '<C-]><C-R>=<SID>insert_new_bullet()<cr>')
--     -- call s:add_local_mapping('inoremap', '<C-cr>', '<cr>')
--
--     -- call s:add_local_mapping('nnoremap', 'o', ':call <SID>insert_new_bullet()<cr>')
--
--     -- " Renumber bullet list
--     -- call s:add_local_mapping('vnoremap', 'gN', ':RenumberSelection<cr>')
--     -- call s:add_local_mapping('nnoremap', 'gN', ':RenumberList<cr>')
--
--     -- " Toggle checkbox
--     -- call s:add_local_mapping('nnoremap', '<leader>x', ':ToggleCheckbox<cr>')
--
--     -- " Promote and Demote outline level
--     -- call s:add_local_mapping('inoremap', '<C-t>', '<C-o>:BulletDemote<cr>')
--     -- call s:add_local_mapping('nnoremap', '>>', ':BulletDemote<cr>')
--     -- call s:add_local_mapping('inoremap', '<C-d>', '<C-o>:BulletPromote<cr>')
--     -- call s:add_local_mapping('nnoremap', '<<', ':BulletPromote<cr>')
--     -- call s:add_local_mapping('vnoremap', '>', ':BulletDemoteVisual<cr>')
--     -- call s:add_local_mapping('vnoremap', '<', ':BulletPromoteVisual<cr>')
-- end

------------------------------------------------------------------
-- Hop
------------------------------------------------------------------

M.hop = function()

  lvim.keys.normal_mode["h"] = false
  lvim.keys.normal_mode["H"] = false

  lvim.keys.normal_mode["h"] = ":HopChar2<cr>"
  lvim.keys.normal_mode["H"] = ":HopWord<cr>"

  -- vim.api.nvim_del_keymap("n", 'H')
  -- vim.api.nvim_del_keymap("n", 'h')
  -- local opts = { noremap = true, silent = true }
  -- vim.api.nvim_set_keymap("n", "h", ":HopChar2<cr>", opts)
  -- vim.api.nvim_set_keymap("n", "H", ":HopWord<cr>", opts)

end

return M
