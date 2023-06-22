return function(_, opts)
  require("mason").setup(opts)

  -- TODO: AstroNvim v4: change these auto command names to not conflict with core Mason commands
  local cmd = vim.api.nvim_create_user_command
  cmd("MasonUpdate", function(options) require("astronvim.utils.mason").update(options.fargs) end, {
    nargs = "*",
    desc = "Update Mason Package",
    complete = function(arg_lead)
      local _ = require "mason-core.functional"
      return _.sort_by(
        _.identity,
        _.filter(_.starts_with(arg_lead), require("mason-registry").get_installed_package_names())
      )
    end,
  })
  cmd(
    "MasonUpdateAll",
    function() require("astronvim.utils.mason").update_all() end,
    { desc = "Update Mason Packages" }
  )

  for _, plugin in ipairs { "mason-lspconfig", "mason-null-ls", "mason-nvim-dap" } do
    pcall(require, plugin)
  end
end
