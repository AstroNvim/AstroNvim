-- Functions to toggle and tweak User Experience
--
local is_available = astronvim.is_available

local bool2str = function(bool)
  return bool and "on" or "off"
end

local normal_buftype = function()
  return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt'
end

-- Toggle background="dark"|"light"
astronvim.toggle_background = function()
  local background = vim.go.background  -- global
  if background == "light" then
    vim.go.background = "dark"
  else
    vim.go.background = "light"
  end
  print(string.format("background=%s", vim.go.background))
end

-- https://github.com/hrsh7th/nvim-cmp/issues/261
-- My own old solution
-- https://github.com/hrsh7th/nvim-cmp/issues/106
-- require('cmp').setup.buffer { enabled = false } -- new calling convention
vim.g.cmp_toggle_flag = true -- initialize

astronvim.toggle_completion = function()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    local next_cmp_toggle_flag = not vim.g.cmp_toggle_flag
    if next_cmp_toggle_flag then
      print("completion on")
    else
      print("completion off")
    end
    cmp.setup.buffer {
      enabled = function()
        vim.g.cmp_toggle_flag = next_cmp_toggle_flag
        if next_cmp_toggle_flag then
          return normal_buftype
        else
          return next_cmp_toggle_flag
        end
      end
    }
  else
    print("completion not available")
  end
end

-- Toggle signcolumn="auto"|"no"
astronvim.toggle_signcolumn = function()
  local signcolumn = vim.wo.signcolumn  -- local to window
  if signcolumn == "no" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  print(string.format("signcolumn=%s", vim.wo.signcolumn))
end

-- Set the indent and tab related numbers.
astronvim.set_indent = function()
  local indent = tonumber(
    vim.fn.input("Set indent value (>0 expandtab, <=0 noexpandtab, 0 vim defaults): ")
  )
  if not indent then
    indent = -8                         -- noexpandtab, tabstop=8
  end
  vim.bo.expandtab = (indent > 0)       -- local to buffer
  indent = math.abs(indent)
  vim.bo.tabstop = indent               -- local to buffer
  vim.bo.softtabstop = indent           -- local to buffer
  vim.bo.shiftwidth = indent            -- local to buffer
  print(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
end

-- Change the number display modes.
astronvim.change_number = function()
  local number = vim.wo.number          -- local to window
  local relativenumber = vim.wo.relativenumber  -- local to window
  if (number == false) and (relativenumber == false) then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif (number == true) and (relativenumber == false) then
    vim.wo.number = false
    vim.wo.relativenumber = true
  elseif (number == false) and (relativenumber == true) then
    vim.wo.number = true
    vim.wo.relativenumber = true
  else -- (number == true) and (relativenumber == true) then
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
  print(
    string.format("number=%s, relativenumber=%s",
      bool2str(vim.wo.number),
      bool2str(vim.wo.relativenumber)
    )
  )
end

-- Toggle spell.
astronvim.toggle_spell = function()
  vim.wo.spell = not vim.wo.spell       -- local to window
  print(string.format("spell=%s", bool2str(vim.wo.spell)))
end

-- Toggle syntax/treesitter
astronvim.toggle_syntax = function()
  local parsers = require("nvim-treesitter.parsers")
  if parsers.has_parser() then
    if vim.g.syntax_on then               -- local to buffer
      vim.cmd("TSBufDisable highlight")
      vim.cmd("syntax off")
    else
      vim.cmd("TSBufEnable highlight")
      vim.cmd("syntax on")
    end
    local state = bool2str(vim.g.syntax_on)
    print(string.format("treesitter %s", state))
  else
    if vim.g.syntax_on then
      vim.cmd("syntax off")
    else
      vim.cmd("syntax on")
    end
    local state = bool2str(vim.g.syntax_on)
    print(string.format("syntax %s", state))
  end
end

