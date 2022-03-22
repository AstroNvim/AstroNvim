<h1 align="center">AstroVim</h1>

<div align="center"><p>
    <a href="https://github.com/kabinspace/AstroVim/pulse">
      <img src="https://img.shields.io/github/last-commit/kabinspace/AstroVim?color=%4dc71f&label=Last%20Commit&logo=github&style=flat-square"/>
    </a>
    <a href="https://github.com/kabinspace/AstroVim/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/kabinspace/AstroVim?label=License&logo=GNU&style=flat-square"/>
	</a>
    <a href="https://neovim.io/">
      <img src="https://img.shields.io/badge/Neovim-0.6+-blueviolet.svg?style=flat-square&logo=Neovim&logoColor=white"/>
    </a>
    <a href="https://discord.gg/UcZutyeaFW">
      <img src="https://img.shields.io/badge/discord-Join-7289da?color=%235865F2%20&label=Discord&logo=discord&logoColor=%23ffffff&style=flat-square"/>
    </a>
</p>
</div>

<p align="center">
AstroVim is an aesthetic and feature-rich neovim config that is extensible and easy to use with a great set of plugins
</p>

**BREAKING RELEASE NOTICE:** If you were using AstroVim before the official
release, please see the updated user configuration in the [`lua/user_example`
folder](https://github.com/kabinspace/AstroVim/tree/main/lua/user_example)
as well as the updated configuration details below and in the `user_example`
README. The official release came with a lot of restructuring changes to make
things easier and more "future-proof".

## 🌟 Preview

![Preview1](./screenshots/preview1.png)
![Preview2](./screenshots/preview2.png)
![Preview33](./screenshots/preview3.png)

## ⚡ Requirements

- [Nerd Fonts](https://www.nerdfonts.com/font-downloads)
- [Neovim 0.6+](https://github.com/neovim/neovim/releases/tag/v0.6.1)
- Terminal with true color support (for the default theme, otherwise it is dependent on the theme you are using)

> Note when using default theme: For MacOS, the default terminal does not have true color support. You wil need to use [iTerm2](https://iterm2.com/) or another [terminal emulator](https://gist.github.com/XVilka/8346728#terminal-emulators) that has true color support.

## 🛠️ Installation

### Linux

#### Make a backup of your current nvim folder

```
mv ~/.config/nvim ~/.config/nvimbackup
```

#### Clone the repository

```
git clone https://github.com/kabinspace/AstroVim ~/.config/nvim
nvim +PackerSync
```

## 📦 Setup

#### Install LSP

Enter `:LspInstall` followed by the name of the server you want to install<br>
Example: `:LspInstall pyright`

#### Install language parser

Enter `:TSInstall` followed by the name of the language you want to install<br>
Example: `:TSInstall python`

#### Manage plugins

Run `:PackerClean` to remove any disabled or unused plugins<br>
Run `:PackerSync` to update and clean plugins<br>

#### Update AstroVim

Run `:AstroUpdate` to get the latest updates from the repository<br>

## ✨ Features

- File explorer with [Nvimtree](https://github.com/kyazdani42/nvim-tree.lua)
- Autocompletion with [Cmp](https://github.com/hrsh7th/nvim-cmp)
- Git integration with [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- Statusline with [Lualine](https://github.com/nvim-lualine/lualine.nvim)
- Terminal with [Toggleterm](https://github.com/akinsho/toggleterm.nvim)
- Fuzzy finding with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- Syntax highlighting with [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Formatting and linting with [Null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim)
- Language Server Protocol with [Native LSP](https://github.com/neovim/nvim-lspconfig)

## ⚙️ Configuration

To begin making custom user configurations you must create a `user/` folder. The provided example can be created with (please note the trailing slashes after the directory names)

```sh
cp -r ~/.config/nvim/lua/user_example/ ~/.config/nvim/lua/user/
```

The provided example
[user_example](https://github.com/kabinspace/AstroVim/blob/main/lua/user_example)
contains an `init.lua` file which can be used for all user configuration. After
running the `cp` command above this file can be found in
`~/.config/nvim/lua/user/init.lua`.

**Advanced Configuration Options** are described in the [`AstroVim wiki`](https://github.com/kabinspace/AstroVim/wiki/Advanced-Configuration)

## Extending AstroVim

AstroVim should allow you to extend its functionality without going outside of the `user` directory!

Please get in contact when you run into some setup issue where that is not the case.

### Add more Plugins

Just copy the `packer` configuration without the `use` and with a `,` after the last closing `}` into the `plugins.init` entry of your `user/init.lua` file.

See the example in the [user_example](https://github.com/kabinspace/AstroVim/blob/main/lua/user_example) directory.

### Change Default Plugin Configurations

AstroVim allows you to easily override the setup of any pre-configured plugins.
Simply add a table to the `plugins` table with a key the same name as the
plugin package and return a table with the new options or overrides that you
want. For an example see the included `plugins` entry for `treesitter` in the
`user_example` folder which lets you extend the default treesitter
configuration.

### Change Default Packer Configuration

The `plugins` table extensibility includes the packer configuration for all
plugins, user plugins as well as plugins configured by AstroVim.

E.g. this code in your `init.lua` `plugins.init` table entry to remove
`dashboard-nvim` and disable lazy loading of `toggleterm`:

```lua
plugins = {
  -- if the plugins init table can be a function on the default plugin table
  -- instead of a table to be extended. This lets you modify the details of the default plugins
  init = function(plugins)
    -- add your new plugins to this table
    local my_plugins = {
      -- { "andweeb/presence.nvim" },
      -- {
      --   "ray-x/lsp_signature.nvim",
      --   event = "BufRead",
      --   config = function()
      --     require("lsp_signature").setup()
      --   end,
      -- },
    }

    -- Remove a default plugins all-together
    plugins["glepnir/dashboard-nvim"] = nil

    -- Modify default plugin packer configuration
    plugins["akinsho/nvim-toggleterm.lua"]["cmd"] = nil

    -- add the my_plugins table to the plugin table
    return vim.tbl_deep_extend("force", plugins, my_plugins)
  end,
},
```

### Adding sources to `nvim-cmp`

To add new completion sources to `nvim-cmp` you can add the plugin (see above) providing that source like this:

```lua
plugins = {
  init = {
    {
      "Saecki/crates.nvim",
      after = "nvim-cmp",
      config = function()
        require("crates").setup()

        local cmp = require "cmp"
        local config = cmp.get_config()
        table.insert(config.sources, { name = "crates" })
        cmp.setup(config)
      end,
    },
  },
},
```

Use the options provided by `nvim-cmp` to change the order, etc. as you see fit.

### Add Custom LSP Server Settings

You might want to override the default LSP settings for some servers to enable advanced features. This can be achieved with the `lsp.server-settings` table inside of your `user/init.lua` config and creating entries where the keys are equal to the LSP server. Examples of these table entries can be found in [`/lua/configs/lsp/server-settings`](https://github.com/kabinspace/AstroVim/tree/main/lua/configs/lsp/server-settings).

For example, if you want to add schemas to the `yamlls` LSP server, you can add the following to the `user/init.lua` file:

```lua
lsp = {
  ["server-settings"] = {
    yamlls = {
      settings = {
        yaml = {
          schemas = {
            ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
            ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
          },
        },
      },
    },
  },
},
```

### Compley LSP server setup

Some plugins need to do special magic to the LSP configuration to enable advanced features. One example for this is the `rust-tools.nvim` plugin.

Those can override `lsp.server_registration`.

For example the `rust-tools.nvim` plugin can be set up in the `user/init.lua` file as follows:

```lua
plugins = {
  init = {
    -- Plugin definition:
    {
      "simrat39/rust-tools.nvim",
      requires = { "nvim-lspconfig", "nvim-lsp-installer", "nvim-dap", "Comment.nvim" },
      -- Is configured via the server_registration_override installed below!
    },
  },
},

lsp = {
  server_registration = function(server, server_opts)
    -- Special code for rust.tools.nvim!
    if server.name == "rust_analyzer" then
      local extension_path = vim.fn.stdpath "data" .. "/dapinstall/codelldb/extension/"
      local codelldb_path = extension_path .. "adapter/codelldb"
      local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

      require("rust-tools").setup {
        server = server_opts,
        dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }
    else
      server:setup(server_opts)
    end
  end,
},
```

### Extending the LSP on_attach Function

Some users may want to have more control over the `on_attach` function of their LSP servers to enable or disable capabilities. This can be extended with `lsp.on_attach` in the `user/init.lua` file.

For example if you want to disable document formatting for `intelephense` in `user/init.lua`:

```lua
lsp = {
  on_attach = function(client, bufnr)
    if client.name == "intelephense" then
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end,
},
```

## 🗒️ Links

[AstroVim Wiki](https://github.com/kabinspace/AstroVim/wiki)

- [Basic Usage](https://github.com/kabinspace/AstroVim/wiki/Default-Plugins) is given for basic usage
- [Default Mappings](https://github.com/kabinspace/AstroVim/wiki/Default-Mappings) more about the default key bindings
- [Default Plugins](https://github.com/kabinspace/AstroVim/wiki/Default-Plugins) more about the default plugins
- [Advanced Configuration](https://github.com/kabinspace/AstroVim/wiki/Advanced-Configuration) more about advanced configuration

[Watch](https://www.youtube.com/watch?v=JQLZ7NJRTEo&t=4s&ab_channel=JohnCodes) a review video to know about the out of the box experience

## ⭐ Credits

Sincere appreciation to the following repositories, plugin authors and the entire neovim community out there that made the development of AstroVim possible.

- [Plugins](https://github.com/kabinspace/AstroVim/wiki/Default-Plugins)
- [NvChad](https://github.com/NvChad/NvChad)
- [LunarVim](https://github.com/LunarVim)
- [CosmicVim](https://github.com/CosmicNvim/CosmicNvim)

<div align="center" id="madewithlua">

[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://lua.org)

</div>
