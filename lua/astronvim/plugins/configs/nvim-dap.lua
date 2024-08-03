return function()
  local parser, cleaner
  local vscode = require "dap.ext.vscode"
  vscode.json_decode = function(str)
    if not cleaner then cleaner = require("astrocore.json").json_strip_comments end
    if not parser then
      local json5_avail, json5 = pcall(require, "json5")
      parser = json5_avail and json5.parse or vim.json.decode
    end
    local parsed_ok, parsed = pcall(parser, cleaner(str))
    if not parsed_ok then
      require("astrocore").notify("Error parsing `.vscode/launch.json`.", vim.log.levels.ERROR)
      parsed = {}
    end
    return parsed
  end
  if (vim.uv or vim.loop).fs_stat(vim.fn.getcwd() .. "/.vscode/launch.json") then vscode.load_launchjs() end
end
