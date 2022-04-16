
M = {}


-- unsepcifc commands
vim.cmd("command! Mappings enew|pu=execute('map')")
vim.cmd("command! Cd2This lcd %:p:h")
-- vim.cmd([[command! Words2String :s/\(\w\+\)/'\1'/g]])
vim.cmd([[command! -range Words2String :'<,'>s/\%V\(\h\+\)/'\1'/g]])

vim.cmd([[
  command! KeyMaps :call utils#KeyMaps()
  " save and quit
  command! W :w!
  command! Q :q
  cnoreabbrev <silent> ww w!
  cnoreabbrev <silent> wwa wa!
  cnoreabbrev <silent> xx x!
  cnoreabbrev <silent> xxa xa!
  cnoreabbrev <silent> qq q!
  cnoreabbrev <silent> qqa qa!
  cnoreabbrev <silent> ee e!
]])


----------------------------------------------
-- MarkdownPreview
----------------------------------------------

vim.cmd([[
  command! Pv :MarkdownPreview
]])

----------------------------------------------
-- Telescope
----------------------------------------------

M.telescope = function()
  vim.cmd("command! Zoxide lua require'plugins.telescope'.pickers.zoxide()")
end

return M

