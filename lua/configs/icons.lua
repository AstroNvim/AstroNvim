local M = {}

function M.config()
  local status_ok, icons = pcall(require, "nvim-web-devicons")
  if not status_ok then
    return
  end

  local colors = {
    c = "#519aba",
    css = "#61afef",
    deb = "#a1b7ee",
    docker = "#384d54",
    html = "#de8c92",
    js = "#ebcb8b",
    kt = "#7bc99c",
    lock = "#c4c720",
    lua = "#51a0cf",
    mp3 = "#d39ede",
    mp4 = "#9ea3de",
    out = "#abb2bf",
    py = "#a3b8ef",
    robot = "#abb2bf",
    toml = "#39bf39",
    ts = "#519aba",
    ttf = "#abb2bf",
    rb = "#ff75a0",
    rpm = "#fca2aa",
    woff = "#abb2bf",
    woff2 = "#abb2bf",
    zip = "#f9d71c",
    jsx = "#519ab8",
    vue = "#7bc99c",
    rs = "#dea584",
    png = "#c882e7",
    jpeg = "#c882e7",
    jpg = "#c882e7",
  }

  icons.set_icon(require("core.utils").user_plugin_opts("plugins.nvim-web-devicons", {
    c = {
      icon = "",
      color = colors.c,
      name = "c",
    },
    css = {
      icon = "",
      color = colors.css,
      name = "css",
    },
    deb = {
      icon = "",
      color = colors.deb,
      name = "deb",
    },
    Dockerfile = {
      icon = "",
      color = colors.docker,
      name = "Dockerfile",
    },
    html = {
      icon = "",
      color = colors.html,
      name = "html",
    },
    js = {
      icon = "",
      color = colors.js,
      name = "js",
    },
    kt = {
      icon = "󱈙",
      color = colors.kt,
      name = "kt",
    },
    lock = {
      icon = "",
      color = colors.lock,
      name = "lock",
    },
    lua = {
      icon = "",
      color = colors.lua,
      name = "lua",
    },
    mp3 = {
      icon = "",
      color = colors.mp3,
      name = "mp3",
    },
    mp4 = {
      icon = "",
      color = colors.mp4,
      name = "mp4",
    },
    out = {
      icon = "",
      color = colors.out,
      name = "out",
    },
    py = {
      icon = "",
      color = colors.py,
      name = "py",
    },
    ["robots.txt"] = {
      icon = "ﮧ",
      color = colors.robot,
      name = "robots",
    },
    toml = {
      icon = "",
      color = colors.toml,
      name = "toml",
    },
    ts = {
      icon = "",
      color = colors.ts,
      name = "ts",
    },
    ttf = {
      icon = "",
      color = colors.ttf,
      name = "TrueTypeFont",
    },
    rb = {
      icon = "",
      color = colors.rb,
      name = "rb",
    },
    rpm = {
      icon = "",
      color = colors.rpm,
      name = "rpm",
    },
    vue = {
      icon = "﵂",
      color = colors.vue,
      name = "vue",
    },
    woff = {
      icon = "",
      color = colors.woff,
      name = "WebOpenFontFormat",
    },
    woff2 = {
      icon = "",
      color = colors.woff2,
      name = "WebOpenFontFormat2",
    },
    xz = {
      icon = "",
      color = colors.zip,
      name = "xz",
    },
    zip = {
      icon = "",
      color = colors.zip,
      name = "zip",
    },
    jsx = {
      icon = "ﰆ",
      color = colors.jsx,
      name = "jsx",
    },
    rust = {
      icon = "",
      color = colors.rs,
      name = "rs",
    },
    jpg = {
      icon = "",
      color = colors.jpg,
      name = "jpg",
    },
    png = {
      icon = "",
      color = colors.png,
      name = "png",
    },
    jpeg = {
      icon = "",
      color = colors.jpeg,
      name = "jpeg",
    },
  }))
end

return M
