local heirline = require "heirline"
if not astronvim.status then return end
local C = require "default_theme.colors"

local function setup_colors()
  local Normal = astronvim.get_hlgroup("Normal", { fg = C.fg, bg = C.bg })
  local Comment = astronvim.get_hlgroup("Comment", { fg = C.grey_2, bg = C.bg })
  local Error = astronvim.get_hlgroup("Error", { fg = C.red, bg = C.bg })
  local StatusLine = astronvim.get_hlgroup("StatusLine", { fg = C.fg, bg = C.grey_4 })
  local WinBar = astronvim.get_hlgroup("WinBar", { fg = C.grey_2, bg = C.bg })
  local WinBarNC = astronvim.get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
  local Conditional = astronvim.get_hlgroup("Conditional", { fg = C.purple_1, bg = C.grey_4 })
  local String = astronvim.get_hlgroup("String", { fg = C.green, bg = C.grey_4 })
  local TypeDef = astronvim.get_hlgroup("TypeDef", { fg = C.yellow, bg = C.grey_4 })
  local GitSignsAdd = astronvim.get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.grey_4 })
  local GitSignsChange = astronvim.get_hlgroup("GitSignsChange", { fg = C.orange_1, bg = C.grey_4 })
  local GitSignsDelete = astronvim.get_hlgroup("GitSignsDelete", { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticError = astronvim.get_hlgroup("DiagnosticError", { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticWarn = astronvim.get_hlgroup("DiagnosticWarn", { fg = C.orange_1, bg = C.grey_4 })
  local DiagnosticInfo = astronvim.get_hlgroup("DiagnosticInfo", { fg = C.white_2, bg = C.grey_4 })
  local DiagnosticHint = astronvim.get_hlgroup("DiagnosticHint", { fg = C.yellow_1, bg = C.grey_4 })
  local HeirlineInactive = astronvim.get_hlgroup("HeirlineInactive", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("inactive", C.grey_7)
  local HeirlineNormal = astronvim.get_hlgroup("HeirlineNormal", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("normal", C.blue)
  local HeirlineInsert = astronvim.get_hlgroup("HeirlineInsert", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("insert", C.green)
  local HeirlineVisual = astronvim.get_hlgroup("HeirlineVisual", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("visual", C.purple)
  local HeirlineReplace = astronvim.get_hlgroup("HeirlineReplace", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("replace", C.red_1)
  local HeirlineCommand = astronvim.get_hlgroup("HeirlineCommand", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("command", C.yellow_1)
  local HeirlineTerminal = astronvim.get_hlgroup("HeirlineTerminal", { fg = nil }).fg
    or astronvim.status.hl.lualine_mode("inactive", HeirlineInsert)

  local colors = astronvim.user_plugin_opts("heirline.colors", {
    tab_fg = Normal.fg,
    tab_bg = Normal.bg,
    tab_inactive_fg = Comment.fg,
    tab_visible_bg = Normal.bg,
    close_fg = Error.fg,
    fg = StatusLine.fg,
    bg = StatusLine.bg,
    section_fg = StatusLine.fg,
    section_bg = StatusLine.bg,
    git_branch_fg = Conditional.fg,
    treesitter_fg = String.fg,
    scrollbar = TypeDef.fg,
    git_added = GitSignsAdd.fg,
    git_changed = GitSignsChange.fg,
    git_removed = GitSignsDelete.fg,
    diag_ERROR = DiagnosticError.fg,
    diag_WARN = DiagnosticWarn.fg,
    diag_INFO = DiagnosticInfo.fg,
    diag_HINT = DiagnosticHint.fg,
    winbar_fg = WinBar.fg,
    winbar_bg = WinBar.bg,
    winbarnc_fg = WinBarNC.fg,
    winbarnc_bg = WinBarNC.bg,
    inactive = HeirlineInactive,
    normal = HeirlineNormal,
    insert = HeirlineInsert,
    visual = HeirlineVisual,
    replace = HeirlineReplace,
    command = HeirlineCommand,
    terminal = HeirlineTerminal,
  })

  for _, section in ipairs {
    "git_branch",
    "file_info",
    "git_diff",
    "diagnostics",
    "lsp",
    "macro_recording",
    "cmd_info",
    "treesitter",
    "nav",
  } do
    if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
    if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
  end
  return colors
end

--- Make a list of buffers, rendering all listed buffers
---@param component table
---@return table
astronvim.status.utils.make_buflist = function(component)
  return require("heirline.utils").make_buflist(
    component,
    { provider = astronvim.get_icon "ArrowLeft" .. " ", hl = { fg = "tab_inactive_fg", bg = "bg" } },
    { provider = astronvim.get_icon "ArrowRight" .. " ", hl = { fg = "tab_inactive_fg", bg = "bg" } },
    function() return vim.t.bufs end,
    false -- disable internal caching
  )
end

--- Alias to require("heirline.utils").make_tablist
astronvim.status.utils.make_tablist = require("heirline.utils").make_tablist

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  { -- statusline
    hl = { fg = "fg", bg = "bg" },
    astronvim.status.component.mode(),
    astronvim.status.component.git_branch(),
    astronvim.status.component.file_info { filetype = {}, filename = false, file_modified = false },
    astronvim.status.component.git_diff(),
    astronvim.status.component.diagnostics(),
    astronvim.status.component.fill(),
    astronvim.status.component.cmd_info(),
    astronvim.status.component.fill(),
    astronvim.status.component.lsp(),
    astronvim.status.component.treesitter(),
    astronvim.status.component.nav(),
    astronvim.status.component.mode { surround = { separator = "right" } },
  },
  { -- winbar
    static = {
      disabled = {
        buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
        filetype = { "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" },
      },
    },
    init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
    fallthrough = false,
    {
      condition = function(self)
        return vim.opt.diff:get() or astronvim.status.condition.buffer_matches(self.disabled or {})
      end,
      init = function() vim.opt_local.winbar = nil end,
    },
    astronvim.status.component.file_info {
      condition = function() return not astronvim.status.condition.is_active() end,
      unique_path = {},
      file_icon = { hl = false },
      hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" },
      surround = false,
      update = "BufEnter",
    },
    astronvim.status.component.breadcrumbs { hl = { fg = "winbar_fg", bg = "winbar_bg" } },
  },
  { -- bufferline
    { -- file tree padding
      condition = function(self)
        self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
        return vim.tbl_contains({ "neo-tree", "NvimTree" }, vim.bo[vim.api.nvim_win_get_buf(self.winid)].filetype)
      end,
      provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid)) end,
      hl = { bg = "bg" },
    },
    astronvim.status.utils.make_buflist { -- bufferlist
      astronvim.status.component.file_info {
        file_icon = { padding = { left = 1 } },
        unique_path = { hl = { fg = "winbarnc_fg" } },
        close_button = {
          hl = { fg = "close_fg" },
          padding = { left = 1, right = 1 },
          on_click = {
            callback = function(_, minwid) astronvim.close_buf(minwid) end,
            minwid = function(self) return self.bufnr end,
            name = "heirline_tabline_close_buffer_callback",
          },
        },
        padding = { left = 1, right = 1 },
        hl = function(self)
          return {
            fg = self.is_active and "tab_fg" or "tab_inactive_fg",
            bold = self.is_active,
            italic = self.is_active,
          }
        end,
        on_click = {
          callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
          minwid = function(self) return self.bufnr end,
          name = "heirline_tabline_buffer_callback",
        },
        surround = {
          separator = "tab",
          condition = false,
          color = function(self)
            return { main = (self.is_active or self.is_visible) and "tab_bg" or "bg", left = "bg", right = "bg" }
          end,
        },
      },
    },
    { -- tab list
      condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
      astronvim.status.component.fill(),
      astronvim.status.utils.make_tablist {
        provider = astronvim.status.provider.tabnr(),
        hl = function(self) return self.is_active and "TabLineSel" or "TabLine" end,
      },
      {
        provider = astronvim.status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
        hl = { fg = "close_fg" },
        on_click = { callback = astronvim.close_tab, name = "heirline_tabline_close_tab_callback" },
      },
    },
  },
})
heirline.setup(heirline_opts[1], heirline_opts[2], heirline_opts[3])

local augroup = vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "AstroColorScheme",
  group = augroup,
  desc = "Refresh heirline colors",
  callback = function() require("heirline.utils").on_colorscheme(setup_colors()) end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "HeirlineInitWinbar",
  group = augroup,
  desc = "Disable winbar for some filetypes",
  callback = function()
    if vim.opt.diff:get() or astronvim.status.condition.buffer_matches(require("heirline").winbar.disabled or {}) then
      vim.opt_local.winbar = nil
    end
  end,
})
