local M = {}

M.config = function()
  local present, alpha = pcall(require, "alpha")
  if not present then
    return
  end

  local kind = require "user.configs.lsp_kind"

  local header = {
    type = "text",
    val = require("user.plugins.banners").dashboard(),
    opts = {
      position = "center",
      hl = "Comment",
    },
  }

  local plugins = ""
  local date = ""
  if vim.fn.has "linux" == 1 or vim.fn.has "mac" == 1 then
    local handle = io.popen 'fd -d 2 . $HOME"/.local/share/lunarvim/site/pack/packer" | grep pack | wc -l | tr -d "\n" '
    plugins = handle:read "*a"
    handle:close()

    local thingy = io.popen 'echo "$(date +%a) $(date +%d) $(date +%b)" | tr -d "\n"'
    date = thingy:read "*a"
    thingy:close()
    plugins = plugins:gsub("^%s*(.-)%s*$", "%1")
  else
    plugins = "N/A"
    date = "  whatever "
  end

  local plugin_count = {
    type = "text",
    val = "└─ " .. kind.cmp_kind.Module .. " " .. plugins .. " plugins in total ─┘",
    opts = {
      position = "center",
      hl = "String",
    },
  }

  local heading = {
    type = "text",
    val = "┌─ " .. kind.icons.calendar .. " Today is " .. date .. " ─┐",
    opts = {
      position = "center",
      hl = "String",
    },
  }

  local fortune = require "alpha.fortune"()
  -- fortune = fortune:gsub("^%s+", ""):gsub("%s+$", "")
  local footer = {
    type = "text",
    val = fortune,
    opts = {
      position = "center",
      hl = "Comment",
      hl_shortcut = "Comment",
    },
  }

  local function button(sc, txt, keybind)
    local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

    local opts = {
      position = "center",
      text = txt,
      shortcut = sc,
      cursor = 5,
      width = 24,
      align_shortcut = "right",
      hl_shortcut = "Number",
      hl = "Function",
    }
    if keybind then
      opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
    end

    return {
      type = "button",
      val = txt,
      on_press = function()
        local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
        vim.api.nvim_feedkeys(key, "normal", false)
      end,
      opts = opts,
    }
  end

  local buttons = {
    type = "group",
    val = {
      button("f", " " .. kind.cmp_kind.Folder .. " Explore", ":Telescope find_files<CR>"),
      button("e", " " .. kind.cmp_kind.File .. " New file", ":ene <BAR> startinsert <CR>"),
      button("s", " " .. kind.icons.magic .. " Restore", ":lua require('persistence').load()<cr>"),
      -- button(
      --   "g",
      --   " " .. kind.icons.git .. " Git Status",
      --   ":lua require('lvim.core.terminal')._exec_toggle({cmd = 'lazygit', count = 1, direction = 'float'})<CR>"
      -- ),
      button("r", " " .. kind.icons.clock .. " Recents", ":Telescope oldfiles<CR>"),
      button("c", " " .. kind.icons.settings .. " Config", ":e ~/.config/lvim/config.lua<CR>"),
      button("q", " " .. kind.icons.exit .. " Quit", ":q<CR>"),
    },
    opts = {
      spacing = 1,
    },
  }

-- default.buttons = {
--    type = "group",
--    val = {
--       button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
--       button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
--       button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
--       button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
--       button("SPC t h", "  Themes  ", ":Telescope themes<CR>"),
--       button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
--    },
--    opts = {
--       spacing = 1,
--    },
-- }

  local section = {
    header = header,
    buttons = buttons,
    plugin_count = plugin_count,
    heading = heading,
    footer = footer,
  }

  local opts = {
    layout = {
      { type = "padding", val = 1 },
      section.header,
      { type = "padding", val = 2 },
      section.heading,
      section.plugin_count,
      { type = "padding", val = 1 },
      -- section.top_bar,
      section.buttons,
      -- section.bot_bar,
      -- { type = "padding", val = 1 },
      section.footer,
    },
    opts = {
      margin = 5,
    },
  }
  alpha.setup(opts)
end

return M

------------ other ---- 
-- local present, alpha = pcall(require, "alpha")
--
-- if not present then
--    return
-- end
--
-- local function button(sc, txt, keybind)
--    local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")
--
--    local opts = {
--       position = "center",
--       text = txt,
--       shortcut = sc,
--       cursor = 5,
--       width = 36,
--       align_shortcut = "right",
--       hl = "AlphaButtons",
--    }
--
--    if keybind then
--       opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
--    end
--
--    return {
--       type = "button",
--       val = txt,
--       on_press = function()
--          local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
--          vim.api.nvim_feedkeys(key, "normal", false)
--       end,
--       opts = opts,
--    }
-- end
--
-- local default = {}
--
-- default.ascii = {
--    "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
--    "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
--    "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
--    "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
--    "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
--    "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
--    "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
--    " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
--    " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
--    "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
--    "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
-- }
--
-- default.header = {
--    type = "text",
--    val = default.ascii,
--    opts = {
--       position = "center",
--       hl = "AlphaHeader",
--    },
-- }
--
-- default.buttons = {
--    type = "group",
--    val = {
--       button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
--       button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
--       button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
--       button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
--       button("SPC t h", "  Themes  ", ":Telescope themes<CR>"),
--       button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
--    },
--    opts = {
--       spacing = 1,
--    },
-- }
--
-- local M = {}
--
-- M.setup = function(override_flag)
--    if override_flag then
--       default = require("core.utils").tbl_override_req("alpha", default)
--    end
--    alpha.setup {
--       layout = {
--          { type = "padding", val = 9 },
--          default.header,
--          { type = "padding", val = 2 },
--          default.buttons,
--       },
--       opts = {},
--    }
-- end
--
-- return M
