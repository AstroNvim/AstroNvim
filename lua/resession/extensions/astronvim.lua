local M = {}

M.on_save = function()
  -- initiate astronvim data
  local data = { bufnrs = {}, tabs = {} }

  local buf_utils = require "astronvim.utils.buffer"

  data.current_buf = buf_utils.current_buf
  data.last_buf = buf_utils.last_buf

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

  local buf_utils = require "astronvim.utils.buffer"
  buf_utils.current_buf = new_bufnrs[data.current_buf]
  buf_utils.last_buf = new_bufnrs[data.last_buf]

  require("astronvim.utils").event "BufsUpdated"

  if vim.opt.bufhidden:get() == "wipe" and vim.fn.bufnr() ~= buf_utils.current_buf then
    vim.cmd.b(buf_utils.current_buf)
  end
end

return M
