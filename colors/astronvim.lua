for key, _ in pairs(package.loaded) do
  if key:find "astronvim.*" then package.loaded[key] = nil end
end

require "astronvim_theme"
