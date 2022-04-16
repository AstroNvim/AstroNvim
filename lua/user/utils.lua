
local M = {}

-- OPEN file, url, or directory with an external app
M.openExtApp = function()

  local commandsOpen = {unix="xdg-open", mac="open", win="start"}
  if vim.fn.has "mac" == 1 then local osKey = "mac" 
    elseif vim.fn.has "unix" == 1 then local osKey = "unix" 
    elseif vim.fn.has("win") == 1 then local osKey = "win"
  end

  local cword = vim.fn.expand("<cWORD>")

  if string.len(cword) ~= 0 then
    arg, nrepl = string.gsub(cword, "^www.", "http://www.", 1)
    if nrepl == 0 then arg = vim.fn.shellescape(arg) end
  else
    -- arg = vim.fn.shellescape(cword)
    arg = vim.fn.shellescape(vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":p"))
  end

  os.execute(commandsOpen[osKey] .. ' ' .. arg)
  vim.cmd("redraw!")
end

return M
