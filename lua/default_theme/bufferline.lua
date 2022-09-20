local bufferline = {
  -- Empty fill
  fill = { fg = C.fg, bg = C.grey_4 },

  -- Buffers
  background = { fg = C.grey_9, bg = C.grey_4 },
  buffer_selected = { fg = C.fg, bg = C.bg, bold = true, italic = false },
  buffer_visible = { fg = C.grey, bg = C.bg },

  -- Duplicate
  duplicate = { fg = C.grey, bg = C.grey_4 },
  duplicate_selected = { fg = C.grey, bg = C.bg, italic = true },
  duplicate_visible = { fg = C.grey, bg = C.bg },

  -- Tabs
  tab = { fg = C.fg, bg = C.grey },
  tab_close = { fg = C.red_4, bg = C.bg },
  tab_selected = { fg = C.black, bg = C.blue },

  -- Indicator
  indicator_selected = { fg = C.blue, bg = C.bg },
  indicator_visible = { fg = C.grey, bg = C.bg },

  -- Modified
  modified = { fg = C.red_4, bg = C.grey_4 },
  modified_selected = { fg = C.green_2, bg = C.bg },
  modified_visible = { fg = C.grey, bg = C.bg },

  -- Separators
  separator = { fg = C.grey_5, bg = C.grey_4 },
  separator_selected = { fg = C.grey, bg = C.bg },
  separator_visible = { fg = C.grey, bg = C.bg },
  tab_separator = { fg = C.grey_5, bg = C.grey },
  tab_separator_selected = { fg = C.grey_5, bg = C.blue },
  offset_separator = { fg = C.grey_5, bg = C.grey },

  -- Close buttons
  close_button = { fg = C.grey, bg = C.grey_4 },
  close_button_selected = { fg = C.red, bg = C.bg },
  close_button_visible = { fg = C.grey, bg = C.bg },

  -- Pick
  pick = { fg = C.red_1, bg = C.grey_4, bold = true, italic = true },
  pick_selected = { fg = C.red_1, bg = C.bg, bold = true, italic = true },
  pick_visible = { fg = C.red_1, bg = C.bg, bold = true, italic = true },

  -- Numbers
  numbers = { fg = C.grey_9, bg = C.grey_4 },
  numbers_selected = { fg = C.fg, bg = C.bg, bold = true, italic = false },
  numbers_visible = { fg = C.grey, bg = C.bg },

  -- Errors
  error = { fg = C.red, bg = C.grey_4 },
  error_selected = { fg = C.red_1, bg = C.bg, bold = true, italic = false },
  error_visible = { fg = C.red, bg = C.bg },
  error_diagnostic = { fg = C.red_1, bg = C.grey_4 },
  error_diagnostic_selected = { fg = C.red_1, bg = C.bg, bold = true },
  error_diagnostic_visible = { fg = C.red, bg = C.bg },

  -- Warnings
  warning = { fg = C.orange, bg = C.grey_4 },
  warning_selected = { fg = C.orange_1, bg = C.bg, bold = true, italic = false },
  warning_visible = { fg = C.orange, bg = C.bg },
  warning_diagnostic = { fg = C.orange, bg = C.grey_4 },
  warning_diagnostic_selected = { fg = C.orange_1, bg = C.bg, bold = true, italic = false },
  warning_diagnostic_visible = { fg = C.orange, bg = C.bg },

  -- Infos
  info = { fg = C.white_1, bg = C.grey_4 },
  info_selected = { fg = C.white_2, bg = C.bg, bold = true, italic = false },
  info_visible = { fg = C.white_1, bg = C.bg },
  info_diagnostic = { fg = C.white_1, bg = C.grey_4 },
  info_diagnostic_selected = { fg = C.white_2, bg = C.bg, bold = true, italic = false },
  info_diagnostic_visible = { fg = C.white_1, bg = C.bg },

  -- -- Hint
  hint = { fg = C.yellow, bg = C.grey_4 },
  hint_selected = { fg = C.yellow_1, bg = C.bg, bold = true, italic = false },
  hint_visible = { fg = C.yellow, bg = C.bg },
  hint_diagnostic = { fg = C.yellow, bg = C.grey_4 },
  hint_diagnostic_selected = { fg = C.yellow_1, bg = C.bg, bold = true, italic = false },
  hint_diagnostic_visible = { fg = C.yellow, bg = C.bg },

  -- Diagnostics
  diagnostic = { fg = C.grey_9, bg = C.grey_4 },
  diagnostic_selected = { fg = C.fg, bg = C.bg, bold = true, italic = false },
  diagnostic_visible = { fg = C.grey, bg = C.bg },
}

return bufferline
