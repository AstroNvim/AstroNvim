

local optsNormLocLeader = {mode = 'n', prefix = "<localleader>"}
local optsNormNoPrefix = {mode = "n", prefix = ""}
local optsXmodeLocLeader = {mode = "x", prefix = "<localleader>"}
local optsNmodeSemiCol = {mode = "n", prefix = ";"}

local leaderNormal = {
    m = { 
      w = {"<cmd>keeppatterns %substitute/\\s\\+$//e<CR>", "Clear postspace"},
    -- lvim.builtin.which_key.mappings["c"] = {name = "Utils", w = {"<cmd>keeppatterns %substitute/\\s\\+$//e<CR>", "Whitespce remove"} }
    }
}

local mapsNormNoPrefix = {
  m = {
    name = "Window", -- optional group name
    g = { '<cmd>call utils#toggle_background()<CR>', "Toggle background color" }, -- create a binding with label
    b = { '<cmd>buffer#<CR>', "Buffer alternate"},
    o = { '<cmd>only<CR>', "Only this"},
    c = { '<cmd>close<CR>', "Close"},
    d = { '<cmd>bdelete<CR>', "Buffer delete"},
    q = { '<cmd>quit<CR>', "Quit"},
    x = { '<cmd>call utils#window_empty_buffer()<CR>', "Buffer empty"},
    z = { '<cmd>call utils#zoom()<CR>', "Zoom"},

    -- h = { '<cmd>split<CR>', "Split horizontal"},
    -- v = { '<cmd>vsplit<CR>', "Split vertical"},
    --Split current buffer, go to previous window and previous buffer
    h = { '<cmd>split<CR>:wincmd p<CR>:e#<CR>', "Split horizontal"},
    v = { '<cmd>vsplit<CR>:wincmd p<CR>:e#<CR>', "Split vertical"},
    t = { '<cmd>tabnew<CR>', "Tab new"},
    n = { '<cmd>tabnext<CR>', "Tab next"},
    p = { '<cmd>tabprev<CR>', "Tab previous"},

    f = { '<cmd>lcd %:p:h<CR>'},
  },

   -- Telescope LSP related
  l = {
    name = "Lsp",
    d = {'<cmd>Telescope lsp_definitions<CR>', "Lsp definitions"},
    i = {'<cmd>Telescope lsp_implementations<CR>', "Lsp implementations"},
    r = {'<cmd>Telescope lsp_references<CR>', "Lsp references"},
    a = {'<cmd>Telescope lsp_code_actions<CR>', "Lsp code actions"},
    c = {'<cmd>Telescope lsp_range_code_actions<CR>', "Lsp range code actions"},
    v = {"<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Definition vsplit"},
  },
}

local mapsNormLocLeader = {

    -- Telescope general pickers
    a = { "<Cmd>NvimTreeToggle<CR>", "Nvimtree toggle"},  -- Nvimtree
    b = {'<cmd>Telescope buffers<CR>', "Buffers"},
    c = { '<cmd>Telescope command_history<CR>', "Command history"},
    d = { '<cmd>lua require"config.plugins.telescope".pickers.plugin_directories()<CR>', "Directories"},
    e = { "<Cmd>NvimTreeToggle<CR>", "Nvimtree toggle"},  -- Nvimtree
    f = {'<cmd>Telescope find_files<CR>', "Files"},
    g = {'<cmd>Telescope live_grep<CR>', "Live grep"},
    -- TODO: not working
    G = {"<cmd>lua require('plugins.telescope').pickers.grep_string_cursor()<cr>", "Grep cursor word"},
    h = {'<cmd>Telescope highlights<CR>', "Highlights"},
    H = {'<cmd>Telescope search_history<CR>', "Search history"},
    j = {'<cmd>Telescope jumplist<CR>', "Jumplist"},
    m = {'<cmd>Telescope marks<CR>', "Marks"},
    n = { "<cmd>lua require('telescope').extensions.notify.notify()<cr>", 'Notifications' },  -- require("telescope").load_extension("notify")
    N = { '<cmd>lua require"config.plugins.telescope".pickers.notebook()<CR>', "Notebook"},
    p = {'<cmd>Telescope projects<CR>', "Projects"},
    o = {'<cmd>Telescope vim_options<CR>', "Vim options"},
    r = {'<cmd>Telescope resume<CR>', "Resume last"},
    R = {'<cmd>Telescope pickers<CR>', "Pickers"},
    S = {'<cmd>Telescope session-lens search_session<CR>', "Search session"},
    s = {"<cmd>Telescope current_buffer_fuzzy_find<CR>", "Search current Buffer" },
    ["/"] = { '<cmd>Telescope current_buffer_fuzzy_find<CR>', "Search current buffer"},
    t = {'<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', "LSP workspace symbols"},
    u = {'<cmd>Telescope spell_suggest<CR>', "Spell suggestions"},
    v = {'<cmd>Telescope registers<CR>', "Registers"},
    x = {'<cmd>Telescope oldfiles<CR>', "Files old"},
    z = {'<cmd>Zoxide<CR>', "Zoxide"},
}


local mapsXmodeLocLeader = {

  -- Telescope
  g = {'<cmd>lua require"config.plugins.telescope".pickers.grep_string_visual()<cr>', "Grep selection"},
  G = {'<cmd>lua require"config.plugins.telescope".pickers.grep_string_visual()<cr>', "Grep selection"},
}

local mapsNmodeSemicol = {

  -- Spectre
  h = { "<cmd>HopChar2<cr>", "HopChar2" },
  H = { "<cmd>HopWord<cr>", "HopWord" },

}

-------------------------------------------------------
-- Register which-keys --
-------------------------------------------------------

local whkOn, whk = pcall(require, "which-key")
if not whkOn then
  print("Warning: lua/config/which-keys not loaded")

  require("config.no_which-key").viewKeys()
  require("config.no_which-key").telescope()
  require("config.no_which-key").nerdtree()
  -- TODO: define non-which keys for Hop

else
  whk.register(leaderNormal, {mode = "n", prefix = "leader"})
  whk.register(mapsNormNoPrefix, optsNormNoPrefix)
  whk.register(mapsNormLocLeader, optsNormLocLeader)
  whk.register(mapsXmodeLocLeader, optsXmodeLocLeader)
  whk.register(mapsNmodeSemicol, optsNmodeSemiCol)
end

