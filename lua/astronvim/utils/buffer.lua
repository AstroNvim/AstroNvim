--- ### AstroNvim Buffer Utilities
--
-- Buffer management related utility functions
--
-- This module can be loaded with `local buffer_utils = require "astronvim.utils.buffer"`
--
-- @module astronvim.utils.buffer
-- @copyright 2022
-- @license GNU General Public License v3.0

local M = {}

--- Check if a buffer is valid
-- @param bufnr the buffer to check
-- @return true if the buffer is valid or false
function M.is_valid(bufnr)
  if not bufnr or bufnr < 1 then return false end
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

--- Move the current buffer tab n places in the bufferline
-- @param n number of tabs to move the current buffer over by (positive = right, negative = left)
function M.move(n)
  if n == 0 then return end -- if n = 0 then no shifts are needed
  local bufs = vim.t.bufs -- make temp variable
  for i, bufnr in ipairs(bufs) do -- loop to find current buffer
    if bufnr == vim.api.nvim_get_current_buf() then -- found index of current buffer
      for _ = 0, (n % #bufs) - 1 do -- calculate number of right shifts
        local new_i = i + 1 -- get next i
        if i == #bufs then -- if at end, cycle to beginning
          new_i = 1 -- next i is actually 1 if at the end
          local val = bufs[i] -- save value
          table.remove(bufs, i) -- remove from end
          table.insert(bufs, new_i, val) -- insert at beginning
        else -- if not at the end,then just do an in place swap
          bufs[i], bufs[new_i] = bufs[new_i], bufs[i]
        end
        i = new_i -- iterate i to next value
      end
      break
    end
  end
  vim.t.bufs = bufs -- set buffers
  require("astronvim.utils").event "BufsUpdated"
  vim.cmd.redrawtabline() -- redraw tabline
end

--- Navigate left and right by n places in the bufferline
-- @param n the number of tabs to navigate to (positive = right, negative = left)
function M.nav(n)
  local current = vim.api.nvim_get_current_buf()
  for i, v in ipairs(vim.t.bufs) do
    if current == v then
      vim.cmd.b(vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1])
      break
    end
  end
end

--- Navigate to a specific buffer by its position in the bufferline
-- @param tabnr the position of the buffer to navigate to
function M.nav_to(tabnr) vim.cmd.b(vim.t.bufs[tabnr]) end

--- Close a given buffer
-- @param bufnr? the buffer number to close or the current buffer if not provided
-- @param force? whether or not to foce close the buffers or confirm changes (default: false)
function M.close(bufnr, force)
  if force == nil then force = false end
  if require("astronvim.utils").is_available "bufdelete.nvim" then
    require("bufdelete").bufdelete(bufnr, force)
  else
    vim.cmd((force and "bd!" or "confirm bd") .. bufnr)
  end
end

--- Close all buffers
-- @param keep_current? whether or not to keep the current buffer (default: false)
-- @param force? whether or not to foce close the buffers or confirm changes (default: false)
function M.close_all(keep_current, force)
  if force == nil then force = false end
  if keep_current == nil then keep_current = false end
  local current = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.t.bufs) do
    if not keep_current or bufnr ~= current then
      if require("astronvim.utils").is_available "bufdelete.nvim" then
        require("bufdelete").bufdelete(bufnr, force)
      else
        vim.cmd((force and "bd!" or "confirm bd") .. bufnr)
      end
    end
  end
end

--- Close the current tab
function M.close_tab()
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.t.bufs = nil
    require("astronvim.utils").event "BufsUpdated"
    vim.cmd.tabclose()
  end
end

return M
