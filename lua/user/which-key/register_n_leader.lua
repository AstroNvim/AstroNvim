
local keybindings = {

  ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
  ["sg"] = {'<cmd>Telescope live_grep<CR>', "Live grep"},
  ["w"] = {},

-- -------------------------------------------------------
-- -- LSP --
-- -------------------------------------------------------
--
-- -- lvim.builtin.which_key.mappings['gd'] = {"<cmd>diffview: diff HEAD" }
--
-- -- Telescope Lsp
-- lvim.builtin.which_key.mappings['lA'] = {'<cmd>Telescope lsp_range_code_actions<CR>', "Lsp range code actions"}
-- lvim.builtin.which_key.mappings['lD'] = {'<cmd>Telescope lsp_definitions<CR>', "Lsp definitions"}
-- lvim.builtin.which_key.mappings['lI'] = {'<cmd>Telescope lsp_implementations<CR>', "Lsp implementations"}
-- lvim.builtin.which_key.mappings['lz'] = {'<cmd>Telescope lsp_references<CR>', "Lsp references"}
-- lvim.builtin.which_key.mappings['lR'] = {'<cmd>Telescope lsp_references<CR>', "Lsp references"}
-- -- a = {'<cmd>Telescope lsp_code_actions<CR>', "Lsp code actions"},
--
-- -- Other Lsp
-- lvim.builtin.which_key.mappings['lv'] = {"<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Definition vsplit"}
--
--
-- -------------------------------------------------------
-- -- GIT --
-- -------------------------------------------------------
--
-- -- Neogit --
-- lvim.builtin.which_key.mappings["gm"] = {"<cmd>Neogit<CR>", "Magit" }  -- noremap=true
-- lvim.builtin.which_key.mappings["gy"] = {"<cmd>lua require('lvim.core.terminal')._exec_toggle({cmd = 'lazygit', count = 1, direction = 'float'})<CR>", 'Lazygit'}
-- lvim.builtin.which_key.mappings["gg"] = {"<cmd>lua require('lvim.core.terminal')._exec_toggle({cmd = 'lazygit', count = 1, direction = 'float'})<CR>", 'Lazygit'}
--
--
-- --------------------------------------------------
-- -- Trouble --
-- -------------------------------------------------------
--
-- lvim.builtin.which_key.mappings["T"] = {
--   name = "Diagnostics",
--   t = { "<cmd>TroubleToggle<cr>", "Trouble" },
--   w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "Workspace" },
--   d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "Document" },
--   q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix" },
--   l = { "<cmd>TroubleToggle loclist<cr>", "Location list" },
--   r = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
--   -- definition
--   -- ....
-- }
--
--
-- -------------------------------------------------------
-- -- Telekasten --
-- -------------------------------------------------------
--
--   lvim.builtin.which_key.mappings["z"] = {
--     name = "Telekasten",
--     b = { "<cmd>lua require('telekasten').show_backlinks()<CR>", "Show backlinks" },
--     c = { "<cmd>lua require('telekasten').show_calendar()<CR>", "Show calendar" },
--     C = { "<cmd>CalendarT<CR>", "Calendar" },
--     d = { "<cmd>lua require('telekasten').find_daily_notes()<CR>", "Find daily notes" },
--     f = { "<cmd>lua require('telekasten').find_notes()<CR>", "Find notes" },
--     F = { "<cmd>lua require('telekasten').find_friends()<CR>", "Find friends" },
--     g = { "<cmd>lua require('telekasten').search_notes()<CR>", "Search notes" },
--     i = { "<cmd>lua require('telekasten').paste_img_and_link()<CR>", "Paste img link" },
--     I = { "<cmd>lua require('telekasten').insert_img_link({ i=true })<CR>", "Insert image link" },
--     k = { "<cmd>Telekasten<CR>", "Telekasten" },
--     l = { "<cmd>lua require('telekasten').insert_link({ i=true })<CR>", "Insert link"},
--     ["["] = { "<cmd>lua require('telekasten').insert_link({ i=true })<CR>", "Insert link"},
--     m = { "<cmd>lua require('telekasten').browse_media()<CR>", "Browse media" },
--     n = { "<cmd>lua require('telekasten').new_note()<CR>", "New note" },
--     N = { "<cmd>lua require('telekasten').new_templated_note()<CR>", "New template note" },
--     p = { "<cmd>lua require('telekasten').preview_img()<CR>", "Preview img" },
--     t = { "<cmd>lua require('telekasten').toggle_todo()<CR>", "Toggle todo" },
--     T = { "<cmd>lua require('telekasten').goto_today()<CR>", "Goto today" },
--     w = { "<cmd>lua require('telekasten').find_weekly_notes()<CR>", "Find weekly notes" },
--     W = { "<cmd>lua require('telekasten').goto_thisweek()<CR>", "Goto this week" },
--     y = { "<cmd>lua require('telekasten').yank_notelink()<CR>", "Yank note link" },
--     z = { "<cmd>lua require('telekasten').follow_link()<CR>", "Follow lin" },
--     ["#"] = { "<cmd>lua require('telekasten').show_tags()<CR>", "Show tags" },
--   }


}

return keybindings
