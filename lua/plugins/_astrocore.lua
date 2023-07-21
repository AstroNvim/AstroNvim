return {
  "AstroNvim/astrocore",
  dependencies = { "AstroNvim/astroui" },
  lazy = false,
  priority = 10000,
  opts = function(_, opts)
    local utils = require "astrocore.utils"
    local get_icon = require("astroui").get_icon
    local is_available = utils.is_available
    local ui = require "astronvim.utils.ui"
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
    local maps = utils.empty_map_table()
    local sections = opts._map_section

    -- Normal --
    -- Standard Operations
    maps.n["j"] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Move cursor down" }
    maps.n["k"] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Move cursor up" }
    maps.n["<leader>w"] = { "<cmd>w<cr>", desc = "Save" }
    maps.n["<leader>q"] = { "<cmd>confirm q<cr>", desc = "Quit" }
    maps.n["<leader>n"] = { "<cmd>enew<cr>", desc = "New File" }
    maps.n["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" }
    maps.n["<C-q>"] = { "<cmd>q!<cr>", desc = "Force quit" }
    maps.n["|"] = { "<cmd>vsplit<cr>", desc = "Vertical Split" }
    maps.n["\\"] = { "<cmd>split<cr>", desc = "Horizontal Split" }
    -- TODO: Remove when dropping support for <Neovim v0.10
    if not vim.ui.open then
      maps.n["gx"] = { utils.system_open, desc = "Open the file under cursor with system app" }
    end

    -- Plugin Manager
    maps.n["<leader>p"] = sections.p
    maps.n["<leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install" }
    maps.n["<leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status" }
    maps.n["<leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync" }
    maps.n["<leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates" }
    maps.n["<leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update" }

    -- AstroNvim
    maps.n["<leader>pa"] = { "<cmd>AstroUpdatePackages<cr>", desc = "Update Plugins and Mason Packages" }
    maps.n["<leader>pA"] = { "<cmd>AstroUpdate<cr>", desc = "AstroNvim Update" }
    maps.n["<leader>pv"] = { "<cmd>AstroVersion<cr>", desc = "AstroNvim Version" }
    maps.n["<leader>pl"] = { "<cmd>AstroChangelog<cr>", desc = "AstroNvim Changelog" }

    -- Manage Buffers
    maps.n["<leader>c"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" }
    maps.n["<leader>C"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" }
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

    maps.n["<leader>b"] = sections.b
    maps.n["<leader>bc"] =
      { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
    maps.n["<leader>bC"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
    maps.n["<leader>bb"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
      end,
      desc = "Select buffer from tabline",
    }
    maps.n["<leader>bd"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
      end,
      desc = "Close buffer from tabline",
    }
    maps.n["<leader>bl"] =
      { function() require("astrocore.buffer").close_left() end, desc = "Close all buffers to the left" }
    maps.n["<leader>bp"] = { function() require("astrocore.buffer").prev() end, desc = "Previous buffer" }
    maps.n["<leader>br"] =
      { function() require("astrocore.buffer").close_right() end, desc = "Close all buffers to the right" }
    maps.n["<leader>bs"] = sections.bs
    maps.n["<leader>bse"] = { function() require("astrocore.buffer").sort "extension" end, desc = "By extension" }
    maps.n["<leader>bsr"] = { function() require("astrocore.buffer").sort "unique_path" end, desc = "By relative path" }
    maps.n["<leader>bsp"] = { function() require("astrocore.buffer").sort "full_path" end, desc = "By full path" }
    maps.n["<leader>bsi"] = { function() require("astrocore.buffer").sort "bufnr" end, desc = "By buffer number" }
    maps.n["<leader>bsm"] = { function() require("astrocore.buffer").sort "modified" end, desc = "By modification" }
    maps.n["<leader>b\\"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr)
          vim.cmd.split()
          vim.api.nvim_win_set_buf(0, bufnr)
        end)
      end,
      desc = "Horizontal split buffer from tabline",
    }
    maps.n["<leader>b|"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr)
          vim.cmd.vsplit()
          vim.api.nvim_win_set_buf(0, bufnr)
        end)
      end,
      desc = "Vertical split buffer from tabline",
    }

    -- Navigate tabs
    maps.n["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" }
    maps.n["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" }

    -- Split navigation
    maps.n["<C-h>"] = { "<C-w>h", desc = "Move to left split" }
    maps.n["<C-j>"] = { "<C-w>j", desc = "Move to below split" }
    maps.n["<C-k>"] = { "<C-w>k", desc = "Move to above split" }
    maps.n["<C-l>"] = { "<C-w>l", desc = "Move to right split" }
    maps.n["<C-Up>"] = { "<cmd>resize -2<CR>", desc = "Resize split up" }
    maps.n["<C-Down>"] = { "<cmd>resize +2<CR>", desc = "Resize split down" }
    maps.n["<C-Left>"] = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" }
    maps.n["<C-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" }

    -- Stay in indent mode
    maps.v["<S-Tab>"] = { "<gv", desc = "Unindent line" }
    maps.v["<Tab>"] = { ">gv", desc = "Indent line" }

    -- Improved Terminal Navigation
    maps.t["<C-h>"] = { "<cmd>wincmd h<cr>", desc = "Terminal left window navigation" }
    maps.t["<C-j>"] = { "<cmd>wincmd j<cr>", desc = "Terminal down window navigation" }
    maps.t["<C-k>"] = { "<cmd>wincmd k<cr>", desc = "Terminal up window navigation" }
    maps.t["<C-l>"] = { "<cmd>wincmd l<cr>", desc = "Terminal right window navigation" }

    maps.n["<leader>u"] = sections.u
    -- Custom menu for modification of the user experience
    if is_available "nvim-autopairs" then maps.n["<leader>ua"] = { ui.toggle_autopairs, desc = "Toggle autopairs" } end
    maps.n["<leader>ub"] = { ui.toggle_background, desc = "Toggle background" }
    if is_available "nvim-cmp" then maps.n["<leader>uc"] = { ui.toggle_cmp, desc = "Toggle autocompletion" } end
    if is_available "nvim-colorizer.lua" then
      maps.n["<leader>uC"] = { "<cmd>ColorizerToggle<cr>", desc = "Toggle color highlight" }
    end
    if is_available "astrolsp" then
      maps.n["<leader>ud"] = { function() require("astrolsp.toggles").diagnostics() end, desc = "Toggle diagnostics" }
      maps.n["<leader>uL"] = { function() require("astrolsp.toggles").codelens() end, desc = "Toggle CodeLens" }
    end
    maps.n["<leader>ug"] = { ui.toggle_signcolumn, desc = "Toggle signcolumn" }
    maps.n["<leader>ui"] = { ui.set_indent, desc = "Change indent setting" }
    maps.n["<leader>ul"] = { ui.toggle_statusline, desc = "Toggle statusline" }
    maps.n["<leader>un"] = { ui.change_number, desc = "Change line numbering" }
    maps.n["<leader>uN"] = { ui.toggle_ui_notifications, desc = "Toggle Notifications" }
    maps.n["<leader>up"] = { ui.toggle_paste, desc = "Toggle paste mode" }
    maps.n["<leader>us"] = { ui.toggle_spell, desc = "Toggle spellcheck" }
    maps.n["<leader>uS"] = { ui.toggle_conceal, desc = "Toggle conceal" }
    maps.n["<leader>ut"] = { ui.toggle_tabline, desc = "Toggle tabline" }
    maps.n["<leader>uu"] = { ui.toggle_url_match, desc = "Toggle URL highlight" }
    maps.n["<leader>uw"] = { ui.toggle_wrap, desc = "Toggle wrap" }
    maps.n["<leader>uy"] = { ui.toggle_syntax, desc = "Toggle syntax highlight" }
    maps.n["<leader>uh"] = { ui.toggle_foldcolumn, desc = "Toggle foldcolumn" }

    opts.mappings = maps
  end,
}
