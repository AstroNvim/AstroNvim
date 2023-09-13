<div align="center" id="madewithlua">
    <img src="https://astronvim.com/img/logo/astronvim.svg" width="110", height="100">
</div>

<h1 align="center">AstroNvim</h1>

<h4 align="center">
  <a href="https://astronvim.com/#%EF%B8%8F-installation">Install</a>
  ·
  <a href="https://astronvim.com/#%EF%B8%8F-configuration">Configure</a>
  ·
  <a href="https://github.com/AstroNvim/astrocommunity">Community Plugins</a>
  ·
  <a href="https://astronvim.com">Docs</a>
  ·
  <a href="https://discord.astronvim.com">Discord</a>
</h4>

<p align="center">
    <a href="https://github.com/AstroNvim/AstroNvim/pulse">
      <img src="https://img.shields.io/github/last-commit/AstroNvim/AstroNvim?style=for-the-badge&logo=github&color=7dc4e4&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://github.com/AstroNvim/AstroNvim/releases/latest">
      <img src="https://img.shields.io/github/v/release/AstroNvim/AstroNvim?style=for-the-badge&logo=gitbook&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://github.com/AstroNvim/AstroNvim/stargazers">
      <img src="https://img.shields.io/github/stars/AstroNvim/AstroNvim?style=for-the-badge&logo=apachespark&color=eed49f&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <img src="https://img.shields.io/endpoint?url=https://waka.mehalter.com/api/compat/shields/v1/mehalter/interval:any/label:AstroNvim&style=for-the-badge&label=wakatime&logo=wakatime&color=a6da95&logoColor=D9E0EE&labelColor=302D41"/>
    <br>
    <a href="https://www.twitter.com/AstroNvim">
      <img src="https://img.shields.io/twitter/follow/AstroNvim?style=for-the-badge&logo=twitter&color=fab387&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://hachyderm.io/@AstroNvim">
      <img src="https://img.shields.io/mastodon/follow/110685512385862046?domain=https%3A%2F%2Fhachyderm.io&style=for-the-badge&logo=mastodon&color=eebebe&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://www.reddit.com/r/AstroNvim/">
      <img src="https://img.shields.io/reddit/subreddit-subscribers/AstroNvim?style=for-the-badge&logo=reddit&color=ee99a0&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://discord.astronvim.com">
      <img src="https://img.shields.io/discord/939594913560031363?style=for-the-badge&logo=discord&color=cba6f7&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
</p>

<p align="center">
AstroNvim is an aesthetic and feature-rich neovim config that is extensible and easy to use with a great set of plugins
</p>

## 🌟 Preview

