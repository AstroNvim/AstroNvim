local status_ok, aerial = pcall(require, "aerial")
if not status_ok then return end
aerial.setup(astronvim.user_plugin_opts("plugins.aerial", {
  attach_mode = "global",
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    min_width = 28,
  },
  show_guides = true,
  filter_kind = false,
  guides = {
    mid_item = "├ ",
    last_item = "└ ",
    nested_top = "│ ",
    whitespace = "  ",
  },
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '[y' and ']y'
    vim.keymap.set("n", "[y", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "Previous Aerial" })
    vim.keymap.set("n", "]y", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "Next Aerial" })
    -- Jump up the tree with '[Y' or ']Y'
    vim.keymap.set("n", "[Y", "<cmd>AerialPrevUp<cr>", { buffer = bufnr, desc = "Previous and Up in Aerial" })
    vim.keymap.set("n", "]Y", "<cmd>AerialNextUp<cr>", { buffer = bufnr, desc = "Next and Up in Aerial" })
  end,
}))
