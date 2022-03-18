# Advanced User Configuration

For basic usage check out the main [README](https://github.com/kabinspace/AstroVim/)

## Available User Configuration Tables

| `init.lua` table key           | Expected Format                    | Use Case                                                                            |
| ------------------------------ | ---------------------------------- | ----------------------------------------------------------------------------------- |
| `colorscheme`                  | `string`                           | The colorscheme to be set                                                           |
| `default_theme`                | `table` or `function(table)...end` | Set available options for the default theme                                         |
| `diagnostics`                  | `table` or `function(table)...end` | Modify the default vim diagnostics options                                          |
| `enabled`                      | `table` or `function(table)...end` | Easily enable or disable default plugins                                            |
| `polish`                       | `function()...end`                 | Lua function to be run last. Good place for setting vim options and adding mappings |
| `plugins.init`                 | `table` or `function(table)...end` | Modify the default plugins table such as adding new plugins                         |
| `plugins.autopairs`            | `table` or `function(table)...end` | Modify the `autopairs.setup()` options                                              |
| `plugins.better_escape`        | `table` or `function(table)...end` | Modify the `better_escape.setup()` options                                          |
| `plugins.bufferline`           | `table` or `function(table)...end` | Modify the `bufferline.setup()` options                                             |
| `plugins.cmp`                  | `table` or `function(table)...end` | Modify the `cmp.setup()` options                                                    |
| `plugins.colorizer`            | `table` or `function(table)...end` | Modify the `colorizer.setup()` options                                              |
| `plugins.Comment`              | `table` or `function(table)...end` | Modify the `Comment.setup()` options                                                |
| `plugins.gitsigns`             | `table` or `function(table)...end` | Modify the `gitsigns.setup()` options                                               |
| `plugins.nvim-web-devicons`    | `table` or `function(table)...end` | Modify the `nvim-web-devicons.setup()` options                                      |
| `plugins.indent_blankline`     | `table` or `function(table)...end` | Modify the `indent_blankline.setup()` options                                       |
| `plugins.lualine`              | `table` or `function(table)...end` | Modify the `lualine.setup()` options                                                |
| `plugins.lspsaga`              | `table` or `function(table)...end` | Modify the `lspsaga.setup()` options                                                |
| `plugins.neoscroll`            | `table` or `function(table)...end` | Modify the `neoscroll.setup()` options                                              |
| `plugins.nvim-tree`            | `table` or `function(table)...end` | Modify the `nvim-tree.setup()` options                                              |
| `plugins.symbols_outline`      | `table` or `function(table)...end` | Modify the `symbols_outline.setup()` options                                        |
| `plugins.telescope`            | `table` or `function(table)...end` | Modify the `telescope.setup()` options                                              |
| `plugins.toggleterm`           | `table` or `function(table)...end` | Modify the `toggleterm.setup()` options                                             |
| `plugins.treesitter`           | `table` or `function(table)...end` | Modify the `treesitter.setup()` options                                             |
| `plugins.which-key`            | `table` or `function(table)...end` | Modify the `which-key.setup()` options                                              |
| `lsp.on_attach`                | function(client, bufnr)...end`     | Modify the lsp `on_attach` function                                                 |
| `lsp.server_registration`      | function(server, opts)...end`      | Modify the `lsp-installer` `server_registration` function                           |
| `lsp.server-settings.<lsp>`    | `table` or `function(table)...end` | Modify the LSP server settings, replace `<lsp>` with server name                    |
| `which-key.register_n_leader`  | `table` or `function(table)...end` | Modify the default which-key normal mode bindings with `<leader>` prefix            |
| `luasnip.vscode_snippet_paths` | `table` or `function(table)...end` | Add paths with extra VS Code style snippets to be included in `luasnip`             |

## Supported init.lua Override Formats

This applies to all `init.lua` fields except those that expect specific
function definitions such as `null-ls`, `lsp.on_attach`,
`lsp.server_registration`, and `polish`.

Anywhere where you want to override a default provided lua table such as
`plugins.init` (specifying user plugins) or `plugins.X` where `X` is a default
plugin where you want to override the `setup()` call.

### Override Table

For most use cases, supplying a table is more than enough for supplying your
own configuration changes to a default table. This is done by simply providing
a new table and we merge the table with the default table where the user table
takes precedence.

For example, the `plugins.init` table can be used to add new plugins to be
installed along side the default plugins:

```lua
plugins = {
  init = {
    { "andweeb/presence.nvim" }, -- each table entry is a plugin using the Packer syntax without the "use"
    {
      "ray-x/lsp_signature.nvim",
      event = "BufRead",
      config = function()
        require("lsp_signature").setup()
      end,
    },
  },
},
```

Or adding new normal mode `<leader>` bindings to `which-key`:

```lua
["which-key"] = {
  register_n_leader = {
    ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
  },
},
```

### Override Function

There may be cases where you want to have more control over the default tables
when overriding them. For these situations we also provide the ability to use a
`function` that takes one parameter (the default table) and returns a new table
to be used in it's place. This method is a lot more advanced and requires
knowledge of the Lua programming language.

For example with `plugins.init`, you may want to disable lazy-loading for a default plugin while also providing your own plugins:

```lua
plugins = {
  init = function(default_plugins)
    -- A table for your own plugins to load
    local my_plugins = {
      { "andweeb/presence.nvim" },
      {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
          require("lsp_signature").setup()
        end,
      },
    }

    -- The default plugin table is indexable by the package github username/repository
    -- You can directly modify the default table and remove the Packer "cmd" configuration
    default_plugins["akinsho/nvim-toggleterm.lua"]["cmd"] = nil

    -- Finally  you will want to add the my_plugins table to the default table and return it
    return vim.tbl_deep_extend("force", plugins, my_plugins)
  end,
},
```

## Splitting Up Configuration to Multiple Files

AstroVim can be fully configured using just the `user/init.lua` file, but also
supports easily being configured with separate files. These files will be
automatically detected if the file location corresponds to the location in the
`init.lua` table.

For example the plugins `plugins.init` override table (or
`function(table)...end`) can be placed in the file `user/plugins/init.lua`
which would be a `lua` file that returns the override `table` or
`function(table)...end`.

Example `user/plugins/init.lua` file:

```lua
return {
  { "andweeb/presence.nvim" },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
      require("lsp_signature").setup()
    end,
  },
}
```

Another example would be adding a custom `lsp.on_attach` function, this could
be in a file `lsp/on_attach.lua` that returns a `function(client, bufnr)...end`
for example, if you wanted to enable document formatting for the `sumneko_lua`
LSP:

```lua
return function(client, bufnr)
  if client.name == "sumneko_lua" then
    client.resolved_capabilities.document_formatting = true
  end
end
```

### Lazy Loaded Files

When separating these files into separate files they are lazy loaded by AstroVim and only called when they are needed. This is particularly useful when configuring plugins when you may want to `require` them.

For example if you want to add bindings to `nvim-tree` that use the `nvim_tree_callback` function. This can be easily achieved with the file `plugins/nvim-tree.lua` with the contents:

```lua
local tree_cb = require("nvim-tree.config").nvim_tree_callback

return {
  view = {
    mappings = {
      custom_only = false,
      list = {
        { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
        { key = "h", cb = tree_cb "close_node" },
        { key = "v", cb = tree_cb "vsplit" },
      },
    },
  },
}
```

### Example File Tree

A heavily modified AstroVim setup that leverages these separate files could have a file structure as such:

```
user/
├── init.lua
├── null-ls.lua
├── diagnostics.lua
├── lsp/
│   ├── on_attach.lua
│   ├── server_registration.lua
│   └── server-settings/
│       ├── texlab.lua
│       └── yamlls.lua
├── plugins/
|   ├── init.lua
│   ├── bufferline.lua
│   ├── which-key.lua
|   ├── packer.lua
|   ├── symbols_outline.lua
|   ├── telescope.lua
|   ├── toggleterm.lua
|   ├── treesitter.lua
│   └── nvim-tree.lua
├── which-key/
│   └── register_n_leader.lua
└── luasnip/
    └── vscode_snippet_paths.lua
```
