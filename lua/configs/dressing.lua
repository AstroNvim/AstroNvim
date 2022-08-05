local status_ok, dressing = pcall(require, "dressing")
if not status_ok then return end
-- TODO: Deprecate user ui options table with v2
local ui_opts = astronvim.user_plugin_opts("ui", { nui_input = true, telescope_select = true })
dressing.setup(astronvim.user_plugin_opts("plugins.dressing", {
  input = {
    enabled = ui_opts.nui_input,
    default_prompt = "➤ ",
    winhighlight = "Normal:Normal,NormalNC:Normal",
  },
  select = {
    enabled = ui_opts.telescope_select,
    backend = { "telescope", "builtin" },
    builtin = { winhighlight = "Normal:Normal,NormalNC:Normal" },
  },
}))
