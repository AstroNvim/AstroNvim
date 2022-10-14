local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then return end
npairs.setup(astronvim.user_plugin_opts("plugins.nvim-autopairs", {
  check_ts = true,
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
    java = false,
  },
  disable_filetype = { "TelescopePrompt", "spectre_panel" },
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
    offset = 0,
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "PmenuSel",
    highlight_grey = "LineNr",
  },
}))

if not vim.g.autopairs_enabled then npairs.disable() end

local rules = astronvim.user_plugin_opts("nvim-autopairs").add_rules
if vim.tbl_contains({ "function", "table" }, type(rules)) then
  npairs.add_rules(type(rules) == "function" and rules(npairs) or rules)
end

local cmp_status_ok, cmp = pcall(require, "cmp")
if cmp_status_ok then
  cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { map_char = { tex = "" } })
end
