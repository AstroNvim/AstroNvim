-- Functions to change User Interface behavior
--
local bool2str = function(bool)
  return bool and "on" or "off"
end

local normal_buftype = function()
  return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt'
end

-- Toggle background="dark"|"light"
function astronvim.toggle_background()
  local background = vim.go.background  -- global
  if background == "light" then
    vim.go.background = "dark"
  else
    vim.go.background = "light"
  end
  astronvim.echo({{string.format("background=%s", vim.go.background)}})
end

-- https://github.com/hrsh7th/nvim-cmp/issues/261
-- My own old solution
-- https://github.com/hrsh7th/nvim-cmp/issues/106
-- require('cmp').setup.buffer { enabled = false } -- new calling convention
vim.g.cmp_toggle_flag = true -- initialize global var for toggle_completion

function astronvim.toggle_completion()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    vim.g.cmp_toggle_flag = not vim.g.cmp_toggle_flag
    if vim.g.cmp_toggle_flag then
      astronvim.echo({{"completion on"}})
    else
      astronvim.echo({{"completion off"}})
    end
    cmp.setup.buffer {
      enabled = function()
        if vim.g.cmp_toggle_flag then
          return normal_buftype
        else
          return false
        end
      end
    }
  else
    astronvim.echo({{"completion not available"}})
  end
end

-- Toggle signcolumn="auto"|"no"
function astronvim.toggle_signcolumn()
  local signcolumn = vim.wo.signcolumn  -- local to window
  if signcolumn == "no" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  astronvim.echo({{string.format("signcolumn=%s", vim.wo.signcolumn)}})
end

-- Set the indent and tab related numbers.
function astronvim.set_indent()
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
  astronvim.echo({{string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab")}})
end

-- Change the number display modes.
function astronvim.change_number()
  local number = vim.wo.number          -- local to window
  local relativenumber = vim.wo.relativenumber  -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif number and not relativenumber then
    vim.wo.number = false
    vim.wo.relativenumber = true
  elseif not number and relativenumber then
    vim.wo.number = true
    vim.wo.relativenumber = true
  else -- number and relativenumber
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
  astronvim.echo(
    {{
      string.format("number=%s, relativenumber=%s",
        bool2str(vim.wo.number),
        bool2str(vim.wo.relativenumber)
      )
    }}
  )
end

-- Toggle spell.
function astronvim.toggle_spell()
  vim.wo.spell = not vim.wo.spell       -- local to window
  astronvim.echo({{string.format("spell=%s", bool2str(vim.wo.spell))}})
end

-- Toggle syntax/treesitter
function astronvim.toggle_syntax()
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.g.syntax_on then               -- global var for on//off
    if ts_avail and parsers.has_parser() then
      vim.cmd("TSBufDisable highlight")
    end
    vim.cmd("syntax off")  -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then
      vim.cmd("TSBufEnable highlight")
    end
    vim.cmd("syntax on")   -- set vim.g.syntax_on = true
  end
  local state = bool2str(vim.g.syntax_on)
  if ts_avail and parsers.has_parser() then
    astronvim.echo({{string.format("syntax and treesitter %s", state)}})
  else
    astronvim.echo({{string.format("syntax %s", state)}})
  end
end

