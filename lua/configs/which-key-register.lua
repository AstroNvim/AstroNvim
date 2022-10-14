local is_available = astronvim.is_available
local user_plugin_opts = astronvim.user_plugin_opts
local mappings = {
  n = {
    ["<leader>"] = {
      f = { name = "File" },
      p = { name = "Packages" },
      l = { name = "LSP" },
      u = { name = "UI" },
    },
  },
}

local extra_sections = {
  g = "Git",
  s = "Search",
  S = "Session",
  t = "Terminal",
}

local function init_table(mode, prefix, idx)
  if not mappings[mode][prefix][idx] then mappings[mode][prefix][idx] = { name = extra_sections[idx] } end
end

if is_available "neovim-session-manager" then init_table("n", "<leader>", "S") end

if is_available "gitsigns.nvim" then init_table("n", "<leader>", "g") end

if is_available "toggleterm.nvim" then
  init_table("n", "<leader>", "g")
  init_table("n", "<leader>", "t")
end

if is_available "telescope.nvim" then
  init_table("n", "<leader>", "s")
  init_table("n", "<leader>", "g")
end

astronvim.which_key_register(user_plugin_opts("which-key.register", mappings))
