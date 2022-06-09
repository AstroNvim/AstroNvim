local is_available = astronvim.is_available
local cmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local create_command = vim.api.nvim_create_user_command

augroup("highlighturl", { clear = true })
cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = "highlighturl",
  pattern = "*",
  callback = function()
    astronvim.set_url_match()
  end,
})

if is_available "alpha-nvim" then
  augroup("alpha_settings", { clear = true })
  if is_available "bufferline.nvim" then
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
      local alpha_avail, alpha = pcall(require, "alpha")
      if alpha_avail then
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
          alpha.start(true)
        end
      end
    end,
  })
end

if is_available "neo-tree.nvim" then
  augroup("neotree_start", { clear = true })
  cmd("BufEnter", {
    desc = "Open Neo-Tree on startup with directory",
    group = "neotree_start",
    callback = function()
      local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
      if stats and stats.type == "directory" then
        require("neo-tree.setup.netrw").hijack()
      end
    end,
  })
end

if is_available "feline.nvim" then
  augroup("feline_setup", { clear = true })
  cmd("ColorScheme", {
    desc = "Reload feline on colorscheme change",
    group = "feline_setup",
    callback = function()
      package.loaded["configs.feline"] = nil
      require "configs.feline"
    end,
  })
end

create_command("AstroUpdate", astronvim.updater.update, { desc = "Update AstroNvim" })
create_command("AstroVersion", astronvim.updater.version, { desc = "Check AstroNvim Version" })
create_command("ToggleHighlightURL", astronvim.toggle_url_match, { desc = "Toggle URL Highlights" })
