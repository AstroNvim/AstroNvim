return function(_, opts)
  local npairs = require "nvim-autopairs"
  npairs.setup(opts)

  if not vim.g.autopairs_enabled then npairs.disable() end
  local cmp_status_ok, cmp = pcall(require, "cmp")
  if cmp_status_ok then
    cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false })
  end
end
