# User Guide

### Basic knowledge of lua language is recommended.

You can learn some basics of lua from [here](https://github.com/pohka/Lua-Beginners-Guide)

### Usage

#### Opening file explorer

To toggle file explorer you need to press `Space` + `e`

#### Opening terminal

To toggle terminal you need to press `Ctrl` + `\`

#### Opening LSP symbols

To toggle symbols outline you need to press `Space` + `s`

#### Close buffer

To close the current buffer you need to press `Space` + `c`

#### Commenting

To comment on a one or multiple lines you need to press `Space` + `/`

#### Show line diagnostics

To see line diagnostics you need to press `g` + `l`

#### Hover document

To hover over a document you need to press `Shift` + `k`

#### Open rename prompt

To open rename prompt you need to press `r` + `n`

#### Go to definition

To go to the definition you need to press `g` + `d`

#### Code actions

To use code actions you need to press `c` + `a`

#### Telescope search

To find files you need to press `Space` + `ff`

#### Telescope grep

To grep files you need to press `Space` + `fw`

#### Telescope git status

To get git status you need to press `Space` + `gt`

#### Telescope old files

To find old files you need to press `Space` + `fo`

#### Which key

You can use which key plugin to get a menu of some helpful key bindings by pressing `Space`

#### Navigate buffers

To switch to the left buffer you need to press `Shift` + `h`<br>
To switch to the right buffer you need to press `Shift` + `l`

#### Navigate windows

To switch to the left window you need to press `Ctrl` + `h`<br>
To switch to the right window you need to press `Ctrl` + `l`<br>
To switch to the top window you need to press `Ctrl` + `k`<br>
To switch to the bottom window you need to press `Ctrl` + `j`

#### Resizing buffers

To resize buffer to the left you need to press `Ctrl` + `left key`<br>
To resize buffer to the right you need to press `Ctrl` + `right key`<br>
To resize buffer to the top you need to press `Ctrl` + `up key`<br>
To resize buffer to the bottom you need to press `Ctrl` + `down key`

#### Disable default plugins

To disable default plugins you need to go to `lua/user/settings.lua` in [here](https://github.com/kabinspace/AstroVim/blob/d60e83d7cc197407109b9c00e5c33dfabefa4d46/lua/user/settings.lua#L32#L48)
and set it to `false` and do `:PackerSync` to delete them
