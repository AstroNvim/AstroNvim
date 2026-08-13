local MiniTest = require "mini.test"
local unit_helpers = require "unit_helpers"

local T = MiniTest.new_set()

local SHARED_WORKFLOW_REF = "main"

local function assert_nonempty_strings(values, names)
  for _, name in ipairs(names) do
    assert.equals("string", type(values[name]), name)
    assert.is_true(#values[name] > 0, name)
  end
end

local function read_file(path)
  local file = assert(io.open(path, "rb"))
  local contents = assert(file:read "*a")
  file:close()
  return contents
end

local function workflow_job(workflow, name)
  local start = assert(workflow:find("\n  " .. name .. ":\n", 1, true))
  local finish = workflow:find("\n  [_%a][_%w-]*:\n", start + 1)
  return workflow:sub(start, finish and finish - 1 or #workflow)
end

local function make_target_body(makefile, target)
  local start = assert(makefile:find("\n" .. target .. ":\n", 1, true))
  local finish = makefile:find("\n[%a_][%w_-]*:", start + 1)
  return makefile:sub(start, finish and finish - 1 or #makefile)
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

T["CI-CONTRACT-01 delegates Neovim testing and separates unprivileged CI from release"] = function()
  local workflow = read_file(vim.fn.getcwd() .. "/.github/workflows/ci.yml")
  local ci = workflow_job(workflow, "CI")
  local tests = workflow_job(workflow, "Tests")
  local release = workflow_job(workflow, "Release")
  local pr = workflow_job(workflow, "PR")
  local announcement = workflow_job(workflow, "Announcement")

  assert.is_truthy(workflow:find("pull_request_target:", 1, true))
  assert.is_truthy(workflow:find("types: [opened, edited, synchronize]", 1, true))
  assert.is_truthy(workflow:find("types: [published]", 1, true))
  assert.is_truthy(workflow:find('cron: "0 6 * * *"', 1, true))
  assert.is_truthy(workflow:find('cron: "0 8 * * 1"', 1, true))

  assert.is_truthy(ci:find("plugin_ci.yml@" .. SHARED_WORKFLOW_REF, 1, true))
  assert.is_truthy(ci:find("github.event_name == 'pull_request'", 1, true))
  assert.is_truthy(ci:find("contents: read", 1, true))
  assert.is_truthy(ci:find("is_production: false", 1, true))
  assert.is_truthy(ci:find("docs: false", 1, true))
  assert.is_nil(ci:find("secrets:", 1, true))

  assert.is_truthy(tests:find("neovim_testing.yml@" .. SHARED_WORKFLOW_REF, 1, true))
  assert.is_truthy(tests:find("github.event_name == 'push'", 1, true))
  assert.is_truthy(tests:find("github.event_name == 'pull_request'", 1, true))
  assert.is_truthy(tests:find("github.event_name == 'schedule'", 1, true))
  assert.is_nil(tests:find("pull_request_target", 1, true))
  assert.is_truthy(tests:find('minimum_neovim: "0.11.0"', 1, true))
  assert.is_truthy(tests:find('stable_neovim: "0.12.4"', 1, true))
  assert.is_truthy(tests:find('cache_rotation: "1"', 1, true))
  assert.is_truthy(tests:find("timeout_minutes: 30", 1, true))
  assert.is_truthy(tests:find("contents: read", 1, true))
  assert.is_nil(tests:find("secrets:", 1, true))

  assert.is_truthy(release:find("needs: Tests", 1, true))
  assert.is_truthy(
    release:find(
      "concurrency:\n      group: ${{ github.event.repository.name }}-release\n      cancel-in-progress: false",
      1,
      true
    )
  )
  assert.is_truthy(release:find("plugin_ci.yml@" .. SHARED_WORKFLOW_REF, 1, true))
  assert.is_truthy(release:find("github.event_name == 'push'", 1, true))
  assert.is_truthy(release:find("contents: write", 1, true))
  assert.is_truthy(release:find("pull-requests: write", 1, true))
  assert.is_truthy(release:find("RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}", 1, true))
  assert.is_truthy(release:find("is_production: true", 1, true))
  assert.is_truthy(release:find("docs: false", 1, true))

  assert.is_truthy(pr:find("validate_pr.yml@" .. SHARED_WORKFLOW_REF, 1, true))
  assert.is_truthy(pr:find("pull-requests: read", 1, true))
  assert.is_nil(pr:find("with:", 1, true))
  assert.is_nil(pr:find("secrets:", 1, true))

  assert.is_truthy(announcement:find("discord_announcement.yml@" .. SHARED_WORKFLOW_REF, 1, true))
  assert.is_truthy(announcement:find("github.event_name == 'release'", 1, true))
  assert.is_truthy(announcement:find("contents: read", 1, true))
  assert.is_truthy(announcement:find("DISCORD_WEBHOOK_URL: ${{ secrets.DISCORD_WEBHOOK_URL }}", 1, true))
end

T["CI-CONTRACT-02 exposes the standalone compatibility fingerprint command"] = function()
  local makefile = read_file(vim.fn.getcwd() .. "/Makefile")

  assert.is_truthy(makefile:find(".PHONY:", 1, true))
  assert.is_truthy(makefile:find("test-fingerprint", 1, true))
  assert.equals(
    "\ntest-fingerprint:\n\t@nvim -l tests/print_fingerprint.lua\n",
    make_target_body(makefile, "test-fingerprint")
  )
end

return T
