return function(_, opts)
  require("heirline").setup(opts)

  vim.api.nvim_create_autocmd("User", {
    pattern = "AstroColorScheme",
    group = vim.api.nvim_create_augroup("Heirline", { clear = true }),
    desc = "Refresh heirline colors",
    callback = function() require("astroui.status.heirline").refresh_colors() end,
  })
end
