local M = {}

function M.check()
  vim.health.report_start "AstroNvim"

  vim.health.report_info("AstroNvim Version: " .. require("astronvim.utils.updater").version(true))
  vim.health.report_info("Neovim Version: v" .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*"))

  if vim.version().prerelease then
    vim.health.report_warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.8" == 1 then
    vim.health.report_ok "Using stable Neovim >= 0.8.0"
  else
    vim.health.report_error "Neovim >= 0.8.0 is required"
  end

  local programs = {
    { cmd = "git", type = "error", msg = "Used for core functionality such as updater and plugin management" },
    {
      cmd = { "xdg-open", "open", "explorer" },
      type = "warn",
      msg = "Used for `gx` mapping for opening files with system opener (Optional)",
    },
    { cmd = "lazygit", type = "warn", msg = "Used for mappings to pull up git TUI (Optional)" },
    { cmd = "node", type = "warn", msg = "Used for mappings to pull up node REPL (Optional)" },
    { cmd = "gdu", type = "warn", msg = "Used for mappings to pull up disk usage analyzer (Optional)" },
    { cmd = "btm", type = "warn", msg = "Used for mappings to pull up system monitor (Optional)" },
    { cmd = { "python", "python3" }, type = "warn", msg = "Used for mappings to pull up python REPL (Optional)" },
  }

  for _, program in ipairs(programs) do
    if type(program.cmd) == "string" then program.cmd = { program.cmd } end
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        found = true
        break
      end
    end

    if found then
      vim.health.report_ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      vim.health["report_" .. program.type](("`%s` is not installed: %s"):format(name, program.msg))
    end
  end
end

return M
