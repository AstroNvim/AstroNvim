local M = {}

function M.highlight(group, color)
  local fg = color.fg and "guifg = " .. color.fg or "guifg = NONE"
  local bg = color.bg and "guibg = " .. color.bg or "guibg = NONE"
  local sp = color.sp and "guisp = " .. color.sp or "guisp = NONE"
  local style = color.style and "gui = " .. color.style or "gui = NONE"

  vim.cmd("highlight " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp .. " ")
end

return M
