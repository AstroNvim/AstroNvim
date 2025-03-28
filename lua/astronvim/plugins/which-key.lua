return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec", "disable.ft", "disable.bt" },
  opts = function(_, opts)
    if not opts.icons then opts.icons = {} end
    opts.icons.group = ""
    opts.icons.rules = false
    opts.icons.separator = "-"
    if vim.g.icons_enabled == false then
      opts.icons.breadcrumb = ">"
      opts.icons.group = "+"
      opts.icons.keys = {
        Up = "Up",
        Down = "Down",
        Left = "Left",
        Right = "Right",
        C = "Ctrl+",
        M = "Alt+",
        D = "Cmd+",
        S = "Shift+",
        CR = "Enter",
        Esc = "Esc",
        ScrollWheelDown = "ScrollDown",
        ScrollWheelUp = "ScrollUp",
        NL = "Enter",
        BS = "Backspace",
        Space = "Space",
        Tab = "Tab",
        F1 = "F1",
        F2 = "F2",
        F3 = "F3",
        F4 = "F4",
        F5 = "F5",
        F6 = "F6",
        F7 = "F7",
        F8 = "F8",
        F9 = "F9",
        F10 = "F10",
        F11 = "F11",
        F12 = "F12",
      }
    end
  end,
}
