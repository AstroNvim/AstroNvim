# Changelog

## [4.2.1](https://github.com/AstroNvim/AstroNvim/compare/v4.2.0...v4.2.1) (2024-04-23)


### Bug Fixes

* **nvim-dap-ui:** temporarily pin `nvim-dap-ui` to commit until next release ([a6fb183](https://github.com/AstroNvim/AstroNvim/commit/a6fb183eeaf08000f2961bc05009592ff986975c))

## [4.2.0](https://github.com/AstroNvim/AstroNvim/compare/v4.1.12...v4.2.0) (2024-04-18)


### Features

* add notification to recommend running `:Lazy update` again after AstroNvim updates ([3c81105](https://github.com/AstroNvim/AstroNvim/commit/3c811058edc4094a276e637e1763ca14a6135acc))

## [4.1.12](https://github.com/AstroNvim/AstroNvim/compare/v4.1.11...v4.1.12) (2024-04-18)


### Bug Fixes

* **autocmds:** add missing `HighlightURL` default highlight group ([93b10eb](https://github.com/AstroNvim/AstroNvim/commit/93b10ebb1bbf878369625139031f5581c7d3e587))


### Performance Improvements

* optimize url highlighting auto command and disable for large buffers ([848ac6b](https://github.com/AstroNvim/AstroNvim/commit/848ac6b798196893239c680a9d0b6b50c21345f6))

## [4.1.11](https://github.com/AstroNvim/AstroNvim/compare/v4.1.10...v4.1.11) (2024-04-16)


### Performance Improvements

* **astrolsp:** improve lazy loading of AstroLSP ([35b8928](https://github.com/AstroNvim/AstroNvim/commit/35b892836116dd489bf41de4b965052364dabfdb))

## [4.1.10](https://github.com/AstroNvim/AstroNvim/compare/v4.1.9...v4.1.10) (2024-04-11)


### Bug Fixes

* **comment:** add missing `Comment.nvim` mappings for lazy loading ([9d5b0eb](https://github.com/AstroNvim/AstroNvim/commit/9d5b0eb59548e8a5667d3e04d0ca1d9bb487fac9))

## [4.1.9](https://github.com/AstroNvim/AstroNvim/compare/v4.1.8...v4.1.9) (2024-04-10)


### Bug Fixes

* **autocmds:** check if buffer is valid before checking for file ([40f7c42](https://github.com/AstroNvim/AstroNvim/commit/40f7c42b9589cd3fe45168b3875200c3e2e93ed8))

## [4.1.8](https://github.com/AstroNvim/AstroNvim/compare/v4.1.7...v4.1.8) (2024-04-06)


### Bug Fixes

* **mappings:** clear up language of `&lt;Leader&gt;q` and `<Leader>Q` mappings ([e09e62e](https://github.com/AstroNvim/AstroNvim/commit/e09e62e5338e2b2b074c5a041b18a773c0eb55e3))
* **snapshot:** require AstroCore v1.1.1 for important bug fix ([4e0f63c](https://github.com/AstroNvim/AstroNvim/commit/4e0f63ce6efb6f1c1175afd8f77faf861b6f3317))

## [4.1.7](https://github.com/AstroNvim/AstroNvim/compare/v4.1.6...v4.1.7) (2024-04-05)


### Bug Fixes

* make sure `FileType` event is fired at the correct time after `AstroFile` ([eceb0a8](https://github.com/AstroNvim/AstroNvim/commit/eceb0a803bbaf146b0a7a33885b4d7cf410a345d))

## [4.1.6](https://github.com/AstroNvim/AstroNvim/compare/v4.1.5...v4.1.6) (2024-04-04)


### Bug Fixes

* **autocmds:** when triggering `AstroFile` events, only forward events for valid buffers ([3bf88e0](https://github.com/AstroNvim/AstroNvim/commit/3bf88e035e302a15504e1074018cb11e51fc1076))

## [4.1.5](https://github.com/AstroNvim/AstroNvim/compare/v4.1.4...v4.1.5) (2024-04-03)


### Bug Fixes

* **telescope:** load treesitter with telescope ([7462fb1](https://github.com/AstroNvim/AstroNvim/commit/7462fb100799ac8c9ec1968df2d97baf766d6853))

## [4.1.4](https://github.com/AstroNvim/AstroNvim/compare/v4.1.3...v4.1.4) (2024-04-03)


### Bug Fixes

* **autocmds:** fully retrigger original autocmd event after `AstroFile` ([112e209](https://github.com/AstroNvim/AstroNvim/commit/112e209d75bb728ecff416811c52a495531675d0))

## [4.1.3](https://github.com/AstroNvim/AstroNvim/compare/v4.1.2...v4.1.3) (2024-04-02)


### Bug Fixes

* **cmp:** guarantee all sources have a group index ([568da53](https://github.com/AstroNvim/AstroNvim/commit/568da5323cb17652d6eb7536a7668e83398260e9))
* **resession:** enable AstroCore resession extension for single tab restore ([0c9f87b](https://github.com/AstroNvim/AstroNvim/commit/0c9f87bff8232d3efbebdb3d8725ac65887dc28a))

## [4.1.2](https://github.com/AstroNvim/AstroNvim/compare/v4.1.1...v4.1.2) (2024-04-02)


### Bug Fixes

* **lspkind:** improve `cmp` and `lspkind` integration and loading order ([e1a5eca](https://github.com/AstroNvim/AstroNvim/commit/e1a5ecac5fc4dd2a157e466b5edbad49fca461aa))

## [4.1.1](https://github.com/AstroNvim/AstroNvim/compare/v4.1.0...v4.1.1) (2024-04-01)


### Bug Fixes

* **plugins:** explicitly mark all dependencies as `lazy = true` ([dbd3d13](https://github.com/AstroNvim/AstroNvim/commit/dbd3d1320459913bb6cadb3c932ccc986ccb57df))

## [4.1.0](https://github.com/AstroNvim/AstroNvim/compare/v4.0.0...v4.1.0) (2024-04-01)


### Features

* **dap:** enable dap on windows by default ([8d8f18d](https://github.com/AstroNvim/AstroNvim/commit/8d8f18d127b70e10a4e92fecb96a9d0eff75d49e))


### Bug Fixes

* **colorizer:** attach colorizer immediately after lazy loading ([f56a332](https://github.com/AstroNvim/AstroNvim/commit/f56a33276d8446cd562cc140ff0aa6673ae6e3b0))

## [4.0.0](https://github.com/AstroNvim/AstroNvim/compare/v3.45.3...v4.0.0) (2024-04-01)


### ⚠ BREAKING CHANGES

* **mappings:** change `gT` to `gy` for type definition to avoid conflict with core mapping
* move `signs` and `diagnostics` configuration to AstroCore
* **mappings:** change some UI/UX mappings to make more sense
* **options:** move vim options to AstroCore `opts`
* **ui:** unify capital/lowercase meaning for global/buffer
* remove `mini.indentscope` and just use `indent-blankline.nvim`
* **treesitter:** change loop text object from `l` to `o`
* **astrolsp:** configure signs separately from diagnostics
* remove `schemastore` from default plugins
* **mappings:** make `<Leader>uc` and `<Leader>uC` toggle buffer/global cmp and move colorizer toggle to `<Leader>uz`
* **plugins:** move from `null-ls` to maintained fork `none-ls`
* **ui:** use mini.indentscope for highlighting current context ([#2253](https://github.com/AstroNvim/AstroNvim/issues/2253))
* **neo-tree:** remove `o` binding, conflicts with new "Order by" keymaps
* **mason:** rename `MasonUpdate` and `MasonUpdateAll` to `AstroMasonUpdate` and `AstroMasonUpdateAll`
* move configuration defaults to `opts` tables
* move updater, git, and mason utilities to `astrocore`
* move buffer to `astrocore` and icons to `astroui`
* move resession extension to AstroCore
* make resession the default session manager
* move status API to AstroUI
* move colorscheme to AstroUI and polish to AstroCore
* move astronvim.user_terminals to AstroCore
* remove deprecated plugin configs and unnecessary LSPLoaded icon
* move UI/UX utils to `astrocore`
* move astronvim specific options to AstroCore options
* move Heirline `setup_colors` function to AstroUI
* move plugins and lazy_snapshot into `astronvim` module
* move to a model of just providing plugins
* remove updater mappings and commands
* **astrolsp:** `setup_handlers` renamed to `handlers`
* drop support for Neovim v0.8
* **plugins:** use `on_load` and remove some unnecessary `config` functions
* modularize config with AstroCore, AstroUI, and AstroLSP

### Features

* `large_buf` can be set to `false` to disable ([73d521e](https://github.com/AstroNvim/AstroNvim/commit/73d521e112f70f1d74e161531c66ea76327af4c6))
* add `&lt;Leader&gt;SF` to search all previous directory sessions ([ab9455a](https://github.com/AstroNvim/AstroNvim/commit/ab9455a99a664999ea83da8fe509bf01fc1da492))
* add `AstroLargeBuf` autocmd user event and update `max_file` usage to `large_buf` ([efaf0e5](https://github.com/AstroNvim/AstroNvim/commit/efaf0e5393793f70d6c8f5bda9ef58a2ab7f51bd))
* add `AstroUpdate` to update Lazy and Mason ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* add `init.lua` to warn user if they try to use AstroNvim as a direct Neovim configuration ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* add `vim.g.astronvim_options` as an optional function for setting up options ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* add configuration of plugin pinning ([9d1376d](https://github.com/AstroNvim/AstroNvim/commit/9d1376d5eddf44fabd0eb92153201939cfc938ed))
* add Neovim version detection on startup ([ad934f0](https://github.com/AstroNvim/AstroNvim/commit/ad934f0c996c93c9019cae82693c82ff27534271))
* **alpha:** use built in `button` function from Alpha ([1ad1e1e](https://github.com/AstroNvim/AstroNvim/commit/1ad1e1e0dc4b27a3c498130c0956a937245a5ef7))
* **astrocore:** disable rooter `autochdir` by default ([be5ee14](https://github.com/AstroNvim/AstroNvim/commit/be5ee1451e289b9b97f09528a0a0f8f86ce28044))
* **astrocore:** enable built-in project rooting by default ([9a8b7d1](https://github.com/AstroNvim/AstroNvim/commit/9a8b7d1675be66547e4ca4bdd19bd88d1d04be38))
* **astrocore:** increase the default size for large files ([e0b826d](https://github.com/AstroNvim/AstroNvim/commit/e0b826d4e854ea2ce59e927ccfe207e65cdc40f5))
* **astrolsp:** configure `vim.lsp.handlers` in configuration ([ab008dd](https://github.com/AstroNvim/AstroNvim/commit/ab008ddb438432982b67c9f2da74f65d580b0984))
* **astrolsp:** don't add formatting mappings when formatting is disabled ([26147a6](https://github.com/AstroNvim/AstroNvim/commit/26147a631e6c80370181c0617a4bc41ea4de8fbe))
* **astrolsp:** move lsp autocommands to AstroLSP `opts` ([8fe55d0](https://github.com/AstroNvim/AstroNvim/commit/8fe55d042e2d017f26e14b04f53e228b3ed45f29))
* **astrolsp:** move lsp user commands to AstroLSP `opts` ([2c19d9e](https://github.com/AstroNvim/AstroNvim/commit/2c19d9e600b52c62a6e05cad85a63e7f85c952b7))
* **cmp:** add buffer local cmp completion control ([815ee79](https://github.com/AstroNvim/AstroNvim/commit/815ee79ba4537e6073936d791ca7895c9d34ef12))
* **cmp:** allow `LuaSnip` to be disabled ([7958c12](https://github.com/AstroNvim/AstroNvim/commit/7958c12def1cc7a0e3fdba8e55983d2922df5f64))
* **cmp:** fallback to `vim.snippet` if available and no other snippet engine configured ([424f46b](https://github.com/AstroNvim/AstroNvim/commit/424f46b49ebd752997cb965e88f96f404172bde0))
* **cmp:** set `group_index` for lsp and buffer `cmp` sources ([bfb01ee](https://github.com/AstroNvim/AstroNvim/commit/bfb01ee8017a6c38d9cd0df258b0e67cb295d457))
* **config:** add ability to configure `mapleader` and `icons_enabled` in AstroNvim `opts` ([27adb26](https://github.com/AstroNvim/AstroNvim/commit/27adb26c3c65ce82489370f930de93237a671b48))
* **config:** move `maplocalleader` to AstroNvim `opts` to be set up before Lazy ([668691d](https://github.com/AstroNvim/AstroNvim/commit/668691d4bfa298ff38fdf2789412b9d6e0d2a6c3))
* **dev:** add dev utility to generate snapshot for stable releases ([5081890](https://github.com/AstroNvim/AstroNvim/commit/5081890702919d5046382c9af4d38e24e9db4c1a))
* **gitsigns:** use new preview hunk inline ([463be1a](https://github.com/AstroNvim/AstroNvim/commit/463be1a2630cbc2dcd63532d8add755107dbb1ca))
* **heirline:** add virtual environment component ([7761b63](https://github.com/AstroNvim/AstroNvim/commit/7761b6376394e465ab6fea30886f92d96b932869))
* **indent-blankline:** migrate to indent blankline v3 ([c2e15ee](https://github.com/AstroNvim/AstroNvim/commit/c2e15ee549871237072c50d2fcb358aa36ab67ae))
* **lazy:** use `$LAZY` environment directory for lazy dir if available ([1e93c9c](https://github.com/AstroNvim/AstroNvim/commit/1e93c9cd8145acbc4c9588feb60906510b98c44a))
* make resession the default session manager ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **mappings:** make `&lt;Leader&gt;uc` and `<Leader>uC` toggle buffer/global cmp and move colorizer toggle to `<Leader>uz` ([cfa1962](https://github.com/AstroNvim/AstroNvim/commit/cfa1962709b75bca9ee521535a490eae99eefa78))
* move to modular plugin for configuring LSP options ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move to modular plugin for configuring mappings and autocmds ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **neo-tree:** add shift+enter to system open files ([7a20dc7](https://github.com/AstroNvim/AstroNvim/commit/7a20dc79a4305a30b33744a398881e702be6b5a3))
* **nvim-lspconfig:** add lazy loading on `nvim-lspconfig` commands ([495a17a](https://github.com/AstroNvim/AstroNvim/commit/495a17a4691dfdcfc11d3153e98c325ca0cfde1c))
* **nvim-treesitter:** disable all treesitter modules for large buffers ([a92f05d](https://github.com/AstroNvim/AstroNvim/commit/a92f05d3a101db4406f9ef72a41b6888a17347a8))
* **options:** enable confirm by default ([d8055ac](https://github.com/AstroNvim/AstroNvim/commit/d8055ac78087d401f6f1cbfabd080f8d2e638b33))
* **options:** use the histogram algorithm for diff calculations ([f1cfd02](https://github.com/AstroNvim/AstroNvim/commit/f1cfd02c5164906dfcd555315daf1cbbdb54bc46))
* **plugins:** add `todo-comments.nvim` to the base installation ([4d690ca](https://github.com/AstroNvim/AstroNvim/commit/4d690caa269b5a85aca839e154f39c82dd1a3134))
* **plugins:** move from `null-ls` to maintained fork `none-ls` ([b4687e3](https://github.com/AstroNvim/AstroNvim/commit/b4687e3f61804bba70899401f1ada567a061fa61))
* **plugins:** move to `vim-illuminate` to reference highlighting ([1749d5a](https://github.com/AstroNvim/AstroNvim/commit/1749d5ac3be624fb67c58c7b06f92245bafe7736))
* **plugins:** use `on_load` and remove some unnecessary `config` functions ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* remove `mini.indentscope` and just use `indent-blankline.nvim` ([0e23d5b](https://github.com/AstroNvim/AstroNvim/commit/0e23d5b90b8f281835c67ccfe402287c99d5f0ab))
* **resession:** add `&lt;Leader&gt;SD` for deleting a directory session ([e4c586c](https://github.com/AstroNvim/AstroNvim/commit/e4c586cba5ca73286b838c87e13deedf61ed2f39))
* **resession:** add `&lt;Leader&gt;SS` to save current directory session ([76018e9](https://github.com/AstroNvim/AstroNvim/commit/76018e90c5cd082869e98210466b9b7737e23e1b))
* **treesitter:** change loop text object from `l` to `o` ([2ed7eb3](https://github.com/AstroNvim/AstroNvim/commit/2ed7eb37385468a89eb00a167954cc727829cbf7))
* **treesitter:** enable `auto_install` if user has the `tree-sitter` CLI ([ca0db4e](https://github.com/AstroNvim/AstroNvim/commit/ca0db4e8db4d812dbd75a61215078db2853bd529))
* **ui:** use mini.indentscope for highlighting current context ([#2253](https://github.com/AstroNvim/AstroNvim/issues/2253)) ([c2e15ee](https://github.com/AstroNvim/AstroNvim/commit/c2e15ee549871237072c50d2fcb358aa36ab67ae))


### Bug Fixes

* `astrocore.utils` moved to `astrocore` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **alpha:** fix alpha on fresh installation ([16e2805](https://github.com/AstroNvim/AstroNvim/commit/16e2805175cfc6dd7b67279e07f1c5d382256d46))
* **alpha:** patch alpha button function until resolved upstream ([fb94050](https://github.com/AstroNvim/AstroNvim/commit/fb940502cfa5ce72d331317997717b97960c933d))
* **astrocore:** `syntax` toggle renamed to `buffer_syntax` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **astrocore:** prefer version control over project files ([41c63b9](https://github.com/AstroNvim/AstroNvim/commit/41c63b9cfe759811e19bdd80198d3bf1d1d346d6))
* **astrolsp:** `setup_handlers` renamed to `handlers` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **astrolsp:** configure signs separately from diagnostics ([10929d5](https://github.com/AstroNvim/AstroNvim/commit/10929d5a33b0e0b664e76103ed18a95635cb4b06))
* **astrolsp:** move `signs` to new dictionary format ([96bb76f](https://github.com/AstroNvim/AstroNvim/commit/96bb76ff351d39beeb6050dd115d8c5c830a5a93))
* **astrolsp:** update autoformat_enabled to autoformat ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **astrolsp:** update lsp mapping conditions ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **astrolsp:** which-key integration fixed ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **astroui:** add missing gitsigns handlers ([9d593be](https://github.com/AstroNvim/AstroNvim/commit/9d593beed4196d315b06036c7bcd48f350a84461))
* **autocmds:** always fire "AstroFile" if in a vscode session ([5fb7345](https://github.com/AstroNvim/AstroNvim/commit/5fb7345e04a958d278b4ffe6395952ce4fb3dedb))
* **autocmds:** fix large buffer detection autocmd ([2bfce12](https://github.com/AstroNvim/AstroNvim/commit/2bfce126de622a43f2844626c39c213bc1f081ba))
* **autocmds:** silently fail if `augroup` has already been deleted ([f77ec3f](https://github.com/AstroNvim/AstroNvim/commit/f77ec3fa17f92ac76edcfbcf762a8c212e864997))
* **autocmds:** use quotes in git command on windows ([b5ef0d2](https://github.com/AstroNvim/AstroNvim/commit/b5ef0d25693a49c829b09429f131361fc584d69a))
* **cmp:** use `completeopt` from `vim.opt` rather than hard coding in `nvim-cmp` ([a2b3571](https://github.com/AstroNvim/AstroNvim/commit/a2b35718fbf42ebed371694fd86353c213e480a5))
* disable cmp for large buffers ([8b81aa5](https://github.com/AstroNvim/AstroNvim/commit/8b81aa5b633ca01f9c89eab04f07a50e7f87f9be))
* disable completion and indent guides for large buffers ([8b81aa5](https://github.com/AstroNvim/AstroNvim/commit/8b81aa5b633ca01f9c89eab04f07a50e7f87f9be))
* fix initial startup ordering ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **heirline:** only apply sidebar padding for non full-width windows ([548a4c1](https://github.com/AstroNvim/AstroNvim/commit/548a4c1d288a1ccf5d226841c93b5d5868eab7c4))
* **heirline:** update to new `file_info` component defaults ([cf3974f](https://github.com/AstroNvim/AstroNvim/commit/cf3974fe229188b49f3386591803eeeac5a3e4a7))
* improve first installation path ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **indent-blankline:** improve lazy loading ([d9592cd](https://github.com/AstroNvim/AstroNvim/commit/d9592cddc9451836ebb659ff1bc527c296cf904b))
* **init:** improve initialization sequence ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **lspconfig:** resolve lsp attaching when new filetype buffer is not focused ([4f568eb](https://github.com/AstroNvim/AstroNvim/commit/4f568eb63387b3ea5810cca076a296eab0c46414))
* **mappings:** change `gT` to `gy` for type definition to avoid conflict with core mapping ([fe0e3d7](https://github.com/AstroNvim/AstroNvim/commit/fe0e3d708ffad29c06a3ce34e6986a0d5ac5ec52))
* **mappings:** change some UI/UX mappings to make more sense ([77ba866](https://github.com/AstroNvim/AstroNvim/commit/77ba866cb88ba26539d9aa115d8ca53f3205a2e0))
* **mappings:** fix incorrect mapping key casing ([a5cf6a0](https://github.com/AstroNvim/AstroNvim/commit/a5cf6a0a0603b65c8fbfcdcd0b568aee6247e760))
* **mappings:** move diagnostic mappings to always loaded ([e575551](https://github.com/AstroNvim/AstroNvim/commit/e575551e033961cfe2e4fac3d316cb2bcaba3fe5))
* **mason:** rename `MasonUpdate` and `MasonUpdateAll` to `AstroMasonUpdate` and `AstroMasonUpdateAll` ([9be64b9](https://github.com/AstroNvim/AstroNvim/commit/9be64b9d0f8fbd9d57209711a03460b8606abbd4))
* **neo-tree:** add missing fold icons from AstroUI ([bea5d52](https://github.com/AstroNvim/AstroNvim/commit/bea5d528e8ed72f68bfacf5ca1eea9399e315ea2))
* **neo-tree:** disable `foldcolumn` in neo-tree ([61e05d4](https://github.com/AstroNvim/AstroNvim/commit/61e05d4b38cdc0d6826ee01fb954e3740a2483bf))
* **neo-tree:** fix autocmds ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **neo-tree:** improve `h` and `l` navigation edge cases for empty directories and nested files ([f7f3204](https://github.com/AstroNvim/AstroNvim/commit/f7f3204f2d88a26c096a18119f24ebf8f413210f))
* **neo-tree:** remove `o` binding, conflicts with new "Order by" keymaps ([ba92f46](https://github.com/AstroNvim/AstroNvim/commit/ba92f464b1e6738e136fed6650935e3379963899))
* **notify:** add icon disable support to `nvim-notify` ([fcb833c](https://github.com/AstroNvim/AstroNvim/commit/fcb833c92d3b8ec263f2413ad2af1f147a7480a1))
* **notify:** return after closing window ([d68514c](https://github.com/AstroNvim/AstroNvim/commit/d68514c718017350bf603029e3623904a120d7e7))
* **nvim-treesitter:** force install parsers bundled with neovim ([3bd128e](https://github.com/AstroNvim/AstroNvim/commit/3bd128e17a23a7f1df13964aa8a4e8c2d9582aef))
* **options:** add error reporting to malformed user options ([d9eb52d](https://github.com/AstroNvim/AstroNvim/commit/d9eb52d6b6d5dd9f1e5c3fb19028c9882b455d3e))
* **options:** don't concatenate boolean in error message ([90f3c3b](https://github.com/AstroNvim/AstroNvim/commit/90f3c3bb82505ee1a512d531d2cc7216e13fc476))
* **options:** initialize buffer list on startup ([8ea4190](https://github.com/AstroNvim/AstroNvim/commit/8ea4190a67ee04c60868920c2fae1b0317a846ad))
* **plugins:** don't use the shorthand notation for plugins ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **plugins:** make sure `mason` is set up before mason plugins ([4afe41a](https://github.com/AstroNvim/AstroNvim/commit/4afe41a5b94f05802d6a81a7c6508eae3e71ec1a))
* **status:** allow for function in colors definition ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **status:** use user provided `status.colors` table for overriding ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **ui:** unify capital/lowercase meaning for global/buffer ([cf50450](https://github.com/AstroNvim/AstroNvim/commit/cf50450f87bd8897604511369dde729364ed42d1))
* **which-key:** remove separator icon when icons are disabled ([281606e](https://github.com/AstroNvim/AstroNvim/commit/281606e4c7696f3cc2d3eacf2cc5c342cdcbe2a4))
* **which-key:** use a more minimal which-key separator ([a5be725](https://github.com/AstroNvim/AstroNvim/commit/a5be725018ddca1c471f050b5117708efba1684f))


### Performance Improvements

* **autocmds:** improve performance of `AstroFile` detection ([09144c5](https://github.com/AstroNvim/AstroNvim/commit/09144c543ec785e19b3a26cdaf4030c78c02d751))
* **heirline:** simplify buffer matcher for disabling winbar ([91fd4d5](https://github.com/AstroNvim/AstroNvim/commit/91fd4d518971834b40209f6d254a0a176ce2d34c))
* **heirline:** use logic to calculate offset rather than hardcoded list ([72e1780](https://github.com/AstroNvim/AstroNvim/commit/72e17808ad7d6a9d18c9d5f80390222050d71e1d))
* improve initial installation and startup performance ([432897f](https://github.com/AstroNvim/AstroNvim/commit/432897fd8b1088dc44753ebda8cd53058d942e94))
* improve performance of triggered plugin loading ([bae0ad7](https://github.com/AstroNvim/AstroNvim/commit/bae0ad70021e47991cc4514dee99897d7654c3e6))
* **mappings:** remove unnecessary check ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **options:** set options directly ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **plugins:** lazy now ignores plugin fragments if a plugin is disabled ([811a0b1](https://github.com/AstroNvim/AstroNvim/commit/811a0b1ad4e45a900185b9990ad86d6f045d68ac))
* **toggleterm:** optimize toggleterm `on_create` function ([c6a9f03](https://github.com/AstroNvim/AstroNvim/commit/c6a9f03a11c511ce36180ff045c13252f6d6b492))


### Miscellaneous Chores

* remove deprecated plugin configs and unnecessary LSPLoaded icon ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))


### Code Refactoring

* drop support for Neovim v0.8 ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* modularize config with AstroCore, AstroUI, and AstroLSP ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move `signs` and `diagnostics` configuration to AstroCore ([7898fcd](https://github.com/AstroNvim/AstroNvim/commit/7898fcd681ac19ecaadb3a1e85b120220fde986f))
* move astronvim specific options to AstroCore options ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move astronvim.user_terminals to AstroCore ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move buffer to `astrocore` and icons to `astroui` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move colorscheme to AstroUI and polish to AstroCore ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move configuration defaults to `opts` tables ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move Heirline `setup_colors` function to AstroUI ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move plugins and lazy_snapshot into `astronvim` module ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move resession extension to AstroCore ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move status API to AstroUI ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move to a model of just providing plugins ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move UI/UX utils to `astrocore` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* move updater, git, and mason utilities to `astrocore` ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
* **options:** move vim options to AstroCore `opts` ([170774b](https://github.com/AstroNvim/AstroNvim/commit/170774b87545e6a8fdffbec9a37a56403b1c1f5c))
* remove `schemastore` from default plugins ([aeb24b0](https://github.com/AstroNvim/AstroNvim/commit/aeb24b0154c0a8907191acd0546bec904ad215c3))
* remove updater mappings and commands ([0e0d8bd](https://github.com/AstroNvim/AstroNvim/commit/0e0d8bdef5e0a147f1f1a0c434539016d39940b5))
