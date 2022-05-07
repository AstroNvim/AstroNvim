local M = {}

function M.setup()
  require("core.utils").vim_opts {
    g = {
      indentLine_enabled = 1,
      indent_blankline_show_trailing_blankline_indent = false,
      indent_blankline_show_first_indent_level = true,
      indent_blankline_use_treesitter = true,
      indent_blankline_show_current_context = true,
      indent_blankline_char = "▏",
      indent_blankline_buftype_exclude = {
        "nofile",
        "terminal",
        "lsp-installer",
        "lspinfo",
      },
      indent_blankline_filetype_exclude = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "neogitstatus",
        "NvimTree",
        "neo-tree",
        "Trouble",
      },
      indent_blankline_context_patterns = {
        "class",
        "return",
        "function",
        "method",
        "^if",
        "^while",
        "jsx_element",
        "^for",
        "^object",
        "^table",
        "block",
        "arguments",
        "if_statement",
        "else_clause",
        "jsx_element",
        "jsx_self_closing_element",
        "try_statement",
        "catch_clause",
        "import_statement",
        "operation_type",
      },
    },
  }
end

function M.config()
  local status_ok, indent_blankline = pcall(require, "indent_blankline")
  if status_ok then
    indent_blankline.setup(require("core.utils").user_plugin_opts("plugins.indent_blankline", {
      show_current_context = true,
      show_current_context_start = false,
    }))
  end
end

return M
