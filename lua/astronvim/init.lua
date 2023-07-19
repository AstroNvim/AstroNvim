local M = {}

M.did_init = false

function M.init()
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

    -- set options
    if vim.bo.filetype == "lazy" then vim.cmd.bw() end
    require "astronvim.options"
  end
end

return M
