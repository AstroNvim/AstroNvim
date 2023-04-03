vim.opt.viewoptions:remove "curdir"             -- disable saving current directory with views
vim.opt.shortmess:append { s = true, I = true } -- disable startup message
vim.opt.backspace:append { "nostop" }           -- Don't stop backspace at insert
if vim.fn.has "nvim-0.9" == 1 then
  vim.opt.diffopt:append "linematch:60"         -- enable linematch diff algorithm
end
local options = astronvim.user_opts("options", {
  opt = {
    breakindent = true,                                         -- Wrap indent to match  line start
    clipboard = "unnamedplus",                                  -- Connection to the system clipboard
    cmdheight = 0,                                              -- hide command line unless needed
    completeopt = { "menuone", "noselect" },                    -- Options for insert mode completion
    copyindent = true,                                          -- Copy the previous indentation on autoindenting
    cursorline = true,                                          -- Highlight the text line of the cursor
    expandtab = true,                                           -- Enable the use of space in tab
    fileencoding = "utf-8",                                     -- File content encoding for the buffer
    fillchars = { eob = " " },                                  -- Disable `~` on nonexistent lines
    foldenable = true,                                          -- enable fold for nvim-ufo
    foldlevel = 99,                                             -- set high foldlevel for nvim-ufo
    foldlevelstart = 99,                                        -- start with all code unfolded
    foldcolumn = vim.fn.has "nvim-0.9" == 1 and "1" or nil,     -- show foldcolumn in nvim 0.9
    history = 100,                                              -- Number of commands to remember in a history table
    ignorecase = true,                                          -- Case insensitive searching
    infercase = true,                                           -- Infer cases in keyword completion
    laststatus = 3,                                             -- globalstatus
    linebreak = true,                                           -- Wrap lines at 'breakat'
    mouse = "a",                                                -- Enable mouse support
    number = true,                                              -- Show numberline
    preserveindent = true,                                      -- Preserve indent structure as much as possible
    pumheight = 10,                                             -- Height of the pop up menu
    relativenumber = true,                                      -- Show relative numberline
    scrolloff = 8,                                              -- Number of lines to keep above and below the cursor
    shiftwidth = 2,                                             -- Number of space inserted for indentation
    showmode = false,                                           -- Disable showing modes in command line
    showtabline = 2,                                            -- always display tabline
    sidescrolloff = 8,                                          -- Number of columns to keep at the sides of the cursor
    signcolumn = "yes",                                         -- Always show the sign column
    smartcase = true,                                           -- Case sensitivie searching
    smartindent = true,                                         -- Smarter autoindentation
    splitbelow = true,                                          -- Splitting a new window below the current one
    splitkeep = vim.fn.has "nvim-0.9" == 1 and "screen" or nil, -- Maintain code view when splitting
    splitright = true,                                          -- Splitting a new window at the right of the current one
    tabstop = 2,                                                -- Number of space in a tab
    termguicolors = true,                                       -- Enable 24-bit RGB color in the TUI
    timeoutlen = 500,                                           -- Shorten key timeout length a little bit for which-key
    undofile = true,                                            -- Enable persistent undo
    updatetime = 300,                                           -- Length of time to wait before triggering the plugin
    virtualedit = "block",                                      -- allow going past end of line in visual block mode
    wrap = false,                                               -- Disable wrapping of lines longer than the width of window
    writebackup = false,                                        -- Disable making a backup before overwriting a file
  },
  g = {
    highlighturl_enabled = true,           -- highlight URLs by default
    mapleader = " ",                       -- set leader key
    autoformat_enabled = true,             -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    codelens_enabled = true,               -- enable or disable automatic codelens refreshing for lsp that support it
    lsp_handlers_enabled = true,           -- enable or disable default vim.lsp.handlers (hover and signatureHelp)
    cmp_enabled = true,                    -- enable completion at start
    autopairs_enabled = true,              -- enable autopairs at start
    diagnostics_mode = 3,                  -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
    icons_enabled = true,                  -- disable icons in the UI (disable if no nerd font is available)
    ui_notifications_enabled = true,       -- disable notifications when toggling UI elements
  },
  t = { bufs = vim.api.nvim_list_bufs() }, -- initialize buffers for the current tab
})

for scope, table in pairs(options) do
  for setting, value in pairs(table) do
    vim[scope][setting] = value
  end
end
