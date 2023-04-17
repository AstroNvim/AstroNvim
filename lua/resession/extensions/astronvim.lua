local M = {}

M.on_save = function()
  -- initiate astronvim data
  local data = { bufnrs = {}, tabs = {} }

  -- save tab scoped buffers and buffer numbers from buffer name
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    data.tabs[tabpage] = vim.t[tabpage].bufs
    for _, bufnr in ipairs(data.tabs[tabpage]) do
      data.bufnrs[vim.api.nvim_buf_get_name(bufnr)] = bufnr
    end
  end

  return data
end

M.on_load = function(data)
  -- create map from old buffer numbers to new buffer numbers
  local new_bufnrs = {}
  vim.print(vim.api.nvim_list_bufs())
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname and bufname ~= "" then new_bufnrs[data.bufnrs[bufname]] = bufnr end
  end
  -- build new tab scoped buffer lists
  for tabpage, tabs in pairs(data.tabs) do
    vim.t[tabpage].bufs = vim.tbl_map(function(bufnr) return new_bufnrs[bufnr] end, tabs)
  end
end

return M
