local user_plugin_opts = astronvim.user_plugin_opts
local is_available = astronvim.is_available
local wk = require "which-key"
local register = wk.register

wk.setup(user_plugin_opts("plugins.which-key", {
  plugins = {
    spelling = { enabled = true },
    presets = { operators = false },
  },
  window = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
  disable = { filetypes = { "TelescopePrompt" } },
}))

register({
  f = { name = "File" },
  p = { name = "Packages" },
  l = { name = "LSP" },
  u = { name = "UI" },
}, { prefix = "<leader>" })

local sections = {
  b = { name = "Buffers" },
  D = { name = "Debugger" },
  g = { name = "Git" },
  s = { name = "Search" },
  S = { name = "Session" },
  t = { name = "Terminal" },
}

if is_available "Comment.nvim" then
  local comments = { c = "Comment toggle linewise", b = "Comment toggle blockwise" }
  register(comments, { mode = "n", prefix = "g" })
  register(comments, { mode = "v", prefix = "g" })
end
if is_available "gitsigns.nvim" then register({ g = sections["g"] }, { prefix = "<leader>" }) end
if is_available "heirline.nvim" then register({ b = sections["b"] }, { prefix = "<leader>" }) end
if is_available "neovim-session-manager" then register({ S = sections["S"] }, { prefix = "<leader>" }) end
if is_available "nvim-dap" then register({ D = sections["D"] }, { prefix = "<leader>" }) end
if is_available "telescope.nvim" then register({ s = sections["s"], g = sections["g"] }, { prefix = "<leader>" }) end
if is_available "toggleterm.nvim" then register({ g = sections["g"], t = sections["t"] }, { prefix = "<leader>" }) end
