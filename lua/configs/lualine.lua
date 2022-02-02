local M = {}

function M.config()
  local status_ok, lualine = pcall(require, "lualine")
  if not status_ok then
    return
  end

  local colors = {
    yellow = "#ecbe7b",
    yellow_1 = "#ff9640",
    grey = "#2c323c",
    white = "#bbc2cf",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67",
  }

  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand "%:t") ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
      local filepath = vim.fn.expand "%:p:h"
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
  }

  local config = {
    options = {
      disabled_filetypes = { "NvimTree", "dashboard", "Outline" },
      component_separators = "",
      section_separators = "",
      theme = {
        normal = { c = { fg = colors.white, bg = colors.grey } },
        inactive = { c = { fg = colors.white, bg = colors.grey } },
      },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  ins_left {
    function()
      return "▊"
    end,
    color = { fg = colors.blue },
    padding = { left = 0, right = 0 },
  }

  ins_left {
    "branch",
    icon = "",
    color = { fg = colors.violet, gui = "bold" },
    padding = { left = 2, right = 1 },
  }

  ins_left {
    "filetype",
    cond = conditions.buffer_not_empty,
    color = { fg = colors.magenta, gui = "bold" },
    padding = { left = 2, right = 1 },
  }

  ins_left {
    "diff",
    symbols = { added = " ", modified = "柳", removed = " " },
    diff_color = {
      added = { fg = colors.green },
      modified = { fg = colors.yellow_1 },
      removed = { fg = colors.red },
    },
    cond = conditions.hide_in_width,
    padding = { left = 2, right = 1 },
  }

  ins_left {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
    diagnostics_color = {
      color_error = { fg = colors.red },
      color_warn = { fg = colors.yellow },
      color_info = { fg = colors.cyan },
    },
    padding = { left = 2, right = 1 },
  }

  ins_left {
    function()
      return "%="
    end,
  }

  ins_right {
    function(msg)
      msg = msg or "Inactive"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        if type(msg) == "boolean" or #msg == 0 then
          return "Inactive"
        end
        return msg
      end
      local buf_ft = vim.bo.filetype
      local buf_client_names = {}

      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" then
          table.insert(buf_client_names, client.name)
        end
      end

      local formatters = require "core.utils"
      local supported_formatters = formatters.list_registered_formatters(buf_ft)
      vim.list_extend(buf_client_names, supported_formatters)

      local linters = require "core.utils"
      local supported_linters = linters.list_registered_linters(buf_ft)
      vim.list_extend(buf_client_names, supported_linters)

      return table.concat(buf_client_names, ", ")
    end,
    icon = " ",
    color = { gui = "none" },
    padding = { left = 0, right = 1 },
    cond = conditions.hide_in_width,
  }

  ins_right {
    function()
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then
        return " 綠TS"
      end
      return ""
    end,
    color = { fg = colors.green },
    padding = { left = 1, right = 0 },
    cond = conditions.hide_in_width,
  }

  ins_right {
    "location",
    padding = { left = 1, right = 1 },
  }

  ins_right {
    "progress",
    color = { fg = colors.fg, gui = "none" },
    padding = { left = 0, right = 0 },
  }

  ins_right {
    function()
      local current_line = vim.fn.line "."
      local total_lines = vim.fn.line "$"
      local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return chars[index]
    end,
    padding = { left = 1, right = 1 },
    color = { fg = colors.yellow, bg = colors.grey },
    cond = nil,
  }

  ins_right {
    function()
      return "▊"
    end,
    color = { fg = colors.blue },
    padding = { left = 1, right = 0 },
  }

  lualine.setup(config)
end

return M
