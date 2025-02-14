return {
  "windwp/nvim-autopairs",
  event = "User AstroFile",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>ua"] = { function() require("astrocore.toggles").autopairs() end, desc = "Toggle autopairs" }
      end,
    },
  },
  opts_extend = { "disable_filetype" },
  opts = {
    check_ts = true,
    enabled = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
    ts_config = { java = false },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  },
  config = function(...) require "astronvim.plugins.configs.nvim-autopairs"(...) end,
}
