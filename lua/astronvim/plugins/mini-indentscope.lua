local ignore_filetypes = {
  "aerial",
  "alpha",
  "dashboard",
  "help",
  "lazy",
  "mason",
  "neo-tree",
  "NvimTree",
  "neogitstatus",
  "notify",
  "startify",
  "toggleterm",
  "Trouble",
}
local ignore_buftypes = {
  "nofile",
  "prompt",
  "quickfix",
  "terminal",
}
local char = "▏"

return {
  "echasnovski/mini.indentscope",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "lukas-reineke/indent-blankline.nvim",
      dependencies = {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          if require("astrocore").is_available "indent-blankline.nvim" then
            -- HACK: indent blankline doesn't properly refresh when scrolling the window
            -- remove when fixed upstream: https://github.com/lukas-reineke/indent-blankline.nvim/issues/489
            opts.autocmds.indent_blankline_refresh_scroll = {
              {
                event = "WinScrolled",
                desc = "Refresh indent blankline on window scroll",
                callback = function()
                  if vim.v.event.all.leftcol ~= 0 then pcall(vim.cmd.IndentBlanklineRefresh) end
                end,
              },
            }
          end
        end,
      },
      opts = {
        buftype_exclude = ignore_buftypes,
        filetype_exclude = ignore_filetypes,
        show_trailing_blankline_indent = false,
        use_treesitter = true,
        char = char,
        context_char = char,
      },
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if require("astrocore").is_available "mini.indentscope" then
          local blankline_opts = require("astrocore").plugin_opts "indent-blankline.nvim"
          opts.autocmds.indentscope_disabled = {
            {
              event = "FileType",
              desc = "Disable indentscope for certain filetypes",
              callback = function(event)
                if vim.b[event.buf].minicursorword_disable == nil then
                  local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
                  if vim.tbl_contains(blankline_opts.filetype_exclude or ignore_filetypes, filetype) then
                    vim.b[event.buf].miniindentscope_disable = true
                  end
                end
              end,
            },
            {
              event = "BufWinEnter",
              desc = "Disable indentscope for certain buftypes",
              callback = function(event)
                if vim.b[event.buf].minicursorword_disable == nil then
                  local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
                  if vim.tbl_contains(blankline_opts.buftype_exclude or ignore_buftypes, buftype) then
                    vim.b[event.buf].miniindentscope_disable = true
                  end
                end
              end,
            },
            {
              event = "TermOpen",
              desc = "Disable indentscope for terminals",
              callback = function(event)
                if vim.b[event.buf].minicursorword_disable == nil then
                  vim.b[event.buf].miniindentscope_disable = true
                end
              end,
            },
          }
        end
      end,
    },
  },
  opts = function()
    return {
      draw = { delay = 0, animation = function() return 0 end },
      options = { border = "top", try_as_border = true },
      symbol = require("astrocore").plugin_opts("indent-blankline.nvim").context_char or char,
    }
  end,
}
