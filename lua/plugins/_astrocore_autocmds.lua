return {
  "astrocore",
  opts = {
    commands = {
      AstroChangelog = { function() require("astrocore.updater").changelog() end, desc = "Check AstroNvim Changelog" },
      AstroReload = { function() require("astrocore.utils").reload() end, desc = "Reload AstroNvim (Experimental)" },
      AstroRollback = { function() require("astrocore.updater").rollback() end, desc = "Rollback AstroNvim" },
      AstroUpdate = { function() require("astrocore.updater").update() end, desc = "Update AstroNvim" },
      AstroUpdatePackages = {
        function() require("astrocore.updater").update_packages() end,
        desc = "Update Plugins and Mason",
      },
      AstroVersion = { function() require("astrocore.updater").version() end, desc = "Check AstroNvim Version" },
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
                local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
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
              local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
              local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
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
            require("astrocore.utils").event "BufsUpdated"
          end,
        },
        {
          event = "BufDelete",
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
            if removed then require("astrocore.utils").event "BufsUpdated" end
            vim.cmd.redrawtabline()
          end,
        },
      },
      file_user_events = {
        {
          event = { "BufReadPost", "BufNewFile", "BufWritePost" },
          desc = "AstroNvim user events for file detection (AstroFile and AstroGitFile)",
          callback = function(args)
            local utils = require "astrocore.utils"
            if
              not (vim.fn.expand "%" == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile")
            then
              utils.event "File"
              if
                require("astrocore.git").file_worktree()
                or utils.cmd({ "git", "-C", vim.fn.expand "%:p:h", "rev-parse" }, false)
              then
                utils.event "GitFile"
                vim.api.nvim_del_augroup_by_name "file_user_events"
              end
            end
          end,
        },
      },
      highlighturl = {
        {
          event = { "VimEnter", "FileType", "BufEnter", "WinEnter" },
          desc = "URL Highlighting",
          callback = function() require("astrocore.utils").set_url_match() end,
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
      large_buf = {
        {
          event = "BufReadPre",
          desc = "Disable certain functionality on very large files",
          callback = function(args)
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
            vim.b[args.buf].large_buf = (ok and stats and stats.size > vim.g.max_file.size)
              or vim.api.nvim_buf_line_count(args.buf) > vim.g.max_file.lines
          end,
        },
      },
      q_close_windows = {
        {
          event = "BufWinEnter",
          desc = "Make q close help, man, quickfix, dap floats",
          callback = function(event)
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
            if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) then
              vim.keymap.set("n", "q", "<cmd>close<cr>", {
                desc = "Close window",
                buffer = event.buf,
                silent = true,
                nowait = true,
              })
            end
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
