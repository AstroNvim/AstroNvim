local status_ok, colorizer = pcall(require, "colorizer")
if status_ok then
  local colorizer_opts = astronvim.user_plugin_opts("plugins.colorizer", {
    { "*" },
    {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- "Name" codes like Blue
      RRGGBBAA = false, -- #RRGGBBAA hex codes
      rgb_fn = false, -- CSS rgb() and rgba() functions
      hsl_fn = false, -- CSS hsl() and hsla() functions
      css = false, -- Enable all css features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      mode = "background", -- Set the display mode
    },
  })
  colorizer.setup(colorizer_opts[1], colorizer_opts[2])
end
