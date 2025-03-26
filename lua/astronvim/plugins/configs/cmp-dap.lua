return function(_, _)
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    for _, dap_ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
      blink.add_filetype_source(dap_ft, "dap")
    end
  end
end
