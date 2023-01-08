local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }
  vim.fn.system { "git", "-C", lazypath, "checkout", "tags/stable" }
  local oldcmdheight = vim.opt.cmdheight:get()
  vim.opt.cmdheight = 1
  vim.notify "Please wait while plugins are installed..."
  vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "LazyInstall",
    callback = function()
      vim.cmd.bw()
      vim.opt.cmdheight = oldcmdheight
      vim.tbl_map(function(module) pcall(require, module) end, { "nvim-treesitter", "mason" })
      astronvim.notify "Mason is installing packages if configured, check status with :Mason"
    end,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(astronvim.user_plugin_opts("lazy", {
  spec = { { import = "plugins" }, { import = "user.plugins" } },
  defaults = { lazy = true },
  install = { colorscheme = { astronvim.user_plugin_opts("colorscheme", false, false), "astronvim" } },
  performance = {
    rtp = {
      paths = { astronvim.install.config },
      disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin", "matchparen" },
    },
  },
  lockfile = vim.fn.stdpath "data" .. "/lazy-lock.json",
}))
