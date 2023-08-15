return {
  "goolord/alpha-nvim",
  cmd = "Alpha",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if require("astrocore").is_available "alpha-nvim" then
          maps.n["<Leader>h"] = {
            function()
              local wins = vim.api.nvim_tabpage_list_wins(0)
              if #wins > 1 and vim.api.nvim_get_option_value("filetype", { win = wins[1] }) == "neo-tree" then
                vim.fn.win_gotoid(wins[2]) -- go to non-neo-tree window to toggle alpha
              end
              require("alpha").start(false, require("alpha").default_config)
            end,
            desc = "Home Screen",
          }
          opts.autocmds.alpha_settings = {
            {
              event = { "User", "BufWinEnter" },
              desc = "Disable status, tablines, and cmdheight for alpha",
              callback = function(event)
                if
                  (
                    (event.event == "User" and event.file == "AlphaReady")
                    or (
                      event.event == "BufWinEnter"
                      and vim.api.nvim_get_option_value("filetype", { buf = event.buf }) == "alpha"
                    )
                  ) and not vim.g.before_alpha
                then
                  vim.g.before_alpha = {
                    showtabline = vim.opt.showtabline:get(),
                    laststatus = vim.opt.laststatus:get(),
                    cmdheight = vim.opt.cmdheight:get(),
                  }
                  vim.opt.showtabline, vim.opt.laststatus, vim.opt.cmdheight = 0, 0, 0
                elseif
                  vim.g.before_alpha
                  and event.event == "BufWinEnter"
                  and vim.api.nvim_get_option_value("buftype", { buf = event.buf }) ~= "nofile"
                then
                  vim.opt.laststatus, vim.opt.showtabline, vim.opt.cmdheight =
                    vim.g.before_alpha.laststatus, vim.g.before_alpha.showtabline, vim.g.before_alpha.cmdheight
                  vim.g.before_alpha = nil
                end
              end,
            },
          }
          opts.autocmds.alpha_autostart = {
            {
              event = "VimEnter",
              desc = "Start Alpha when vim is opened with no arguments",
              callback = function()
                local should_skip
                local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
                if
                  vim.fn.argc() > 0 -- don't start when opening a file
                  or #lines > 1 -- don't open if current buffer has more than 1 line
                  or (#lines == 1 and lines[1]:len() > 0) -- don't open the current buffer if it has anything on the first line
                  or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
                  or not vim.o.modifiable -- don't open if not modifiable
                then
                  should_skip = true
                else
                  for _, arg in pairs(vim.v.argv) do
                    if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
                      should_skip = true
                      break
                    end
                  end
                end
                if should_skip then return end
                require("alpha").start(true, require("alpha").default_config)
                vim.schedule(function() vim.cmd.doautocmd "FileType" end)
              end,
            },
          }
        end
      end,
    },
  },
  opts = function()
    local dashboard = require "alpha.themes.dashboard"

    local orig_button = dashboard.button -- customize button function
    dashboard.button = function(...)
      return vim.tbl_deep_extend("force", orig_button(...), {
        opts = { cursor = -2, width = 36, hl = "DashboardCenter", hl_shortcut = "DashboardShortcut" },
      })
    end
    dashboard.leader = "LDR"

    dashboard.section.header.val = {
      " █████  ███████ ████████ ██████   ██████",
      "██   ██ ██         ██    ██   ██ ██    ██",
      "███████ ███████    ██    ██████  ██    ██",
      "██   ██      ██    ██    ██   ██ ██    ██",
      "██   ██ ███████    ██    ██   ██  ██████",
      " ",
      "    ███    ██ ██    ██ ██ ███    ███",
      "    ████   ██ ██    ██ ██ ████  ████",
      "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
      "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
      "    ██   ████   ████   ██ ██      ██",
    }
    dashboard.section.header.opts.hl = "DashboardHeader"
    dashboard.section.footer.opts.hl = "DashboardFooter"

    local get_icon = require("astroui").get_icon
    dashboard.section.buttons.val = {
      dashboard.button("LDR n  ", get_icon("FileNew", 2, true) .. "New File  "),
      dashboard.button("LDR f f", get_icon("Search", 2, true) .. "Find File  "),
      dashboard.button("LDR f o", get_icon("DefaultFile", 2, true) .. "Recents  "),
      dashboard.button("LDR f w", get_icon("WordFile", 2, true) .. "Find Word  "),
      dashboard.button("LDR f '", get_icon("Bookmarks", 2, true) .. "Bookmarks  "),
      dashboard.button("LDR S l", get_icon("Refresh", 2, true) .. "Last Session  "),
    }

    dashboard.config.layout = {
      { type = "padding", val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) } },
      dashboard.section.header,
      { type = "padding", val = 5 },
      dashboard.section.buttons,
      { type = "padding", val = 3 },
      dashboard.section.footer,
    }
    dashboard.config.opts.noautocmd = true
    return dashboard
  end,
  config = function(...) require "astronvim.plugins.configs.alpha"(...) end,
}
