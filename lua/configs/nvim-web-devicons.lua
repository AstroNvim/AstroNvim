require("nvim-web-devicons").set_default_icon(astronvim.get_icon "DefaultFile", "#6d8086", "66")
require("nvim-web-devicons").set_icon(astronvim.user_plugin_opts("plugins.nvim-web-devicons", {
  deb = { icon = "", name = "Deb" },
  lock = { icon = "", name = "Lock" },
  mp3 = { icon = "", name = "Mp3" },
  mp4 = { icon = "", name = "Mp4" },
  out = { icon = "", name = "Out" },
  ["robots.txt"] = { icon = "ﮧ", name = "Robots" },
  ttf = { icon = "", name = "TrueTypeFont" },
  rpm = { icon = "", name = "Rpm" },
  woff = { icon = "", name = "WebOpenFontFormat" },
  woff2 = { icon = "", name = "WebOpenFontFormat2" },
  xz = { icon = "", name = "Xz" },
  zip = { icon = "", name = "Zip" },
}))
