local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()
local root_init = require("config").root .. "/init.lua"

T["ENTRY-01 shows direct-configuration guidance before waiting and quitting"] = function()
  local calls = { events = {}, echoes = {}, getchar = 0 }

  unit_helpers.with_module("unit_helpers", {
    vim = {
      api = {
        nvim_echo = function(chunks, history, options)
          table.insert(calls.events, "echo")
          table.insert(calls.echoes, { chunks = chunks, history = history, options = options })
        end,
      },
      fn = {
        getchar = function()
          calls.getchar = calls.getchar + 1
          table.insert(calls.events, "getchar")
        end,
      },
      cmd = {
        quit = function() table.insert(calls.events, "quit") end,
      },
    },
  }, function() assert(loadfile(root_init))() end)

  assert.equals(1, #calls.echoes)
  assert.equals(true, calls.echoes[1].history)
  assert.same({}, calls.echoes[1].options)
  assert.same({
    { "This repository is not meant to be used as a direct Neovim configuration\n", "ErrorMsg" },
    { "Please check the AstroNvim documentation for installation details\n", "WarningMsg" },
    { "Press any key to exit...", "MoreMsg" },
  }, calls.echoes[1].chunks)
  assert.equals(1, calls.getchar)
  assert.same({ "echo", "getchar", "quit" }, calls.events)
end

return T
