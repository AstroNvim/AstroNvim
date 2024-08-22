return function(plugin) -- automatically rebuild if not already built
  local astrocore = require "astrocore"
  astrocore.on_load("telescope.nvim", function()
    local ok, err = pcall(require("telescope").load_extension, "fzf")
    if not ok then
      local lib = plugin.dir .. "/build/libfzf." .. (vim.fn.has "win32" == 1 and "dll" or "so")
      if not (vim.uv or vim.loop).fs_stat(lib) then
        astrocore.notify("`telescope-fzf-native.nvim` not built. Rebuilding...", vim.log.levels.WARN)
        require("lazy")
          .build({ plugins = { plugin }, show = false })
          :wait(function() astrocore.notify "Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim." end)
      else
        astrocore.notify("Failed to load `telescope-fzf-native.nvim`:\n" .. err, vim.log.levels.ERROR)
      end
    end
  end)
end
