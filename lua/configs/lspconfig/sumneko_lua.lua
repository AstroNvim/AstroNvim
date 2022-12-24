return {
  settings = {
    Lua = {
      telemetry = { enable = false },
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim", "astronvim", "astronvim_installation", "bit" } },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          astronvim.install.home .. "/lua",
          astronvim.install.config .. "/lua",
        },
      },
    },
  },
}
