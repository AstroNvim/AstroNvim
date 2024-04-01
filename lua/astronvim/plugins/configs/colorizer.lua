return function(_, opts)
  local colorizer = require "colorizer"
  colorizer.setup(opts)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab].bufs then vim.tbl_map(function(buf) colorizer.attach_to_buffer(buf) end, vim.t[tab].bufs) end
  end
end
