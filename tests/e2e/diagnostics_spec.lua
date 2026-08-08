local MiniTest = require "mini.test"
local config = require "config"
local helpers = require "helpers"

local child
local T = MiniTest.new_set {
  hooks = {
    pre_case = function() child = nil end,
    post_case = function()
      helpers.stop_child(child)
      child = nil
    end,
  },
}

local highlight_groups = {
  "DiagnosticError",
  "DiagnosticWarn",
  "DiagnosticInfo",
  "DiagnosticHint",
  "DiagnosticSignError",
  "DiagnosticSignWarn",
  "DiagnosticSignInfo",
  "DiagnosticSignHint",
  "HeirlineNormal",
}

T["renders fixed diagnostics in the Heirline statusline and statuscolumn"] = function()
  child = helpers.start_child()
  helpers.wait_until(child, "vim.g.astronvim_test_ready == true", "VimEnter and LazyDone")

  child.lua [[
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.api.nvim_buf_set_name(bufnr, "diagnostics.txt")
    vim.bo[bufnr].filetype = "text"
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "error diagnostic line",
      "warning diagnostic line",
      "information diagnostic line",
      "hint diagnostic line",
    })

    local namespace = vim.api.nvim_create_namespace "astronvim-test-diagnostics"
    vim.g.astronvim_test_diagnostic_bufnr = bufnr
    vim.g.astronvim_test_diagnostic_namespace = namespace
    vim.g.astronvim_test_diagnostics_changed = false
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      buffer = bufnr,
      once = true,
      callback = function() vim.g.astronvim_test_diagnostics_changed = true end,
    })
    vim.diagnostic.set(namespace, bufnr, {
      { lnum = 0, col = 0, end_col = 5, severity = vim.diagnostic.severity.ERROR, message = "fixed error" },
      { lnum = 1, col = 0, end_col = 7, severity = vim.diagnostic.severity.WARN, message = "fixed warning" },
      { lnum = 2, col = 0, end_col = 11, severity = vim.diagnostic.severity.INFO, message = "fixed information" },
      { lnum = 3, col = 0, end_col = 4, severity = vim.diagnostic.severity.HINT, message = "fixed hint" },
    })
    vim.cmd "redrawstatus"
    vim.cmd "redraw"
  ]]

  helpers.wait_until(
    child,
    "vim.g.astronvim_test_diagnostics_changed and #vim.diagnostic.get(vim.g.astronvim_test_diagnostic_bufnr) == 4",
    "diagnostic state"
  )
  helpers.wait_until(
    child,
    "package.loaded.heirline ~= nil and vim.o.statusline:find('heirline', 1, true) ~= nil and vim.o.statuscolumn:find('heirline', 1, true) ~= nil",
    "Heirline statusline and statuscolumn"
  )

  local state = child.lua_get [[(function()
    local bufnr = vim.g.astronvim_test_diagnostic_bufnr
    local diagnostics = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr, { namespace = vim.g.astronvim_test_diagnostic_namespace })) do
      table.insert(diagnostics, {
        lnum = diagnostic.lnum,
        col = diagnostic.col,
        end_col = diagnostic.end_col,
        severity = diagnostic.severity,
        message = diagnostic.message,
      })
    end
    local highlights = {}
    for _, group in ipairs({
      "DiagnosticError",
      "DiagnosticWarn",
      "DiagnosticInfo",
      "DiagnosticHint",
      "DiagnosticSignError",
      "DiagnosticSignWarn",
      "DiagnosticSignInfo",
      "DiagnosticSignHint",
      "HeirlineNormal",
    }) do
      highlights[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
    end
    return {
      diagnostics = diagnostics,
      statusline = vim.api.nvim_eval_statusline(vim.o.statusline, { winid = 0, maxwidth = vim.o.columns }).str,
      statuscolumn = (function()
        local statuscolumn = {}
        for line = 1, 4 do
          statuscolumn[line] = vim.api.nvim_eval_statusline(vim.o.statuscolumn, {
            winid = 0,
            maxwidth = 20,
            use_statuscol_lnum = line,
          }).str
        end
        return statuscolumn
      end)(),
      highlights = highlights,
    }
  end)()]]

  assert.same({
    { lnum = 0, col = 0, end_col = 5, severity = vim.diagnostic.severity.ERROR, message = "fixed error" },
    { lnum = 1, col = 0, end_col = 7, severity = vim.diagnostic.severity.WARN, message = "fixed warning" },
    { lnum = 2, col = 0, end_col = 11, severity = vim.diagnostic.severity.INFO, message = "fixed information" },
    { lnum = 3, col = 0, end_col = 4, severity = vim.diagnostic.severity.HINT, message = "fixed hint" },
  }, state.diagnostics)
  assert.is_true(state.statusline:find("X 1 ! 1 i 1 ? 1", 1, true) ~= nil)
  assert.same(
    { "                1 X ", "                1 ! ", "                2 i ", "                3 ? " },
    state.statuscolumn
  )
  helpers.expect_screen(child, "diagnostics")
  helpers.expect_highlight_golden(
    child,
    config.highlights_dir .. "/diagnostics.txt",
    state.highlights,
    highlight_groups
  )
end

return T
