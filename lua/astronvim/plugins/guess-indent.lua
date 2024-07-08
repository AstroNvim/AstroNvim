return {
  "NMAC427/guess-indent.nvim",
  cmd = "GuessIndent",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          GuessIndent = {
            {
              event = "BufReadPost",
              desc = "Guess indentation when loading a file",
              callback = function(args) require("guess-indent").set_from_buffer(args.buf, true, true) end,
            },
            {
              event = "BufNewFile",
              desc = "Guess indentation when saving a new file",
              callback = function(args)
                vim.api.nvim_create_autocmd("BufWritePost", {
                  buffer = args.buf,
                  once = true,
                  callback = function(wargs) require("guess-indent").set_from_buffer(wargs.buf, true, true) end,
                })
              end,
            },
          },
        },
      },
    },
  },
  opts = { auto_cmd = false },
}
