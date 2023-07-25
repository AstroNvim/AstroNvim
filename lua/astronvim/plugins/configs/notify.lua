return function(_, opts)
  local notify = require "notify"
  notify.setup(opts)
  vim.notify = notify
end
