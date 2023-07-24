return {
  "goolord/alpha-nvim",
  cmd = "Alpha",
  dependencies = {
    {
      "astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if require("astrocore.utils").is_available "alpha-nvim" then
          maps.n["<leader>h"] = {
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
              event = { "User", "BufEnter" },
              desc = "Disable status and tablines for alpha",
              callback = function(event)
                if
                  (
                    (event.event == "User" and event.file == "AlphaReady")
                    or (
                      event.event == "BufEnter"
                      and vim.api.nvim_get_option_value("filetype", { buf = event.buf }) == "alpha"
                    )
                  ) and not vim.g.before_alpha
                then
                  vim.g.before_alpha =
                    { showtabline = vim.opt.showtabline:get(), laststatus = vim.opt.laststatus:get() }
                  vim.opt.showtabline, vim.opt.laststatus = 0, 0
                elseif
                  vim.g.before_alpha
                  and event.event == "BufEnter"
                  and vim.api.nvim_get_option_value("buftype", { buf = event.buf }) ~= "nofile"
                then
                  vim.opt.laststatus, vim.opt.showtabline =
                    vim.g.before_alpha.laststatus, vim.g.before_alpha.showtabline
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
                local should_skip = false
                if vim.fn.argc() > 0 or vim.fn.line2byte(vim.fn.line "$") ~= -1 or not vim.o.modifiable then
                  should_skip = true
                else
                  for _, arg in pairs(vim.v.argv) do
                    if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
                      should_skip = true
                      break
                    end
                  end
                end
                if not should_skip then
                  require("alpha").start(true, require("alpha").default_config)
                  vim.schedule(function() vim.cmd.doautocmd "FileType" end)
                end
              end,
            },
          }
        end
      end,
    },
  },
  opts = function()
    local dashboard = require "alpha.themes.dashboard"
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

    local button = require("astrocore.utils").alpha_button
    local get_icon = require("astroui").get_icon
    dashboard.section.buttons.val = {
      button("LDR n  ", get_icon("FileNew", 2, true) .. "New File  "),
      button("LDR f f", get_icon("Search", 2, true) .. "Find File  "),
      button("LDR f o", get_icon("DefaultFile", 2, true) .. "Recents  "),
      button("LDR f w", get_icon("WordFile", 2, true) .. "Find Word  "),
      button("LDR f '", get_icon("Bookmarks", 2, true) .. "Bookmarks  "),
      button("LDR S l", get_icon("Refresh", 2, true) .. "Last Session  "),
    }

    dashboard.config.layout[1].val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }
    dashboard.config.layout[3].val = 5
    dashboard.config.opts.noautocmd = true
    return dashboard
  end,
  config = require "plugins.configs.alpha",
}
