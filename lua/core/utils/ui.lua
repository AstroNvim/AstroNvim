-- Functions to toggle User Interface (UI) behaviors
--
local bool2str = function(bool) return bool and "on" or "off" end

-- Toggle autopairs upon user request
function astronvim.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    vim.notify "autopairs not available"
  end
end

-- Toggle background="dark"|"light"
function astronvim.toggle_background()
  local background = vim.go.background -- global
  if background == "light" then
    vim.go.background = "dark"
  else
    vim.go.background = "light"
  end
  vim.notify(string.format("background=%s", vim.go.background))
end

-- https://github.com/hrsh7th/nvim-cmp/issues/261 -- My own old solution
-- https://github.com/hrsh7th/nvim-cmp/issues/106 -- New calling convention setup.buffer
-- NEW : https://www.reddit.com/r/neovim/comments/rh0ohq/nvimcmp_temporarily_disable_autocompletion/ even better
function astronvim.set_cmp_autocomplete()
  local ok, _ = pcall(require, "cmp")
  local autocomplete = {}
  if ok then
    if vim.g.cmp_enabled then autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged } end
  end
  return autocomplete
end

-- Toggle cmp upon user request
function astronvim.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.setup {
      completion = {
        autocomplete = vim.g.cmp_enabled and { require("cmp.types").cmp.TriggerEvent.TextChanged } or {},
      },
    }
    vim.notify(string.format("completion %s", bool2str(vim.g.cmp_enabled)))
  else
    vim.notify "completion not available"
  end
end

-- Toggle signcolumn="auto"|"no"
function astronvim.toggle_signcolumn()
  if vim.wo.signcolumn == "no" then
    vim.wo.signcolumn = "yes"
  elseif vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  vim.notify(string.format("signcolumn=%s", vim.wo.signcolumn))
end

-- Set the indent and tab related numbers.
function astronvim.set_indent()
  local indent = tonumber(vim.fn.input "Set indent value (>0 expandtab, <=0 noexpandtab, 0 vim defaults): ")
  if not indent then
    indent = -8 -- noexpandtab, tabstop=8
  end
  vim.bo.expandtab = (indent > 0) -- local to buffer
  indent = math.abs(indent)
  vim.bo.tabstop = indent -- local to buffer
  vim.bo.softtabstop = indent -- local to buffer
  vim.bo.shiftwidth = indent -- local to buffer
  vim.notify(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
end

-- Change the number display modes.
function astronvim.change_number()
  local number = vim.wo.number -- local to window
  local relativenumber = vim.wo.relativenumber -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
  elseif number and not relativenumber then
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false
  else -- not number and relativenumber
    vim.wo.relativenumber = false
  end
  vim.notify(string.format("number=%s, relativenumber=%s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

-- Toggle spell.
function astronvim.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  vim.notify(string.format("spell=%s", bool2str(vim.wo.spell)))
end

-- Toggle wrap.
function astronvim.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  vim.notify(string.format("wrap=%s", bool2str(vim.wo.wrap)))
end

-- Toggle syntax/treesitter
function astronvim.toggle_syntax()
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.g.syntax_on then -- global var for on//off
    if ts_avail and parsers.has_parser() then vim.cmd "TSBufDisable highlight" end
    vim.cmd "syntax off" -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then vim.cmd "TSBufEnable highlight" end
    vim.cmd "syntax on" -- set vim.g.syntax_on = true
  end
  vim.notify(string.format("syntax %s", bool2str(vim.g.syntax_on)))
end
