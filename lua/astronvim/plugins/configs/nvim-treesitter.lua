return function(plugin, opts)
  local ts = require(plugin.main)

  -- HACK: force install all parsers bundled with neovim
  -- TODO: remove when nvim-treesitter v1 released
  if opts.ensure_installed ~= "all" then
    opts.ensure_installed = require("astrocore").list_insert_unique(
      opts.ensure_installed,
      { "bash", "c", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }
    )
  end

  -- disable all treesitter modules on large buffer
  if vim.tbl_get(require("astrocore").config, "features", "large_buf") then
    for _, module in ipairs(ts.available_modules()) do
      if not opts[module] then opts[module] = {} end
      local module_opts = opts[module]
      local disable = module_opts.disable
      module_opts.disable = function(lang, bufnr)
        return vim.b[bufnr].large_buf
          or (type(disable) == "table" and vim.tbl_contains(disable, lang))
          or (type(disable) == "function" and disable(lang, bufnr))
      end
    end
  end

  ts.setup(opts)
end