![Preview Image](https://astronvim.com/img/themes/overview.png)

## ✨ Features

- Common plugin specifications with [AstroCommunity](https://github.com/AstroNvim/astrocommunity)
- File explorer with [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim)
- Autocompletion with [Cmp](https://github.com/hrsh7th/nvim-cmp)
- Git integration with [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- Statusline, Winbar, and Bufferline with [Heirline](https://github.com/rebelot/heirline.nvim)
- Terminal with [Toggleterm](https://github.com/akinsho/toggleterm.nvim)
- Fuzzy finding with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- Syntax highlighting with [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Formatting and Linting with [Null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim)
- Language Server Protocol with [Native LSP](https://github.com/neovim/nvim-lspconfig)
- Debug Adapter Protocol with [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## ⚡ Requirements

- [Nerd Fonts](https://www.nerdfonts.com/font-downloads) (_Optional with manual intervention:_ See [Documentation on customizing icons](https://astronvim.com/Recipes/icons)) <sup>[[1]](#1)</sup>
- [Neovim 0.8+ (_Not_ including nightly)](https://github.com/neovim/neovim/releases/tag/stable)
- [Tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md) (_Note:_ This is only necessary if you want to use `auto_install` feature with Treesitter)
- A clipboard tool is necessary for the integration with the system clipboard (see [`:help clipboard-tool`](https://neovim.io/doc/user/provider.html#clipboard-tool) for supported solutions)
- Terminal with true color support (for the default theme, otherwise it is dependent on the theme you are using) <sup>[[2]](#2)</sup>
- Optional Requirements:
  - [ripgrep](https://github.com/BurntSushi/ripgrep) - live grep telescope search (`<leader>fw`)
  - [lazygit](https://github.com/jesseduffield/lazygit) - git ui toggle terminal (`<leader>tl` or `<leader>gg`)
  - [go DiskUsage()](https://github.com/dundee/gdu) - disk usage toggle terminal (`<leader>tu`)
  - [bottom](https://github.com/ClementTsang/bottom) - process viewer toggle terminal (`<leader>tt`)
  - [Python](https://www.python.org/) - python repl toggle terminal (`<leader>tp`)
  - [Node](https://nodejs.org/en/) - node repl toggle terminal (`<leader>tn`)

> <sup id="1">[1]</sup> All downloadable Nerd Fonts contain icons which are used by AstroNvim. Install the Nerd Font of your choice to your system and in your terminal emulator settings, set its font face to that Nerd Font. If you are using AstroNvim on a remote system via SSH, you do not need to install the font on the remote system.

> <sup id="2">[2]</sup> Note when using default theme: For MacOS, the default terminal does not have true color support. You will need to use [iTerm2](https://iterm2.com/), [Kitty](https://sw.kovidgoyal.net/kitty/), [WezTerm](https://wezfurlong.org/wezterm/), or another [terminal emulator](https://gist.github.com/XVilka/8346728#terminal-emulators) that has true color support.

## 🛠️ Installation

### Linux/Mac OS (Unix)

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

#### Clone the repository

```shell
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
nvim
```

### Windows (Powershell)

#### Make a backup of your current nvim and nvim-data folder

```pwsh
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName $env:LOCALAPPDATA\nvim.bak
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName $env:LOCALAPPDATA\nvim-data.bak
```

#### Clone the repository

```pwsh
git clone --depth 1 https://github.com/AstroNvim/AstroNvim $env:LOCALAPPDATA\nvim
nvim
```

## 📦 Basic Setup

#### Install LSP

Enter `:LspInstall` followed by the name of the server you want to install<br>
Example: `:LspInstall pyright`

#### Install language parser

Enter `:TSInstall` followed by the name of the language you want to install<br>
Example: `:TSInstall python`

#### Install Debugger

Enter `:DapInstall` followed by the name of the debugger you want to install<br>
Example: `:DapInstall python`

#### Manage plugins

Run `:Lazy check` to check for plugin updates

Run `:Lazy update` to apply any pending plugin updates

Run `:Lazy clean` to remove any disabled or unused plugins

Run `:Lazy sync` to update and clean plugins

#### Update AstroNvim

Run `:AstroUpdate` to get the latest updates from the repository<br>

#### Update AstroNvim Packages

Run `:AstroUpdatePackages` (`<leader>pa`) to update both Neovim plugins and Mason packages

## 🗒️ Links

[AstroNvim Documentation](https://astronvim.com)
[Core AstroNvim LUA API Documentation](https://api.astronvim.com)

- [Basic Usage](https://astronvim.com/Basic%20Usage/walkthrough) is given for basic usage
- [Default Mappings](https://astronvim.com/Basic%20Usage/mappings) more about the default key bindings
- [Default Plugin Configuration](https://astronvim.com/configuration/plugin_defaults) more about the provided plugin defaults
- [Advanced Configuration](https://astronvim.com/configuration/config_options) more about advanced configuration

### 📹 Videos

There have been some great review videos released by members of the community! Here are a few:

- [Neovim With AstroNvim | Your New Advanced Development Editor](https://www.youtube.com/watch?v=GEHPiZ10gOk) (Version: 3, Content By: [@Cretezy](https://github.com/Cretezy))
- [Why I'm quitting VIM by Carlos Mafla](https://www.youtube.com/watch?v=71GDopdc9rw) (Version: 2, Content By: [@gigo6000](https://github.com/gigo6000))
- [Astro Vim - All in one Nvim config!! by John McBride](https://www.youtube.com/watch?v=JQLZ7NJRTEo) (Version: 1, Content By: [@jpmcb](https://github.com/jpmcb))

## 🚀 Contributing

If you plan to contribute, please check the [contribution guidelines](CONTRIBUTING.md) first.

## ⭐ Credits

Sincere appreciation to the following repositories, plugin authors and the entire neovim community out there that made the development of AstroNvim possible.

- [Plugins](https://astronvim.com/acknowledgements#plugins-used-in-astronvim)
- [NvChad](https://github.com/NvChad/NvChad)
- [LunarVim](https://github.com/LunarVim)
- [CosmicVim](https://github.com/CosmicNvim/CosmicNvim)

<div align="center" id="madewithlua">

[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://lua.org)

</div>
