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

## 📃 **Contents**

- [Preview](#-preview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#️-installation)
- [Setup](#-setup)
- [Configurations](#️-configuration)
- [Key bindings](#-key-bindings)
- [Resources](#️-resources)
- [Credits](#-credits)

	
## 🌟 **Preview**
![Preview1](./utils/media/preview1.png)
![Preview2](./utils/media/preview2.png)
![Preview33](./utils/media/preview3.png)
	

## ✨ **Features**

- File explorer with [Nvimtree](https://github.com/kyazdani42/nvim-tree.lua)
- Autocompletion with [Cmp](https://github.com/hrsh7th/nvim-cmp)
- Git integration with [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- Statusline with [Lualine](https://github.com/nvim-lualine/lualine.nvim)
- Terminal with [Toggleterm](https://github.com/akinsho/toggleterm.nvim)
- Fuzzy finding with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- Syntax highlighting with [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Formatting and linting with [Null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim)
- Language Server Protocol with [Native LSP](https://github.com/neovim/nvim-lspconfig)

## ⚡ **Requirements**
* [Nerd Fonts](https://www.nerdfonts.com/font-downloads)
* [Neovim 0.6+](https://github.com/neovim/neovim/releases/tag/v0.6.1)
	
## 🛠️ **Installation**
### 🐧 Linux

> **NOTE** : Make a backup of your current neovim configurations in order to revert back to your original configurations, ( also delete the contents of `~/.local/share/nvim/site` as the data of remaining plugins can retain)
```
mv ~/.config/nvim ~/.config/nvimbackup
```

#### Clone the repository
```
git clone https://github.com/kabinspace/AstroVim ~/.config/nvim
nvim +PackerSync
```

## 📦 **Setup**

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


## ⚙️ **Configuration**

> [User](https://github.com/kabinspace/AstroVim/blob/main/lua/user) directory is given for custom configuration, you can override default settings in the `/lua/user/settings.lua`

#### For setting a colorscheme
```lua
-- Set colorscheme
colorscheme = "onedark",

```
#### For adding plugins (see [Packer](https://github.com/wbthomason/packer.nvim) for more info)
```lua
-- Add plugins
plugins = {
  { "andweeb/presence.nvim" },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
      require("lsp_signature").setup()
    end,
  },
},
```
#### For plugin specefic and other overrides
```lua
-- Overrides
overrides = {
  treesitter = {
    ensure_installed = { "lua" },
  },
},

-- On/off virtual diagnostics text
virtual_text = true,
```
#### For overridingnd setting your own neovim options (type `:help :options` in command mode to see all available options available in neovim)
```lua
-- Set options
set.relativenumber = true
```
#### For settings custom keybindings
>
> NORMAL MODE = "n"
> 
> INSERT MODE = "i"
> 
> VISUAL MODE = "v"
> 
> VISUAL BLOCK MODE = "x"
> 
> TERM MODE = "t"
> 
> COMMAND MODE = "c"
>

Special keys can be represented as

|    Keys   | Representation |
|:---------:|:--------------:|
|  `Enter`  |     `<CR>`     |
| `Control` |      `<C>`     |
|  `Shift`  |      `<S>`     |
|   `Alt`   |      `<A>`     |

```lua
-- Set key bindings
map("n", "<C-s>", ":w!<CR>", opts)
```
#### For setting auto commands
```lua
-- Set autocommands
vim.cmd [[
  augroup packer_conf
    autocmd!
    autocmd bufwritepost plugins.lua source <afile> | PackerSync
  augroup end
]]
```
#### For configuring formatters and linters ( more on formatters and linters [here](https://github.com/jose-elias-alvarez/null-ls.nvim) )
```lua
-- Add formatters and linters
null_ls.setup {
  debug = false,
  sources = {
    -- Set a formatter
    formatting.rufo,
    -- Set a linter
    diagnostics.rubocop,
  },
  ```
> **NOTE**: You can remove this on attach function to disable format on save
  ```lua
  on_attach = function(client)
    if client.resolved_capabilities.document_formatting then
      vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
    end
  end,
}
```

### 🎹 **Key** **Bindings**
#### The default keyboard shortcuts are given below<br><br>

#### General Keyboard shortcuts
|    Leader Key   |         `Space`        |
|:---------------:|:----------------------:|
|      Escape     | `ii`, `jj`, `jk`, `kj` |
|    Resize Up    |      `Ctrl` + `Up`     |
|   Resize Down   |     `Ctrl` + `Down`    |
|   Resize Left   |     `Ctrl` + `Left`    |
|   Resize Right  |    `Ctrl` + `Right`    |
|    Up Window    |      `Ctrl` + `k`      |
|   Down Window   |      `Ctrl` + `j`      |
|   Left Window   |      `Ctrl` + `h`      |
|   Right Window  |      `Ctrl` + `l`      |
|   Force Write   |      `Ctrl` + `w`      |
|    Force Quit   |      `Ctrl` + `q`      |
| Terminal        | `Ctrl` + `/`           |
| Next Buffer     | `Shift` + `l`          |
| Previous Buffer | `Shift` + `h`          |
| Comment         | `Space` + `/`          |
| NvimTreeToggle  | `Space` + `e`          |
| NvimTreeFocus   | `Space` + `o`          |
| Save Session    | `s` + `s`              |

#### LSP mappings
|    Hover Document    | `Shift` + `k` |
|:--------------------:|:-------------:|
|    Symbols Outline   | `Space` + `s` |
|    Set Local List    | `Space` + `p` |
|   Line Diagnostics   |      `gl`     |
|     Code Actions     |      `ca`     |
|        Rename        |      `rn`     |
|   Diagnostics Next   |      `gj`     |
| Diagnostics Previous |      `gk`     |
|   Goto Declaration   |      `gD`     |
|    Goto Definition   |      `gd`     |
|    Implimentation    |      `gi`     |
|    Goto References   |      `gr`     |
|      Open Float      |      `go`     |

#### Telescope Mappings

|  Live Grep  | `Space` + `fw` |
|:-----------:|:--------------:|
|  Git Status | `Space` + `gt` |
| Git Commits | `Space` + `gc` |
|  Find Files | `Space` + `ff` |
|   Buffers   | `Space` + `fb` |
|  Help Tags  | `Space` + `fh` |
|   Old Tags  | `Space` + `fo` |

## 🗃️ **Resources**

A basic user guide is given [here](https://github.com/kabinspace/AstroVim/blob/main/utils/userguide.md)<br>
Watch us on [youtube](https://www.youtube.com/watch?v=JQLZ7NJRTEo&t=4s&ab_channel=JohnCodes)<br>
Share your experience and ask queries from [AstroVim](https://discord.gg/UcZutyeaFW) community

## ⭐ **Credits**

Sincere appreciation to the following repositories, plugin authors and the entire neovim community out there that made the development of AstroVim possible.

- [Plugins](https://github.com/kabinspace/AstroVim/blob/main/utils/plugins.txt)
- [NvChad](https://github.com/NvChad/NvChad)
- [LunarVim](https://github.com/LunarVim)
- [CosmicVim](https://github.com/CosmicNvim/CosmicNvim)

<div align="center" id="madewithlua">
	
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://lua.org)

</div>
 
