return function(_, opts)
  local notify = require "notify"
  notify.setup(opts)
  require("astronvim.notify").setup(notify)
end
