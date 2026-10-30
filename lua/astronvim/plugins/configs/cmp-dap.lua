local registered_blink_modules = setmetatable({}, { __mode = "k" })

return function(_, _)
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    local registered_sources = registered_blink_modules[blink] or {}
    registered_blink_modules[blink] = registered_sources
    for _, dap_ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
      if not registered_sources[dap_ft] then
        blink.add_filetype_source(dap_ft, "dap")
        registered_sources[dap_ft] = true
      end
    end
  end
end
