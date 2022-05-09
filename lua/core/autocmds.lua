local utils = require "core.utils"

local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local create_command = vim.api.nvim_create_user_command

augroup("highlighturl", { clear = true })
cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = "highlighturl",
  pattern = "*",
  callback = require("core.utils").set_url_match,
})

if utils.is_available "alpha-nvim" then
  augroup("alpha_settings", { clear = true })
  if utils.is_available "bufferline.nvim" then
    cmd("FileType", {
      desc = "Disable tabline for alpha",
      group = "alpha_settings",
      pattern = "alpha",
      callback = function()
        local prev_showtabline = vim.opt.showtabline
        vim.opt.showtabline = 0
        cmd("BufUnload", {
          pattern = "<buffer>",
          callback = function()
            vim.opt.showtabline = prev_showtabline
          end,
        })
      end,
    })
  end
  cmd("FileType", {
    desc = "Disable statusline for alpha",
    group = "alpha_settings",
    pattern = "alpha",
    callback = function()
      local prev_status = vim.opt.laststatus
      vim.opt.laststatus = 0
      cmd("BufUnload", {
        pattern = "<buffer>",
        callback = function()
          vim.opt.laststatus = prev_status
        end,
      })
    end,
  })
  cmd("VimEnter", {
    desc = "Start Alpha when vim is opened with no arguments",
    group = "alpha_settings",
    callback = function()
      -- optimized start check from https://github.com/goolord/alpha-nvim
      local should_skip = false
      if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 or not vim.o.modifiable then
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
        local alpha_avail, alpha = pcall(require, "alpha")
        if alpha_avail then
          alpha.start(true)
        end
      end
    end,
  })
end

create_command("AstroUpdate", require("core.utils").update, { desc = "Update AstroNvim" })

create_command("ToggleHighlightURL", require("core.utils").toggle_url_match, { desc = "Toggle URL Highlights" })
