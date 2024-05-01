return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local opt = {}
    opt.backspace = vim.list_extend(vim.opt.backspace:get(), { "nostop" }) -- don't stop backspace at insert
    opt.breakindent = true -- wrap indent to match  line start
    opt.clipboard = "unnamedplus" -- connection to the system clipboard
    opt.cmdheight = 0 -- hide command line unless needed
    opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion
    opt.confirm = true -- raise a dialog asking if you wish to save the current file(s)
    opt.copyindent = true -- copy the previous indentation on autoindenting
    opt.cursorline = true -- highlight the text line of the cursor
    opt.diffopt = vim.list_extend(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" }) -- enable linematch diff algorithm
    opt.expandtab = true -- enable the use of space in tab
    opt.fileencoding = "utf-8" -- file content encoding for the buffer
    opt.fillchars = { eob = " " } -- disable `~` on nonexistent lines
    opt.foldcolumn = "1" -- show foldcolumn
    opt.foldenable = true -- enable fold for nvim-ufo
    opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
    opt.foldlevelstart = 99 -- start with all code unfolded
    opt.history = 100 -- number of commands to remember in a history table
    opt.ignorecase = true -- case insensitive searching
    opt.infercase = true -- infer cases in keyword completion
    opt.laststatus = 3 -- global statusline
    opt.linebreak = true -- wrap lines at 'breakat'
    opt.mouse = "a" -- enable mouse support
    opt.number = true -- show numberline
    opt.preserveindent = true -- preserve indent structure as much as possible
    opt.pumheight = 10 -- height of the pop up menu
    opt.relativenumber = true -- show relative numberline
    opt.shiftwidth = 2 -- number of space inserted for indentation
    opt.shortmess = vim.tbl_deep_extend("force", vim.opt.shortmess:get(), { s = true, I = true }) -- disable search count wrap and startup messages
    opt.showmode = false -- disable showing modes in command line
    opt.showtabline = 2 -- always display tabline
    opt.signcolumn = "yes" -- always show the sign column
    opt.smartcase = true -- case sensitive searching
    opt.splitbelow = true -- splitting a new window below the current one
    opt.splitright = true -- splitting a new window at the right of the current one
    opt.tabstop = 2 -- number of space in a tab
    opt.termguicolors = true -- enable 24-bit RGB color in the TUI
    opt.timeoutlen = 500 -- shorten key timeout length a little bit for which-key
    opt.title = true -- set terminal title to the filename and path
    opt.undofile = true -- enable persistent undo
    opt.updatetime = 300 -- length of time to wait before triggering the plugin
    opt.viewoptions = vim.tbl_filter(function(val) return val ~= "curdir" end, vim.opt.viewoptions:get())
    opt.virtualedit = "block" -- allow going past end of line in visual block mode
    opt.wrap = false -- disable wrapping of lines longer than the width of window
    opt.writebackup = false -- disable making a backup before overwriting a file

    local g = {}
    g.markdown_recommended_style = 0

    if not vim.t.bufs then vim.t.bufs = vim.api.nvim_list_bufs() end -- initialize buffer list
    opts.options = { opt = opt, g = g, t = { bufs = vim.t.bufs } }
  end,
}
