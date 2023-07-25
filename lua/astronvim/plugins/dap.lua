return {
  "mfussenegger/nvim-dap",
  enabled = vim.fn.has "win32" == 0,
  dependencies = {
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = { "nvim-dap" },
      cmd = { "DapInstall", "DapUninstall" },
      opts = { handlers = {} },
    },
    {
      "rcarriga/nvim-dap-ui",
      opts = { floating = { border = "rounded" } },
      config = require "astronvim.plugins.configs.nvim-dap-ui",
    },
    {
      "rcarriga/cmp-dap",
      dependencies = { "nvim-cmp" },
      config = require "astronvim.plugins.configs.cmp-dap",
    },
    {
      "astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local is_available = require("astrocore.utils").is_available
        if is_available "nvim-dap" then
          maps.n["<leader>d"] = opts._map_section.d
          maps.v["<leader>d"] = opts._map_section.d
          -- modified function keys found with `showkey -a` in the terminal to get key code
          -- run `nvim -V3log +quit` and search through the "Terminal info" in the `log` file for the correct keyname
          maps.n["<F5>"] = { function() require("dap").continue() end, desc = "Debugger: Start" }
          maps.n["<F17>"] = { function() require("dap").terminate() end, desc = "Debugger: Stop" } -- Shift+F5
          maps.n["<F21>"] = { -- Shift+F9
            function()
              vim.ui.input({ prompt = "Condition: " }, function(condition)
                if condition then require("dap").set_breakpoint(condition) end
              end)
            end,
            desc = "Debugger: Conditional Breakpoint",
          }
          maps.n["<F29>"] = { function() require("dap").restart_frame() end, desc = "Debugger: Restart" } -- Control+F5
          maps.n["<F6>"] = { function() require("dap").pause() end, desc = "Debugger: Pause" }
          maps.n["<F9>"] = { function() require("dap").toggle_breakpoint() end, desc = "Debugger: Toggle Breakpoint" }
          maps.n["<F10>"] = { function() require("dap").step_over() end, desc = "Debugger: Step Over" }
          maps.n["<F11>"] = { function() require("dap").step_into() end, desc = "Debugger: Step Into" }
          maps.n["<F23>"] = { function() require("dap").step_out() end, desc = "Debugger: Step Out" } -- Shift+F11
          maps.n["<leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" }
          maps.n["<leader>dB"] = { function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" }
          maps.n["<leader>dc"] = { function() require("dap").continue() end, desc = "Start/Continue (F5)" }
          maps.n["<leader>dC"] = {
            function()
              vim.ui.input({ prompt = "Condition: " }, function(condition)
                if condition then require("dap").set_breakpoint(condition) end
              end)
            end,
            desc = "Conditional Breakpoint (S-F9)",
          }
          maps.n["<leader>di"] = { function() require("dap").step_into() end, desc = "Step Into (F11)" }
          maps.n["<leader>do"] = { function() require("dap").step_over() end, desc = "Step Over (F10)" }
          maps.n["<leader>dO"] = { function() require("dap").step_out() end, desc = "Step Out (S-F11)" }
          maps.n["<leader>dq"] = { function() require("dap").close() end, desc = "Close Session" }
          maps.n["<leader>dQ"] = { function() require("dap").terminate() end, desc = "Terminate Session (S-F5)" }
          maps.n["<leader>dp"] = { function() require("dap").pause() end, desc = "Pause (F6)" }
          maps.n["<leader>dr"] = { function() require("dap").restart_frame() end, desc = "Restart (C-F5)" }
          maps.n["<leader>dR"] = { function() require("dap").repl.toggle() end, desc = "Toggle REPL" }
          maps.n["<leader>ds"] = { function() require("dap").run_to_cursor() end, desc = "Run To Cursor" }

          if is_available "nvim-dap-ui" then
            maps.n["<leader>dE"] = {
              function()
                vim.ui.input({ prompt = "Expression: " }, function(expr)
                  if expr then require("dapui").eval(expr) end
                end)
              end,
              desc = "Evaluate Input",
            }
            maps.v["<leader>dE"] = { function() require("dapui").eval() end, desc = "Evaluate Input" }
            maps.n["<leader>du"] = { function() require("dapui").toggle() end, desc = "Toggle Debugger UI" }
            maps.n["<leader>dh"] = { function() require("dap.ui.widgets").hover() end, desc = "Debugger Hover" }
          end
        end
      end,
    },
  },
  event = "User AstroFile",
}
