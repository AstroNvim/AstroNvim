return function(_, opts)
  local heirline = require "heirline"

  local function setup_colors()
    local colors = require("astroui").config.status.setup_colors()

    for _, section in ipairs {
      "git_branch",
      "file_info",
      "git_diff",
      "diagnostics",
      "lsp",
      "macro_recording",
      "mode",
      "cmd_info",
      "treesitter",
      "nav",
    } do
      if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
      if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
    end

    return colors
  end

  heirline.load_colors(setup_colors())
  heirline.setup(opts)

  local augroup = vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AstroColorScheme",
    group = augroup,
    desc = "Refresh heirline colors",
    callback = function() require("heirline.utils").on_colorscheme(setup_colors()) end,
  })
end
