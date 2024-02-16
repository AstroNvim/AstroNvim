return {
  "lukas-reineke/indent-blankline.nvim",
  branch = "current-indent",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>uI"] = { "<Cmd>IBLToggle<CR>", desc = "Toggle indent guides" }
      end,
    },
  },
  main = "ibl",
  opts = {
    indent = { char = "▏" },
    current_indent = { enabled = true, show_start = false, show_end = false },
    scope = { enabled = false },
    exclude = {
      buftypes = {
        "nofile",
        "prompt",
        "quickfix",
        "terminal",
      },
      filetypes = {
        "aerial",
        "alpha",
        "dashboard",
        "help",
        "lazy",
        "mason",
        "neo-tree",
        "NvimTree",
        "neogitstatus",
        "notify",
        "startify",
        "toggleterm",
        "Trouble",
      },
    },
  },
}
