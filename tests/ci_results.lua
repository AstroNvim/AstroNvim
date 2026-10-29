local M = {}

local function case_result(case)
  local execution = case.exec or {}
  local failures = execution.fails or {}
  local notes = execution.notes or {}
  local status = #failures == 0 and (#notes == 0 and "passed" or "passed_with_notes") or "failed"
  return {
    id = table.concat(case.desc or {}, " | "),
    status = status,
    state = execution.state,
    failures = failures,
    notes = notes,
  }
end

function M.write(cases, path)
  if not path or path == "" then return end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local results = {}
  for _, case in ipairs(cases or {}) do
    table.insert(results, case_result(case))
  end
  local file = assert(io.open(path, "wb"))
  assert(file:write(vim.json.encode(results), "\n"))
  file:close()
end

return M
