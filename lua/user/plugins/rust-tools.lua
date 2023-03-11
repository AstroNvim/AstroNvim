return {
  {
     "simrat39/rust-tools.nvim",
        after = { "mason-lspconfig.nvim" },
        -- Is configured via the server_registration_override installed below!
        config = function()
          require("rust-tools").setup {
            server = astronvim.lsp.server_settings "rust_analyzer",
            tools = {
              inlay_hints = {
                parameter_hints_prefix = "  ",
                other_hints_prefix = "  ",
              },
            },
          }
        end,
    }
}
