return function(_, opts)
  require("alpha").setup(opts.config)

  vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
      local stats = require("lazy").stats()
      local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
      opts.section.footer.val =
        { " ", " ", " ", "AstroNvim loaded " .. stats.count .. " plugins   in " .. ms .. "ms" }
      opts.section.footer.opts.hl = "DashboardFooter"
    end,
  })
end
