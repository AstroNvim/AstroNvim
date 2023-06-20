local M = {}

M.on_save = function()
  -- initiate astronvim data
  local data = { last_bufnr = vim.fn.bufnr(), bufnrs = {}, tabs = {} }

  -- save tab scoped buffers and buffer numbers from buffer name
  for new_tabpage, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    data.tabs[new_tabpage] = vim.t[tabpage].bufs
    for _, bufnr in ipairs(data.tabs[new_tabpage]) do
      data.bufnrs[vim.api.nvim_buf_get_name(bufnr)] = bufnr
    end
  end

  return data
end

M.on_load = function(data)
  -- create map from old buffer numbers to new buffer numbers
  local new_bufnrs = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname and data.bufnrs[bufname] then new_bufnrs[data.bufnrs[bufname]] = bufnr end
  end
  -- build new tab scoped buffer lists
  for tabpage, tabs in pairs(data.tabs) do
    vim.t[tabpage].bufs = vim.tbl_map(function(bufnr) return new_bufnrs[bufnr] end, tabs)
  end
  require("astronvim.utils").event "BufsUpdated"
  if vim.fn.bufnr() ~= new_bufnrs[data.last_bufnr] then vim.cmd.b(new_bufnrs[data.last_bufnr]) end
end

return M
