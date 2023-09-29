return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local astro = require "astrocore"
    local get_icon = require("astroui").get_icon
    -- initialize internally use mapping section titles
    opts._map_section = {
      f = { desc = get_icon("Search", 1, true) .. "Find" },
      p = { desc = get_icon("Package", 1, true) .. "Packages" },
      l = { desc = get_icon("ActiveLSP", 1, true) .. "LSP" },
      u = { desc = get_icon("Window", 1, true) .. "UI/UX" },
      b = { desc = get_icon("Tab", 1, true) .. "Buffers" },
      bs = { desc = get_icon("Sort", 1, true) .. "Sort Buffers" },
      d = { desc = get_icon("Debugger", 1, true) .. "Debugger" },
      g = { desc = get_icon("Git", 1, true) .. "Git" },
      S = { desc = get_icon("Session", 1, true) .. "Session" },
      t = { desc = get_icon("Terminal", 1, true) .. "Terminal" },
    }

    -- initialize mappings table
    local maps = astro.empty_map_table()
    local sections = opts._map_section

    -- Normal --
    -- Standard Operations
    maps.n["j"] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Move cursor down" }
    maps.n["k"] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Move cursor up" }
    maps.n["<Leader>w"] = { "<Cmd>w<CR>", desc = "Save" }
    maps.n["<Leader>q"] = { "<Cmd>confirm q<CR>", desc = "Quit" }
    maps.n["<Leader>Q"] = { "<Cmd>confirm qall<CR>", desc = "Quit all" }
    maps.n["<Leader>n"] = { "<Cmd>enew<CR>", desc = "New File" }
    maps.n["<C-s>"] = { "<Cmd>w!<CR>", desc = "Force write" }
    maps.n["<C-q>"] = { "<Cmd>q!<CR>", desc = "Force quit" }
    maps.n["|"] = { "<Cmd>vsplit<CR>", desc = "Vertical Split" }
    maps.n["\\"] = { "<Cmd>split<CR>", desc = "Horizontal Split" }
    -- TODO: remove deprecated method check after dropping support for neovim v0.9
    if not vim.ui.open then
      maps.n["gx"] = { astro.system_open, desc = "Open the file under cursor with system app" }
    end

    -- Plugin Manager
    maps.n["<Leader>p"] = sections.p
    maps.n["<Leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install" }
    maps.n["<Leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status" }
    maps.n["<Leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync" }
    maps.n["<Leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates" }
    maps.n["<Leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update" }
    maps.n["<Leader>pa"] = { function() require("astrocore").update_packages() end, desc = "Update Lazy and Mason" }

    -- Manage Buffers
    maps.n["<Leader>c"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" }
    maps.n["<Leader>C"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" }
    maps.n["]b"] = {
      function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    }
    maps.n["[b"] = {
      function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    }
    maps.n[">b"] = {
      function() require("astrocore.buffer").move(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Move buffer tab right",
    }
    maps.n["<b"] = {
      function() require("astrocore.buffer").move(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Move buffer tab left",
    }

    maps.n["<Leader>b"] = sections.b
    maps.n["<Leader>bc"] =
      { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
    maps.n["<Leader>bC"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
    maps.n["<Leader>bl"] =
      { function() require("astrocore.buffer").close_left() end, desc = "Close all buffers to the left" }
    maps.n["<Leader>bp"] = { function() require("astrocore.buffer").prev() end, desc = "Previous buffer" }
    maps.n["<Leader>br"] =
      { function() require("astrocore.buffer").close_right() end, desc = "Close all buffers to the right" }
    maps.n["<Leader>bs"] = sections.bs
    maps.n["<Leader>bse"] = { function() require("astrocore.buffer").sort "extension" end, desc = "By extension" }
    maps.n["<Leader>bsr"] = { function() require("astrocore.buffer").sort "unique_path" end, desc = "By relative path" }
    maps.n["<Leader>bsp"] = { function() require("astrocore.buffer").sort "full_path" end, desc = "By full path" }
    maps.n["<Leader>bsi"] = { function() require("astrocore.buffer").sort "bufnr" end, desc = "By buffer number" }
    maps.n["<Leader>bsm"] = { function() require("astrocore.buffer").sort "modified" end, desc = "By modification" }

    -- Navigate tabs
    maps.n["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" }
    maps.n["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" }

    -- Split navigation
    maps.n["<C-h>"] = { "<C-w>h", desc = "Move to left split" }
    maps.n["<C-j>"] = { "<C-w>j", desc = "Move to below split" }
    maps.n["<C-k>"] = { "<C-w>k", desc = "Move to above split" }
    maps.n["<C-l>"] = { "<C-w>l", desc = "Move to right split" }
    maps.n["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" }
    maps.n["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" }
    maps.n["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" }
    maps.n["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" }

    -- Stay in indent mode
    maps.v["<S-Tab>"] = { "<gv", desc = "Unindent line" }
    maps.v["<Tab>"] = { ">gv", desc = "Indent line" }

    -- Improved Terminal Navigation
    maps.t["<C-h>"] = { "<Cmd>wincmd h<CR>", desc = "Terminal left window navigation" }
    maps.t["<C-j>"] = { "<Cmd>wincmd j<CR>", desc = "Terminal down window navigation" }
    maps.t["<C-k>"] = { "<Cmd>wincmd k<CR>", desc = "Terminal up window navigation" }
    maps.t["<C-l>"] = { "<Cmd>wincmd l<CR>", desc = "Terminal right window navigation" }

    maps.n["<Leader>u"] = sections.u
    -- Custom menu for modification of the user experience
    maps.n["<Leader>ub"] = { function() require("astrocore.toggles").background() end, desc = "Toggle background" }
    maps.n["<Leader>ug"] = { function() require("astrocore.toggles").signcolumn() end, desc = "Toggle signcolumn" }
    maps.n["<Leader>uh"] = { function() require("astrocore.toggles").foldcolumn() end, desc = "Toggle foldcolumn" }
    maps.n["<Leader>ui"] = { function() require("astrocore.toggles").indent() end, desc = "Change indent setting" }
    maps.n["<Leader>ul"] = { function() require("astrocore.toggles").statusline() end, desc = "Toggle statusline" }
    maps.n["<Leader>un"] = { function() require("astrocore.toggles").number() end, desc = "Change line numbering" }
    maps.n["<Leader>uN"] =
      { function() require("astrocore.toggles").notifications() end, desc = "Toggle Notifications" }
    maps.n["<Leader>up"] = { function() require("astrocore.toggles").paste() end, desc = "Toggle paste mode" }
    maps.n["<Leader>us"] = { function() require("astrocore.toggles").spell() end, desc = "Toggle spellcheck" }
    maps.n["<Leader>uS"] = { function() require("astrocore.toggles").conceal() end, desc = "Toggle conceal" }
    maps.n["<Leader>ut"] = { function() require("astrocore.toggles").tabline() end, desc = "Toggle tabline" }
    maps.n["<Leader>uu"] = { function() require("astrocore.toggles").url_match() end, desc = "Toggle URL highlight" }
    maps.n["<Leader>uw"] = { function() require("astrocore.toggles").wrap() end, desc = "Toggle wrap" }
    maps.n["<Leader>uy"] =
      { function() require("astrocore.toggles").buffer_syntax() end, desc = "Toggle syntax highlight" }

    opts.mappings = maps
  end,
}
