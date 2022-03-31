local colors = require "default_theme.colors"

local function generate_mode(bright, dim)
  return {
    a = { bg = bright, fg = colors.bg_1 },
    b = { bg = dim, fg = colors.bg_1 },
    c = { bg = colors.bg_1, fg = colors.fg },
  }
end

local default_theme = {
  normal = generate_mode(colors.blue, colors.blue_3),
  insert = generate_mode(colors.green, colors.green_1),
  command = generate_mode(colors.yellow_1, colors.yellow),
  visual = generate_mode(colors.purple, colors.purple_1),
  replace = generate_mode(colors.red_1, colors.red),
  inactive = generate_mode(colors.grey_7, colors.grey_6),
}

return default_theme
