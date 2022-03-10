local M = {}

function M.config()
  local status_ok, toggleterm = pcall(require, "toggleterm")
  if not status_ok then
    return
  end

  toggleterm.setup(require("core.utils").user_plugin_opts("toggleterm", {
    size = 10,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  }))

  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new { cmd = "lazygit", hidden = true }

  function _LAZYGIT_TOGGLE()
    lazygit:toggle()
  end

  local node = Terminal:new { cmd = "node", hidden = true }

  function _NODE_TOGGLE()
    node:toggle()
  end

  local ncdu = Terminal:new { cmd = "ncdu", hidden = true }

  function _NCDU_TOGGLE()
    ncdu:toggle()
  end

  local htop = Terminal:new { cmd = "htop", hidden = true }

  function _HTOP_TOGGLE()
    htop:toggle()
  end

  local python = Terminal:new { cmd = "python", hidden = true }

  function _PYTHON_TOGGLE()
    python:toggle()
  end
end

return M
