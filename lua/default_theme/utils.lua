local M = {}

function M.parse_style(spec)
  if spec.style then
    for match in (spec.style .. ","):gmatch "(.-)," do
      spec[match] = true
    end
    spec.style = nil
  end
  return spec
end

return M
