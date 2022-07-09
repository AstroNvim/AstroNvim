return {
  on_attach = astronvim.lsp.disable_formatting,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [astronvim.install.home .. "/lua"] = true,
          [astronvim.install.config .. "/lua"] = true,
        },
      },
    },
  },
}
