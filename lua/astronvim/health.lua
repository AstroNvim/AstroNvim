local M = {}

-- TODO: remove deprecated method check after dropping support for neovim v0.9
local health = {
  start = vim.health.start or vim.health.report_start,
  ok = vim.health.ok or vim.health.report_ok,
  warn = vim.health.warn or vim.health.report_warn,
  error = vim.health.error or vim.health.report_error,
  info = vim.health.info or vim.health.report_info,
}

function M.check()
  health.start "AstroNvim"

  health.info("AstroNvim Version: " .. require("astronvim.utils.updater").version(true))
  health.info("Neovim Version: v" .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*"))

  if vim.version().prerelease then
    health.warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.8" == 1 then
    health.ok "Using stable Neovim >= 0.8.0"
  else
    health.error "Neovim >= 0.8.0 is required"
  end

  local programs = {
    { cmd = { "git" }, type = "error", msg = "Used for core functionality such as updater and plugin management" },
    {
      cmd = { "xdg-open", "open", "explorer" },
      type = "warn",
      msg = "Used for `gx` mapping for opening files with system opener (Optional)",
    },
    { cmd = { "lazygit" }, type = "warn", msg = "Used for mappings to pull up git TUI (Optional)" },
    { cmd = { "node" }, type = "warn", msg = "Used for mappings to pull up node REPL (Optional)" },
    { cmd = { "gdu" }, type = "warn", msg = "Used for mappings to pull up disk usage analyzer (Optional)" },
    { cmd = { "btm" }, type = "warn", msg = "Used for mappings to pull up system monitor (Optional)" },
    { cmd = { "python", "python3" }, type = "warn", msg = "Used for mappings to pull up python REPL (Optional)" },
  }

  for _, program in ipairs(programs) do
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
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health[program.type](("`%s` is not installed: %s"):format(name, program.msg))
    end
  end
end

return M
