return function(plugin, opts)
  local ts = require(plugin.main)

  if vim.fn.executable "git" == 0 then opts.ensure_installed = nil end

  -- disable all treesitter modules on large buffer
  for _, module in ipairs(ts.available_modules()) do
    if not opts[module] then opts[module] = {} end
    local module_opts = opts[module]
    local disable = module_opts.disable
    module_opts.disable = function(lang, bufnr)
      return require("astrocore.buffer").is_large(bufnr)
        or (type(disable) == "table" and vim.tbl_contains(disable, lang))
        or (type(disable) == "function" and disable(lang, bufnr))
    end
  end

  ts.setup(opts)
end
