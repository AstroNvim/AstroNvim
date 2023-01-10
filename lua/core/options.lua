vim.opt.shortmess:append { s = true, I = true } -- disable startup message
if vim.fn.has "nvim-0.9" == 1 then -- TODO v3 REMOVE THIS CONDITIONAL
  vim.opt.diffopt:append "linematch:60" -- enable linematch diff algorithm
end
astronvim.vim_opts(astronvim.user_opts("options", {
  opt = {
    backspace = vim.opt.backspace + { "nostop" }, -- Don't stop backspace at insert
    clipboard = "unnamedplus", -- Connection to the system clipboard
    cmdheight = 0, -- hide command line unless needed
    completeopt = { "menuone", "noselect" }, -- Options for insert mode completion
    copyindent = true, -- Copy the previous indentation on autoindenting
    cursorline = true, -- Highlight the text line of the cursor
    expandtab = true, -- Enable the use of space in tab
    fileencoding = "utf-8", -- File content encoding for the buffer
    fillchars = { eob = " " }, -- Disable `~` on nonexistent lines
    history = 100, -- Number of commands to remember in a history table
    ignorecase = true, -- Case insensitive searching
    laststatus = 3, -- globalstatus
    mouse = "a", -- Enable mouse support
    number = true, -- Show numberline
    preserveindent = true, -- Preserve indent structure as much as possible
    pumheight = 10, -- Height of the pop up menu
    relativenumber = true, -- Show relative numberline
    scrolloff = 8, -- Number of lines to keep above and below the cursor
    shiftwidth = 2, -- Number of space inserted for indentation
    showmode = false, -- Disable showing modes in command line
    showtabline = 2, -- always display tabline
    sidescrolloff = 8, -- Number of columns to keep at the sides of the cursor
    signcolumn = "yes", -- Always show the sign column
    smartcase = true, -- Case sensitivie searching
    splitbelow = true, -- Splitting a new window below the current one
    -- TODO v3 REMOVE THIS CONDITIONAL
    splitkeep = vim.fn.has "nvim-0.9" == 1 and "screen" or nil, -- Maintain code view when splitting
    splitright = true, -- Splitting a new window at the right of the current one
    tabstop = 2, -- Number of space in a tab
    termguicolors = true, -- Enable 24-bit RGB color in the TUI
    timeoutlen = 300, -- Length of time to wait for a mapped sequence
    undofile = true, -- Enable persistent undo
    updatetime = 300, -- Length of time to wait before triggering the plugin
    wrap = false, -- Disable wrapping of lines longer than the width of window
    writebackup = false, -- Disable making a backup before overwriting a file
  },
  g = {
    highlighturl_enabled = true, -- highlight URLs by default
    mapleader = " ", -- set leader key
    autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    lsp_handlers_enabled = true, -- enable or disable default vim.lsp.handlers (hover and signatureHelp)
    cmp_enabled = true, -- enable completion at start
    autopairs_enabled = true, -- enable autopairs at start
    diagnostics_enabled = true, -- enable diagnostics at start
    status_diagnostics_enabled = true, -- enable diagnostics in statusline
    icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
  },
  t = {
    bufs = vim.tbl_filter(astronvim.is_valid_buffer, vim.api.nvim_list_bufs()), -- buffers in tab
  },
}))
