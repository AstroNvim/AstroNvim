local status_ok, Comment = pcall(require, "Comment")
if not status_ok then return end
local utils = require "Comment.utils"
Comment.setup(astronvim.user_plugin_opts("plugins.Comment", {
  pre_hook = function(ctx)
    local location = nil
    if ctx.ctype == utils.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring {
      key = ctx.ctype == utils.ctype.line and "__default" or "__multiline",
      location = location,
    }
  end,
}))
