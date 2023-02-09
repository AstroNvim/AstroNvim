return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "Neotree",
  init = function() vim.g.neo_tree_remove_legacy_commands = true end,
  opts = function()
    -- TODO move after neo-tree improves (https://github.com/nvim-neo-tree/neo-tree.nvim/issues/707)
    local global_commands = {
      system_open = function(state) astronvim.system_open(state.tree:get_node():get_id()) end,
      parent_or_close = function(state)
        local node = state.tree:get_node()
        if (node.type == "directory" or node:has_children()) and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end
      end,
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" or node:has_children() then
          if not node:is_expanded() then -- if unexpanded, expand
            state.commands.toggle_node(state)
          else -- if expanded and has children, seleect the next child
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        else -- if not a directory just open it
          state.commands.open(state)
        end
      end,
    }
    return {
      close_if_last_window = true,
      source_selector = {
        winbar = true,
        content_layout = "center",
        tab_labels = {
          filesystem = astronvim.get_icon "FolderClosed" .. " File",
          buffers = astronvim.get_icon "DefaultFile" .. " Bufs",
          git_status = astronvim.get_icon "Git" .. " Git",
          diagnostics = astronvim.get_icon "Diagnostic" .. " Diagnostic",
        },
      },
      default_component_configs = {
        indent = { padding = 0 },
        icon = {
          folder_closed = astronvim.get_icon "FolderClosed",
          folder_open = astronvim.get_icon "FolderOpen",
          folder_empty = astronvim.get_icon "FolderEmpty",
          default = astronvim.get_icon "DefaultFile",
        },
        modified = { symbol = astronvim.get_icon "FileModified" },
        git_status = {
          symbols = {
            added = astronvim.get_icon "GitAdd",
            deleted = astronvim.get_icon "GitDelete",
            modified = astronvim.get_icon "GitChange",
            renamed = astronvim.get_icon "GitRenamed",
            untracked = astronvim.get_icon "GitUntracked",
            ignored = astronvim.get_icon "GitIgnored",
            unstaged = astronvim.get_icon "GitUnstaged",
            staged = astronvim.get_icon "GitStaged",
            conflict = astronvim.get_icon "GitConflict",
          },
        },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = false, -- disable space until we figure out which-key disabling
          ["[b"] = "prev_source",
          ["]b"] = "next_source",
          o = "open",
          O = "system_open",
          h = "parent_or_close",
          l = "child_or_open",
        },
      },
      filesystem = {
        follow_current_file = true,
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        commands = global_commands,
      },
      buffers = { commands = global_commands },
      git_status = { commands = global_commands },
      event_handlers = {
        { event = "neo_tree_buffer_enter", handler = function(_) vim.opt_local.signcolumn = "auto" end },
      },
    }
  end,
}
