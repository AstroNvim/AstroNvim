return {
        -- You can also add new plugins here as well:
        -- Add plugins, the lazy syntax
        -- "andweeb/presence.nvim",
        "windwp/windline.nvim",
        event = "BufEnter",
        config = function() require "wlsample.airline_anim" end,
}
