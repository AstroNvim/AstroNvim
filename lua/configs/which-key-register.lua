local status_ok, which_key = pcall(require, "which-key")
if status_ok then
  local is_available = astronvim.is_available
  local user_plugin_opts = astronvim.user_plugin_opts
  local mappings = {
    n = {
      ["<leader>"] = {
        f = { name = "File" },
        p = { name = "Packer" },
        l = { name = "LSP" },
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
    if not mappings[mode][prefix][idx] then
      mappings[mode][prefix][idx] = { name = extra_sections[idx] }
    end
  end

  if is_available "neovim-session-manager" then
    init_table("n", "<leader>", "S")
  end

  if is_available "gitsigns.nvim" then
    init_table("n", "<leader>", "g")
  end

  if is_available "toggleterm.nvim" then
    init_table("n", "<leader>", "g")
    init_table("n", "<leader>", "t")
  end

  if is_available "telescope.nvim" then
    init_table("n", "<leader>", "s")
    init_table("n", "<leader>", "g")
  end

  mappings = user_plugin_opts("which-key.register_mappings", mappings)
  -- support previous legacy notation, deprecate at some point
  mappings.n["<leader>"] = user_plugin_opts("which-key.register_n_leader", mappings.n["<leader>"])
  for mode, prefixes in pairs(mappings) do
    for prefix, mapping_table in pairs(prefixes) do
      which_key.register(mapping_table, {
        mode = mode,
        prefix = prefix,
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
      })
    end
  end
end
