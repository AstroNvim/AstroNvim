return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    commands = {
      AstroReload = { function() require("astrocore").reload() end, desc = "Reload AstroNvim (Experimental)" },
      AstroUpdate = { function() require("astrocore").update_packages() end, desc = "Update Lazy and Mason" },
    },
    autocmds = {
      auto_quit = {
        {
          event = "BufEnter",
          desc = "Quit AstroNvim if more than one window is open and only sidebar windows are list",
          callback = function()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            -- Both neo-tree and aerial will auto-quit if there is only a single window left
            if #wins <= 1 then return end
            local sidebar_fts = { aerial = true, ["neo-tree"] = true }
            for _, winid in ipairs(wins) do
              if vim.api.nvim_win_is_valid(winid) then
                local bufnr = vim.api.nvim_win_get_buf(winid)
                local filetype = vim.bo[bufnr].filetype
                -- If any visible windows are not sidebars, early return
                if not sidebar_fts[filetype] then
                  return
                -- If the visible window is a sidebar
                else
                  -- only count filetypes once, so remove a found sidebar from the detection
                  sidebar_fts[filetype] = nil
                end
              end
            end
            if #vim.api.nvim_list_tabpages() > 1 then
              vim.cmd.tabclose()
            else
              vim.cmd.qall()
            end
          end,
        },
      },
      autoview = {
        {
          event = { "BufWinLeave", "BufWritePost", "WinLeave" },
          desc = "Save view with mkview for real files",
          callback = function(event)
            if vim.b[event.buf].view_activated then vim.cmd.mkview { mods = { emsg_silent = true } } end
          end,
        },
        {
          event = "BufWinEnter",
          desc = "Try to load file view if available and enable view saving for real files",
          callback = function(event)
            if not vim.b[event.buf].view_activated then
              local filetype = vim.bo[event.buf].filetype
              local buftype = vim.bo[event.buf].buftype
              local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
              if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
                vim.b[event.buf].view_activated = true
                vim.cmd.loadview { mods = { emsg_silent = true } }
              end
            end
          end,
        },
      },
      bufferline = {
        {
          event = { "BufAdd", "BufEnter", "TabNewEntered" },
          desc = "Update buffers when adding new buffers",
          callback = function(args)
            local buf_utils = require "astrocore.buffer"
            if not vim.t.bufs then vim.t.bufs = {} end
            if not buf_utils.is_valid(args.buf) then return end
            if args.buf ~= buf_utils.current_buf then
              buf_utils.last_buf = buf_utils.is_valid(buf_utils.current_buf) and buf_utils.current_buf or nil
              buf_utils.current_buf = args.buf
            end
            local bufs = vim.t.bufs
            if not vim.tbl_contains(bufs, args.buf) then
              table.insert(bufs, args.buf)
              vim.t.bufs = bufs
            end
            vim.t.bufs = vim.tbl_filter(buf_utils.is_valid, vim.t.bufs)
            require("astrocore").event "BufsUpdated"
          end,
        },
        {
          event = { "BufDelete", "TermClose" },
          desc = "Update buffers when deleting buffers",
          callback = function(args)
            local removed
            for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
              local bufs = vim.t[tab].bufs
              if bufs then
                for i, bufnr in ipairs(bufs) do
                  if bufnr == args.buf then
                    removed = true
                    table.remove(bufs, i)
                    vim.t[tab].bufs = bufs
                    break
                  end
                end
              end
            end
            vim.t.bufs = vim.tbl_filter(require("astrocore.buffer").is_valid, vim.t.bufs)
            if removed then require("astrocore").event "BufsUpdated" end
            vim.cmd.redrawtabline()
          end,
        },
      },
      checktime = {
        {
          event = { "FocusGained", "TermClose", "TermLeave" },
          desc = "Check if buffers changed on editor focus",
          command = "checktime",
        },
      },
      create_dir = {
        {
          event = "BufWritePre",
          desc = "Automatically create parent directories if they don't exist when saving a file",
          callback = function(args)
            if not require("astrocore.buffer").is_valid(args.buf) then return end
            vim.fn.mkdir(vim.fn.fnamemodify(vim.loop.fs_realpath(args.match) or args.match, ":p:h"), "p")
          end,
        },
      },
      editorconfig_filetype = {
        {
          event = "FileType",
          desc = "configure editorconfig after filetype detection to override `ftplugin`s",
          callback = function(args)
            if vim.F.if_nil(vim.b.editorconfig, vim.g.editorconfig, true) then
              local editorconfig_avail, editorconfig = pcall(require, "editorconfig")
              if editorconfig_avail then editorconfig.config(args.buf) end
            end
          end,
        },
      },
      file_user_events = {
        {
          event = { "BufReadPost", "BufNewFile", "BufWritePost" },
          desc = "AstroNvim user events for file detection (AstroFile and AstroGitFile)",
          callback = function(args)
            if vim.b.astrofile_checking then return end
            vim.b.astrofile_checking = true
            vim.schedule(function()
              local astro = require "astrocore"
              local current_file = vim.api.nvim_buf_get_name(args.buf)
              if vim.g.vscode or not (current_file == "" or vim.bo[args.buf].buftype == "nofile") then
                astro.event "File"
                local folder = vim.fn.fnamemodify(current_file, ":p:h")
                if vim.fn.has "win32" == 1 then folder = ('"%s"'):format(folder) end
                if astro.cmd({ "git", "-C", folder, "rev-parse" }, false) or astro.file_worktree() then
                  astro.event "GitFile"
                  pcall(vim.api.nvim_del_augroup_by_name, "file_user_events")
                end
              end
              vim.b.astrofile_checking = nil
            end)
          end,
        },
      },
      highlighturl = {
        {
          event = { "VimEnter", "FileType", "BufEnter", "WinEnter" },
          desc = "URL Highlighting",
          callback = function() require("astrocore").set_url_match() end,
        },
      },
      highlightyank = {
        {
          event = "TextYankPost",
          desc = "Highlight yanked text",
          pattern = "*",
          callback = function() vim.highlight.on_yank() end,
        },
      },
      large_buf_settings = {
        {
          event = "User",
          desc = "Disable certain functionality on very large files",
          pattern = "AstroLargeBuf",
          callback = function(args)
            vim.opt_local.wrap = true -- enable wrap, long lines in vim are slow
            vim.opt_local.list = false -- disable list chars
            vim.b[args.buf].autoformat = false -- disable autoformat on save
            vim.b[args.buf].cmp_enabled = false -- disable completion
            vim.b[args.buf].miniindentscope_disable = true -- disable indent scope
            vim.b[args.buf].matchup_matchparen_enabled = 0 -- disable vim-matchup
            local ibl_avail, ibl = pcall(require, "ibl") -- disable indent-blankline
            if ibl_avail then ibl.setup_buffer(args.buf, { enabled = false }) end
            local illuminate_avail, illuminate = pcall(require, "illuminate.engine") -- disable vim-illuminate
            if illuminate_avail then illuminate.stop_buf(args.buf) end
            local rainbow_avail, rainbow = pcall(require, "rainbow-delimiters") -- disable rainbow-delimiters
            if rainbow_avail then rainbow.disable(args.buf) end
          end,
        },
      },
      q_close_windows = {
        {
          event = "BufWinEnter",
          desc = "Make q close help, man, quickfix, dap floats",
          callback = function(event)
            if vim.tbl_contains({ "help", "nofile", "quickfix" }, vim.bo[event.buf].buftype) then
              vim.keymap.set("n", "q", "<Cmd>close<CR>", {
                desc = "Close window",
                buffer = event.buf,
                silent = true,
                nowait = true,
              })
            end
          end,
        },
      },
      terminal_settings = {
        {
          event = "TermOpen",
          desc = "Disable line number/fold column/sign column for terinals",
          callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.foldcolumn = "0"
            vim.opt_local.signcolumn = "no"
          end,
        },
      },
      unlist_quickfix = {
        {
          event = "FileType",
          desc = "Unlist quickfist buffers",
          pattern = "qf",
          callback = function() vim.opt_local.buflisted = false end,
        },
      },
    },
    on_keys = {
      auto_hlsearch = {
        function(char)
          if vim.fn.mode() == "n" then
            local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
            if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
          end
        end,
      },
    },
  },
}
