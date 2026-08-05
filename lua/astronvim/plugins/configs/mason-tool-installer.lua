return function(_, opts)
  local mason_tool_installer = require "mason-tool-installer"
  mason_tool_installer.setup(opts)
  if opts.run_on_start ~= false and vim.v.vim_did_enter == 1 then
    pcall(vim.api.nvim_del_augroup_by_name, "mti_start")
    mason_tool_installer.run_on_start()
  end
end
