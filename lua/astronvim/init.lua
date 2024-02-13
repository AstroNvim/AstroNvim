local M = {}

M.did_init = false

M.config = require "astronvim.config"

function M.init()
  if vim.fn.has "nvim-0.9" == 0 then
    vim.api.nvim_echo({
      { "AstroNvimVim requires Neovim >= 0.9.0\n", "ErrorMsg" },
      { "Press any key to exit", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end

  if not M.did_init then
    M.did_init = true

    if vim.g.astronvim_first_install then
      vim.api.nvim_create_autocmd("User", {
        desc = "Load Mason and Treesitter after Lazy installs plugins",
        once = true,
        pattern = "LazyInstall",
        callback = function()
          vim.cmd.bw()
          vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })
        end,
      })
    end

    -- force setup during initialization
    local plugin = require("lazy.core.config").spec.plugins.AstroNvim

    local opts = require("lazy.core.plugin").values(plugin, "opts")
    if opts.pin_plugins == nil then opts.pin_plugins = plugin.version ~= nil end

    ---@diagnostic disable-next-line: cast-local-type
    opts = vim.tbl_deep_extend("force", M.config, opts)
    ---@cast opts -nil
    M.config = opts

    if not vim.g.mapleader and M.config.mapleader then vim.g.mapleader = M.config.mapleader end
    if not vim.g.maplocalleader and M.config.maplocalleader then vim.g.maplocalleader = M.config.maplocalleader end
    if M.config.icons_enabled == false then vim.g.icons_enabled = false end
  end
end

function M.setup() end

return M
