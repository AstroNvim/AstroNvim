return function()
  local parser, cleaner
  local vscode = require "dap.ext.vscode"
  vscode.json_decode = function(str)
    if cleaner == nil then
      local plenary_avail, plenary = pcall(require, "plenary.json")
      cleaner = plenary_avail and function(s) return plenary.json_strip_comments(s, {}) end or false
    end
    if not parser then
      local json5_avail, json5 = pcall(require, "json5")
      parser = json5_avail and json5.parse or vim.json.decode
    end
    if type(cleaner) == "function" then str = cleaner(str) end
    local parsed_ok, parsed = pcall(parser, str)
    if not parsed_ok then
      require("astrocore").notify("Error parsing `.vscode/launch.json`.", vim.log.levels.ERROR)
      parsed = {}
    end
    return parsed
  end
end
