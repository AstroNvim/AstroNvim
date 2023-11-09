return function(_, opts)
  if type(opts.ensure_installed) == "table" then
    local added = {}
    opts.ensure_installed = vim.tbl_filter(function(parser)
      if added[parser] then return false end
      added[parser] = true
      return true
    end, opts.ensure_installed)
  end
  require("nvim-treesitter.configs").setup(opts)
end
