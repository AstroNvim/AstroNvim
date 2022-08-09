local status_ok, lspkind = pcall(require, "lspkind")
if not status_ok then return end
astronvim.lspkind = astronvim.user_plugin_opts("plugins.lspkind", {
  mode = "symbol",
  symbol_map = {
    Array = "",
    Boolean = "⊨",
    Class = "",
    Constructor = "",
    Key = "",
    Namespace = "",
    Null = "NULL",
    Number = "#",
    Object = "⦿",
    Package = "",
    Property = "",
    Reference = "",
    Snippet = "",
    String = "𝓐",
    TypeParameter = "",
    Unit = "",
  },
})
lspkind.init(astronvim.lspkind)
