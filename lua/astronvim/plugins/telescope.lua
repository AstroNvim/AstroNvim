return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
    {
      "astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local utils = require "astrocore.utils"
        local is_available = utils.is_available
        if is_available "telescope.nvim" then
          maps.n["<leader>f"] = opts._map_section.f
          maps.n["<leader>g"] = opts._map_section.g
          maps.n["<leader>gb"] =
            { function() require("telescope.builtin").git_branches { use_file_path = true } end, desc = "Git branches" }
          maps.n["<leader>gc"] = {
            function() require("telescope.builtin").git_commits { use_file_path = true } end,
            desc = "Git commits (repository)",
          }
          maps.n["<leader>gC"] = {
            function() require("telescope.builtin").git_bcommits { use_file_path = true } end,
            desc = "Git commits (current file)",
          }
          maps.n["<leader>gt"] =
            { function() require("telescope.builtin").git_status { use_file_path = true } end, desc = "Git status" }
          maps.n["<leader>f<CR>"] =
            { function() require("telescope.builtin").resume() end, desc = "Resume previous search" }
          maps.n["<leader>f'"] = { function() require("telescope.builtin").marks() end, desc = "Find marks" }
          maps.n["<leader>f/"] = {
            function() require("telescope.builtin").current_buffer_fuzzy_find() end,
            desc = "Find words in current buffer",
          }
          maps.n["<leader>fa"] = {
            function()
              local cwd = vim.fn.stdpath "config" .. "/.."
              local search_dirs = {}
              for _, dir in ipairs(astronvim.supported_configs) do -- search all supported config locations
                if dir == astronvim.install.home then dir = dir .. "/lua/user" end -- don't search the astronvim core files
                if vim.fn.isdirectory(dir) == 1 then table.insert(search_dirs, dir) end -- add directory to search if exists
              end
              if vim.tbl_isempty(search_dirs) then -- if no config folders found, show warning
                utils.notify("No user configuration files found", vim.log.levels.WARN)
              else
                if #search_dirs == 1 then cwd = search_dirs[1] end -- if only one directory, focus cwd
                require("telescope.builtin").find_files {
                  prompt_title = "Config Files",
                  search_dirs = search_dirs,
                  cwd = cwd,
                } -- call telescope
              end
            end,
            desc = "Find AstroNvim config files",
          }
          maps.n["<leader>fb"] = { function() require("telescope.builtin").buffers() end, desc = "Find buffers" }
          maps.n["<leader>fc"] =
            { function() require("telescope.builtin").grep_string() end, desc = "Find word under cursor" }
          maps.n["<leader>fC"] = { function() require("telescope.builtin").commands() end, desc = "Find commands" }
          maps.n["<leader>ff"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" }
          maps.n["<leader>fF"] = {
            function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
            desc = "Find all files",
          }
          maps.n["<leader>fh"] = { function() require("telescope.builtin").help_tags() end, desc = "Find help" }
          maps.n["<leader>fk"] = { function() require("telescope.builtin").keymaps() end, desc = "Find keymaps" }
          maps.n["<leader>fm"] = { function() require("telescope.builtin").man_pages() end, desc = "Find man" }
          if is_available "nvim-notify" then
            maps.n["<leader>fn"] =
              { function() require("telescope").extensions.notify.notify() end, desc = "Find notifications" }
          end
          maps.n["<leader>fo"] = { function() require("telescope.builtin").oldfiles() end, desc = "Find history" }
          maps.n["<leader>fr"] = { function() require("telescope.builtin").registers() end, desc = "Find registers" }
          maps.n["<leader>ft"] =
            { function() require("telescope.builtin").colorscheme { enable_preview = true } end, desc = "Find themes" }
          maps.n["<leader>fw"] = { function() require("telescope.builtin").live_grep() end, desc = "Find words" }
          maps.n["<leader>fW"] = {
            function()
              require("telescope.builtin").live_grep {
                additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
              }
            end,
            desc = "Find words in all files",
          }
          maps.n["<leader>l"] = opts._map_section.l
          maps.n["<leader>ls"] = {
            function()
              local aerial_avail, _ = pcall(require, "aerial")
              if aerial_avail then
                require("telescope").extensions.aerial.aerial()
              else
                require("telescope.builtin").lsp_document_symbols()
              end
            end,
            desc = "Search symbols",
          }
        end
      end,
    },
    {
      "astrolsp",
      opts = function(_, opts)
        local maps = opts.mappings
        if vim.fn.exists ":Telescope" > 0 or pcall(require, "telescope") then -- setup telescope mappings if available
          maps.n["<leader>lD"] =
            { function() require("telescope.builtin").diagnostics() end, desc = "Search diagnostics" }
          if maps.n.gd then maps.n.gd[1] = function() require("telescope.builtin").lsp_definitions() end end
          if maps.n.gI then maps.n.gI[1] = function() require("telescope.builtin").lsp_implementations() end end
          if maps.n.gr then maps.n.gr[1] = function() require("telescope.builtin").lsp_references() end end
          if maps.n["<leader>lR"] then
            maps.n["<leader>lR"][1] = function() require("telescope.builtin").lsp_references() end
          end
          if maps.n.gT then maps.n.gT[1] = function() require("telescope.builtin").lsp_type_definitions() end end
          if maps.n["<leader>lG"] then
            maps.n["<leader>lG"][1] = function()
              vim.ui.input({ prompt = "Symbol Query: " }, function(query)
                if query then require("telescope.builtin").lsp_workspace_symbols { query = query } end
              end)
            end
          end
        end
      end,
    },
  },
  cmd = "Telescope",
  opts = function()
    local actions = require "telescope.actions"
    local get_icon = require("astroui").get_icon
    return {
      defaults = {
        git_worktrees = require("astrocore").config.git_worktrees,
        prompt_prefix = get_icon("Selected", 1),
        selection_caret = get_icon("Selected", 1),
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = { q = actions.close },
        },
      },
    }
  end,
  config = require "astronvim.plugins.configs.telescope",
}
