local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function assert_nonempty_strings(values, names)
  for _, name in ipairs(names) do
    assert.equals("string", type(values[name]), name)
    assert.is_true(#values[name] > 0, name)
  end
end

T["DECL-01 enables the AstroTheme dashboard integration"] = function()
  unit_helpers.with_module("astronvim.plugins._astrotheme", nil, function(spec)
    assert.equals("AstroNvim/astrotheme", spec[1])
    assert.is_true(spec.lazy)
    assert.is_true(spec.opts.plugins["dashboard-nvim"])
  end)
end

T["DECL-01 keeps selected AstroUI icon, text-icon, and LazyGit theme declarations"] = function()
  local calls = {}

  unit_helpers.with_module("astronvim.plugins._astroui", {
    vim = {
      fn = {
        stdpath = function(name)
          table.insert(calls, { name = "stdpath", argument = name })
          return "/cache"
        end,
      },
      fs = {
        normalize = function(path)
          table.insert(calls, { name = "normalize", argument = path })
          return "normalized:" .. path
        end,
      },
    },
  }, function(spec)
    local options = spec.opts

    assert.equals("astrotheme", options.colorscheme)
    assert_nonempty_strings(options.icons, { "ActiveLSP", "DiagnosticError", "FolderClosed", "GitBranch", "TabClose" })
    assert.equals("LSP:", options.text_icons.ActiveLSP)
    assert.equals("...", options.text_icons.Ellipsis)
    assert.equals("[lock]", options.text_icons.FileReadOnly)
    assert.equals("|", options.text_icons.GitSign)

    assert.equals("normalized:/cache/astroui-lazygit-config.yml", options.lazygit.theme_path)
    assert.equals("Special", options.lazygit.theme[241].fg)
    assert.equals("MatchParen", options.lazygit.theme.activeBorderColor.fg)
    assert.is_true(options.lazygit.theme.activeBorderColor.bold)
    assert.equals("Visual", options.lazygit.theme.selectedLineBgColor.bg)
    assert.equals("DiagnosticError", options.lazygit.theme.unstagedChangesColor.fg)
  end)

  assert.same({
    { name = "stdpath", argument = "cache" },
    { name = "normalize", argument = "/cache/astroui-lazygit-config.yml" },
  }, calls)
end

return T
