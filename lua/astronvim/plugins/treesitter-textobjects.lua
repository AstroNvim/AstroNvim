return {
  -- "nvim-treesitter/nvim-treesitter-textobjects",
  "TheLeoP/nvim-treesitter-textobjects",
  branch = "refactor_standalone",
  lazy = true,
  dependencies = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        for object, opt in pairs {
          ["k"] = { query = "@block", desc = "block" },
          ["c"] = { query = "@class", desc = "class" },
          ["?"] = { query = "@conditional", desc = "conditional" },
          ["f"] = { query = "@function", desc = "function " },
          ["o"] = { query = "@loop", desc = "loop" },
          ["a"] = { query = "@parameter", desc = "argument" },
        } do
          for motion, map in pairs {
            a = { query = opt.query .. ".outer", desc = "around " .. opt.desc },
            i = { query = opt.query .. ".inner", desc = "inside " .. opt.desc },
          } do
            local lhs = motion .. object
            local rhs = {
              function() require("nvim-treesitter-textobjects.select").select_textobject(map.query, "textobjects") end,
              desc = map.desc,
            }
            for _, mode in ipairs { "x", "o" } do
              opts.mappings[mode][lhs] = rhs
            end
          end
        end

        for object, opt in pairs {
          k = { query = "@block.outer", desc = "block" },
          f = { query = "@function.outer", desc = "function" },
          a = { query = "@parameter.inner", desc = "argument" },
        } do
          for lhs, map in pairs {
            ["]" .. object] = { func = "goto_next_start", desc = "Next " .. opt.desc .. " start" },
            ["[" .. object] = { func = "goto_previous_start", desc = "Previous " .. opt.desc .. " start" },
            ["]" .. object:upper()] = { func = "goto_next_end", desc = "Next " .. opt.desc .. " end" },
            ["[" .. object:upper()] = { func = "goto_previous_end", desc = "Previous " .. opt.desc .. " end" },
          } do
            local rhs = {
              function() require("nvim-treesitter-textobjects.move")[map.func](opt.query, "textobjects") end,
              desc = map.desc,
            }
            for _, mode in ipairs { "n", "x", "o" } do
              opts.mappings[mode][lhs] = rhs
            end
          end
        end

        for lhs, opt in pairs {
          K = { query = "@block.outer", desc = "block" },
          F = { query = "@function.outer", desc = "function" },
          A = { query = "@parameter.inner", desc = "argument" },
        } do
          opts.mappings.n["<" .. lhs] = {
            function() require("nvim-treesitter-textobjects.swap").swap_previous(opt.query)() end,
            desc = "Swap previous " .. opt.desc,
          }
          opts.mappings.n[">" .. lhs] = {
            function() require("nvim-treesitter-textobjects.swap").swap_next(opt.query)() end,
            desc = "Swap next " .. opt.desc,
          }
        end
      end,
    },
  },
  opts = {
    select = {
      lookahead = true,
    },
  },
}
