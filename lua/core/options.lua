local M = {}

local options = {
  fileencoding = "utf-8",                      -- File content encoding for the buffer
  spelllang = "en",                            -- Support US english
  clipboard = "unnamedplus",                   -- Connection to the system clipboard
  mouse = "a",                                 -- Enable mouse support
  signcolumn = "yes",                          -- Always show the sign column
  foldmethod = "manual",                       -- Create folds manually
  completeopt = { "menuone", "noselect" },     -- Options for insert mode completion
  colorcolumn = "99999",                       -- Fix for the indentline problem
  backup = false,                              -- Disable making a backup file
  expandtab = true,                            -- Enable the use of space in tab
  hidden = true,                               -- Ignore unsaved buffers
  hlsearch = true,                             -- Highlight all the matches of search pattern
  ignorecase = true,                           -- Case insensitive searching
  smartcase = true,                            -- Case sensitivie searching
  spell = false,                               -- Disable spelling checking and highlighting
  showmode = false,                            -- Disable showing modes in command line
  smartindent = true,                          -- Do auto indenting when starting a new line
  splitbelow = true,                           -- Splitting a new window below the current one
  splitright = true,                           -- Splitting a new window at the right of the current one
  swapfile = false,                            -- Disable use of swapfile for the buffer
  termguicolors = true,                        -- Enable 24-bit RGB color in the TUI
  undofile = true,                             -- Enable persistent undo
  writebackup = false,                         -- Disable making a backup before overwriting a file
  cursorline = true,                           -- Highlight the text line of the cursor
  number = true,                               -- Show numberline
  relativenumber = true,                       -- Show relative numberline
  wrap = false,                                -- Disable wrapping of lines longer than the width of window
  conceallevel = 0,                            -- Show text normally
  cmdheight = 1,                               -- Number of screen lines to use for the command line
  shiftwidth = 2,                              -- Number of space inserted for indentation
  tabstop = 2,                                 -- Number of space in a tab
  scrolloff = 8,                               -- Number of lines to keep above and below the cursor
  sidescrolloff = 8,                           -- Number of columns to keep at the sides of the cursor
  pumheight = 10,                              -- Height of the pop up menu
  history = 100,                               -- Number of commands to remember in a history table
  timeoutlen = 300,                            -- Length of time to wait for a mapped sequence
  updatetime = 300,                            -- Length of time to wait before triggering the plugin
}

for key, value in pairs(options) do
  vim.opt[key] = value
end

return M
