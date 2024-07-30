return function()
  local parser, cleaner
  local vscode = require "dap.ext.vscode"
  vscode.json_decode = function(str)
    if cleaner == nil then
      local plenary_avail, plenary = pcall(require, "plenary.json")
      if plenary_avail then str = plenary.json_strip_comments(str, {}) end
      cleaner = plenary_avail and function(s) return plenary.json_strip_comments(s, {}) end or false
    end
    if type(parser) ~= "function" then
      local json5_avail, json5 = pcall(require, "json5")
      parser = json5_avail and json5.parse or vim.json.decode
    end
    if type(cleaner) == "function" then str = cleaner(str) end
    return parser(str)
  end
  if (vim.uv or vim.loop).fs_stat(vim.fn.getcwd() .. "/.vscode/launch.json") then vscode.load_launchjs() end
end
