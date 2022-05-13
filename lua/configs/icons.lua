local M = {}

function M.config()
  local status_ok, icons = pcall(require, "nvim-web-devicons")
  if status_ok then
    icons.set_icon(astronvim.user_plugin_opts("plugins.nvim-web-devicons", {
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
  end
end

return M
