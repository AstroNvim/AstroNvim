local status_ok, neotree = pcall(require, "neo-tree")
if not status_ok then return end
neotree.setup(astronvim.user_plugin_opts("plugins.neo-tree", {
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_diagnostics = false,
  default_component_configs = {
    indent = {
      padding = 0,
      with_expanders = false,
    },
    icon = {
      folder_closed = astronvim.get_icon "FolderClosed",
      folder_open = astronvim.get_icon "FolderOpen",
      folder_empty = astronvim.get_icon "FolderEmpty",
      default = astronvim.get_icon "DefaultFile",
    },
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
    width = 25,
    mappings = {
      ["o"] = "open",
    },
  },
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = true,
      hide_gitignored = false,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        "node_modules",
        "__pycache__",
      },
    },
    follow_current_file = true,
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,
  },
  git_status = {
    window = {
      position = "float",
    },
  },
  event_handlers = {
    { event = "neo_tree_buffer_enter", handler = function(_) vim.opt_local.signcolumn = "auto" end },
  },
}))
