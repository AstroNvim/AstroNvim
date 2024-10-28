-- ### AstroNvim Health Checks
--
-- use with `:checkhealth astronvim`
--
-- copyright 2023
-- license GNU General Public License v3.0

local M = {}

local health = vim.health

function M.check()
  health.start "AstroNvim"

  health.info("AstroNvim Version: " .. require("astronvim").version())
  health.info("Neovim Version: v" .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*"))

  if vim.version().prerelease then
    health.warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.9.5" == 1 then
    health.ok "Using stable Neovim >= 0.9.5"
  else
    health.error "Neovim >= 0.9.5 is required"
  end

  local programs = {
    {
      cmd = { "git" },
      type = "error",
      msg = "Used for core functionality such as updater and plugin management",
    },
    {
      cmd = { "xdg-open", "rundll32", "explorer.exe", "open" },
      type = "warn",
      msg = "Used for `gx` mapping for opening files with system opener (Optional)",
    },
    {
      cmd = { "rg" },
      type = "warn",
      msg = "Used for Telescope `live_grep` picker, `<Leader>fw` and `<Leader>fW` by default (Optional)",
    },
    { cmd = { "lazygit" }, type = "warn", msg = "Used for mappings to pull up git TUI (Optional)" },
    { cmd = { "node" }, type = "warn", msg = "Used for mappings to pull up node REPL (Optional)" },
    {
      cmd = { vim.fn.has "mac" == 1 and "gdu-go" or "gdu", "gdu_windows_amd64.exe" },
      type = "warn",
      msg = "Used for mappings to pull up disk usage analyzer (Optional)",
    },
    { cmd = { "btm" }, type = "warn", msg = "Used for mappings to pull up system monitor (Optional)" },
    { cmd = { "python", "python3" }, type = "warn", msg = "Used for mappings to pull up python REPL (Optional)" },
  }

  for _, program in ipairs(programs) do
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        if not program.extra_check or program.extra_check(program) then found = true end
        break
      end
    end

    if found then
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health[program.type](("`%s` is not installed: %s"):format(name, program.msg))
    end
  end

  local function check_duplicate_mappings(all_maps)
    local set_mappings, any_duplicates = {}, false
    for mode, mappings in pairs(all_maps) do
      for lhs, rhs in pairs(mappings) do
        if rhs then
          if not set_mappings[mode] then set_mappings[mode] = {} end
          local normalized_lhs = vim.api.nvim_replace_termcodes(lhs, true, true, true)
          if set_mappings[mode][normalized_lhs] then
            set_mappings[mode][normalized_lhs][lhs] = rhs
            set_mappings[mode][normalized_lhs][1] = true
            any_duplicates = true
          else
            set_mappings[mode][normalized_lhs] = { [1] = false, [lhs] = rhs }
          end
        end
      end
    end

    if any_duplicates then
      local msg = ""
      for mode, mappings in pairs(set_mappings) do
        local mode_msg
        for _, duplicate_mappings in pairs(mappings) do
          if duplicate_mappings[1] then
            if not mode_msg then
              mode_msg = ("Duplicate mappings detected in mode `%s`:\n"):format(mode)
            else
              mode_msg = mode_msg .. "\n"
            end
            for lhs, rhs in pairs(duplicate_mappings) do
              if type(lhs) == "string" then
                mode_msg = mode_msg .. ("- %s: %s\n"):format(lhs, type(rhs) == "table" and (rhs.desc or rhs[1]) or rhs)
              end
            end
          end
        end
        if mode_msg then msg = msg .. mode_msg end
      end
      health.warn(
        msg,
        "Make sure to normalize the left hand side of mappings to what is used in :h keycodes. This includes making sure to capitalize <Leader> and <LocalLeader>."
      )
    else
      health.ok "No duplicate mappings detected"
    end
  end

  local astrocore_avail, astrocore = pcall(require, "astrocore")
  if astrocore_avail then
    health.start "Checking for duplicate mappings in AstroCore"
    check_duplicate_mappings(astrocore.config.mappings)
  end

  local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
  if astrolsp_avail then
    health.start "Checking for duplicate mappings in AstroLSP"
    check_duplicate_mappings(astrolsp.config.mappings)
  end
end

return M
