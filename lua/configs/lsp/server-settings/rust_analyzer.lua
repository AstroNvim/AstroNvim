local opts = {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        loadOutDirsFromCheck = true,
      },
      checkOnSave = {
        command = "clippy",
      },
      experimental = {
        procAttrMacros = true,
      },
    },
  },
}

return opts
