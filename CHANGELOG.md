# Changelog

## [5.3.13](https://github.com/AstroNvim/AstroNvim/compare/v5.3.12...v5.3.13) (2025-11-13)


### Bug Fixes

* **autocmds:** improve `on_key` function to handle searching in command mode and replace mode ([0001b5a](https://github.com/AstroNvim/AstroNvim/commit/0001b5adbd6b6b9c14166f5c5955c43fde5624de))

## [5.3.12](https://github.com/AstroNvim/AstroNvim/compare/v5.3.11...v5.3.12) (2025-09-26)


### Bug Fixes

* **blink:** fix missing snippet icon when use `lspkind` symbols ([d871f76](https://github.com/AstroNvim/AstroNvim/commit/d871f76baeb7e27815a75e37380042166e8c031a))

## [5.3.11](https://github.com/AstroNvim/AstroNvim/compare/v5.3.10...v5.3.11) (2025-09-11)


### Bug Fixes

* **snapshot:** update `lazy_snapshot` ([3f34751](https://github.com/AstroNvim/AstroNvim/commit/3f34751725337ad2bcd3a9546cd185ab286ab5b2))

## [5.3.10](https://github.com/AstroNvim/AstroNvim/compare/v5.3.9...v5.3.10) (2025-08-31)


### Bug Fixes

* **autocmds:** resolve aerial not closing when last buffer ([f3e7cd3](https://github.com/AstroNvim/AstroNvim/commit/f3e7cd30d851e5b0d5bfc347dec76427d0e1e9c9)), closes [#2843](https://github.com/AstroNvim/AstroNvim/issues/2843)

## [5.3.9](https://github.com/AstroNvim/AstroNvim/compare/v5.3.8...v5.3.9) (2025-08-19)


### Bug Fixes

* check for `gdu` executable first on Mac before checking for `gdu-go` ([042d87c](https://github.com/AstroNvim/AstroNvim/commit/042d87c1e53feb0b296d32274e60afac36debfe3)), closes [#2839](https://github.com/AstroNvim/AstroNvim/issues/2839)

## [5.3.8](https://github.com/AstroNvim/AstroNvim/compare/v5.3.7...v5.3.8) (2025-08-07)


### Reverts

* move back to previous logic for automatic hlsearch management ([ff58f54](https://github.com/AstroNvim/AstroNvim/commit/ff58f5490880edfc0934e2ebec23a1cf11fa99bf))

## [5.3.7](https://github.com/AstroNvim/AstroNvim/compare/v5.3.6...v5.3.7) (2025-08-07)


### Bug Fixes

* **autocmds:** improve detection of automatic hlsearch management ([09d3128](https://github.com/AstroNvim/AstroNvim/commit/09d31282ace6872ad6335fd4b38511ad99ec17fd))

## [5.3.6](https://github.com/AstroNvim/AstroNvim/compare/v5.3.5...v5.3.6) (2025-07-26)


### Bug Fixes

* **blink:** add workaround for missing `<End>` mapping in `cmdline` mappings ([fa68880](https://github.com/AstroNvim/AstroNvim/commit/fa68880bcb1c47790ec5acb3da5548e7616574d2))

## [5.3.5](https://github.com/AstroNvim/AstroNvim/compare/v5.3.4...v5.3.5) (2025-07-21)


### Bug Fixes

* **astrocore:** fix incorrect which-key mapping label to indicate buffer local mapping ([047c941](https://github.com/AstroNvim/AstroNvim/commit/047c941a9d7037065ef5069b76531d46688319c5))
* **snacks:** Fix Snacks notifier icons ([e72c9a0](https://github.com/AstroNvim/AstroNvim/commit/e72c9a0523b9f4b76cdc6fa165298d42ae8b91ae))

## [5.3.4](https://github.com/AstroNvim/AstroNvim/compare/v5.3.3...v5.3.4) (2025-07-01)


### Bug Fixes

* **snapshot:** update dependencies ([c2f9ac8](https://github.com/AstroNvim/AstroNvim/commit/c2f9ac881ab830989726b5eb7fea7cd07f12d570))

## [5.3.3](https://github.com/AstroNvim/AstroNvim/compare/v5.3.2...v5.3.3) (2025-05-31)


### Bug Fixes

* **astrolsp:** use `astrolsp.utils` for `supports_method` for deprecation protection ([555be37](https://github.com/AstroNvim/AstroNvim/commit/555be37d8903b0ead166a35ff80dac22076fa375))
* **treesitter:** specify `master` branch in preparation to default branch change ([ed3c636](https://github.com/AstroNvim/AstroNvim/commit/ed3c636e132ae8c40ddc2557c64874b76c420e3a))

## [5.3.2](https://github.com/AstroNvim/AstroNvim/compare/v5.3.1...v5.3.2) (2025-05-27)


### Bug Fixes

* **heirline:** fix highlights not being set until `setup` is called ([9d14deb](https://github.com/AstroNvim/AstroNvim/commit/9d14deb242d4e37621ea61ccc997b51b4d5e36dc))


### Performance Improvements

* **heirline:** add caching for highlight functions ([f082fac](https://github.com/AstroNvim/AstroNvim/commit/f082faccf483bc095ad539aed62352ed0d57bdad))

## [5.3.1](https://github.com/AstroNvim/AstroNvim/compare/v5.3.0...v5.3.1) (2025-05-21)


### Bug Fixes

* **neo-tree:** fix netrw hijacking on first directory opened ([a5c6434](https://github.com/AstroNvim/AstroNvim/commit/a5c6434fae7fe60dbeb95158d26aa9b2d244c6c7))

## [5.3.0](https://github.com/AstroNvim/AstroNvim/compare/v5.2.6...v5.3.0) (2025-05-13)


### Features

* **snapshot:** update Mason to v2 ([b786c47](https://github.com/AstroNvim/AstroNvim/commit/b786c47284c50dca399857c8eef886035bec2e32))


### Bug Fixes

* always pin `blink.cmp` and `mason-lspconfig` even in development mode ([790c5ca](https://github.com/AstroNvim/AstroNvim/commit/790c5ca2bdcf6deee8973644476b49a4470ebe8e))
* **lspconfig:** pin `nvim-lspconfig` to last version not requiring `vim.lsp.config` for Neovim v0.11 ([a5e4de2](https://github.com/AstroNvim/AstroNvim/commit/a5e4de2db3cf7c1deb89f57545a3a4bcde4e6bd2))

## [5.2.6](https://github.com/AstroNvim/AstroNvim/compare/v5.2.5...v5.2.6) (2025-04-23)


### Bug Fixes

* **resession:** get configuration directly from AstroCore ([caf0c74](https://github.com/AstroNvim/AstroNvim/commit/caf0c74ce86d29378c15a224c43c7b2c21246b61))

## [5.2.5](https://github.com/AstroNvim/AstroNvim/compare/v5.2.4...v5.2.5) (2025-04-22)


### Bug Fixes

* **astrocore:** restrict overriding of `foldexpr` on `FileType` ([848884a](https://github.com/AstroNvim/AstroNvim/commit/848884ae2db41c4e2ee96a621ee43e15f462a6ed))

## [5.2.4](https://github.com/AstroNvim/AstroNvim/compare/v5.2.3...v5.2.4) (2025-04-21)


### Bug Fixes

* **astrocore:** make AstroUI folding persistent and override ftplugins ([90409ec](https://github.com/AstroNvim/AstroNvim/commit/90409ecf294765d9967c5f903c706f3d54505d72))
* **neo-tree:** only map filter mappings for filesystem window ([2ddcd27](https://github.com/AstroNvim/AstroNvim/commit/2ddcd27161607fcc9e6b8a3c979538e2e7affec3)), closes [#2802](https://github.com/AstroNvim/AstroNvim/issues/2802)

## [5.2.3](https://github.com/AstroNvim/AstroNvim/compare/v5.2.2...v5.2.3) (2025-04-18)


### Bug Fixes

* **treesitter:** only perform treesitter installations when compiler is available ([ceadde7](https://github.com/AstroNvim/AstroNvim/commit/ceadde78e655df563d30cbb7d73dc6b649d29be6))

## [5.2.2](https://github.com/AstroNvim/AstroNvim/compare/v5.2.1...v5.2.2) (2025-04-17)


### Bug Fixes

* **highlight-colors:** fix typo in config option ([c0aa908](https://github.com/AstroNvim/AstroNvim/commit/c0aa90857f62f7e7e778c592df125b84e133bdc0))
* **options:** always set `clipboard` to `unnamedplus` as this works with OSC52 ([eb583af](https://github.com/AstroNvim/AstroNvim/commit/eb583af3696d486ecd6c2a88ee90511d2d1e1314))

## [5.2.1](https://github.com/AstroNvim/AstroNvim/compare/v5.2.0...v5.2.1) (2025-04-16)


### Bug Fixes

* **nui:** pin to commit until next release ([c1784e3](https://github.com/AstroNvim/AstroNvim/commit/c1784e3a0d7d035211726894e550026bf890da1b))
* **todo-comments:** properly resolve lazy load commands based on plugin availability ([cdddbd3](https://github.com/AstroNvim/AstroNvim/commit/cdddbd3b9e1d83f39a0dae326a41585dba6c4c03))

## [5.2.0](https://github.com/AstroNvim/AstroNvim/compare/v5.1.5...v5.2.0) (2025-04-15)


### Features

* **snacks:** add undo history picker ([ebcdba5](https://github.com/AstroNvim/AstroNvim/commit/ebcdba5ab43d8a9e9fa2717e401dbfa679dd2ed7))

## [5.1.5](https://github.com/AstroNvim/AstroNvim/compare/v5.1.4...v5.1.5) (2025-04-15)


### Bug Fixes

* **neo-tree:** automatically extend `event_handlers` table ([c43b681](https://github.com/AstroNvim/AstroNvim/commit/c43b68155fb249967a707793ac7843c54c3ac027))

## [5.1.4](https://github.com/AstroNvim/AstroNvim/compare/v5.1.3...v5.1.4) (2025-04-14)


### Bug Fixes

* **highlight-colors:** update for important bug fix ([02f599c](https://github.com/AstroNvim/AstroNvim/commit/02f599c7330010eb2a391846574831dcdbfb52a6))

## [5.1.3](https://github.com/AstroNvim/AstroNvim/compare/v5.1.2...v5.1.3) (2025-04-04)


### Bug Fixes

* **snacks:** leave toggle mappings disabling on startup but toggling later ([b5d033c](https://github.com/AstroNvim/AstroNvim/commit/b5d033c54dc22966550662170993401c7865d915))

## [5.1.2](https://github.com/AstroNvim/AstroNvim/compare/v5.1.1...v5.1.2) (2025-04-04)


### Bug Fixes

* **snacks:** make it possible to disable mappings for individual snacks ([724397c](https://github.com/AstroNvim/AstroNvim/commit/724397c9cce2312342682fac09d51198a31d51db))

## [5.1.1](https://github.com/AstroNvim/AstroNvim/compare/v5.1.0...v5.1.1) (2025-04-03)


### Bug Fixes

* **blink:** disable `ghost_text` in `cmdline` by default ([186eae3](https://github.com/AstroNvim/AstroNvim/commit/186eae3b4643865570238303d17d7e87ffacb445))


### Reverts

* **blink:** re-enable `cmdline` in `blink.cmp` after fix upstream ([9cb32ab](https://github.com/AstroNvim/AstroNvim/commit/9cb32ab5bfb8dae23256048bf11b62ea8aca72f5))

## [5.1.0](https://github.com/AstroNvim/AstroNvim/compare/v5.0.6...v5.1.0) (2025-04-01)


### Features

* **snacks:** add find in dir commands for neo-tree ([008c7c9](https://github.com/AstroNvim/AstroNvim/commit/008c7c9a1fe7c7f0ed131201a67aba744ec42f4a))
* **snacks:** add help text for find mappings ([517a6f5](https://github.com/AstroNvim/AstroNvim/commit/517a6f5cee17236235dbeecad69f836feb55bcf0))


### Bug Fixes

* **blink:** disable `cmdline` by default due to instability ([0a22f02](https://github.com/AstroNvim/AstroNvim/commit/0a22f029e4cd82f53d22b3f515d350a8c1ad5fdc)), closes [#2782](https://github.com/AstroNvim/AstroNvim/issues/2782)

## [5.0.6](https://github.com/AstroNvim/AstroNvim/compare/v5.0.5...v5.0.6) (2025-03-31)


### Bug Fixes

* **blink:** prefer rust based fuzzy matching but silently fall back to lua ([f14a3d9](https://github.com/AstroNvim/AstroNvim/commit/f14a3d91db4eb4aed16a80da07a349644038dd98))
* **treesitter:** load treesitter immediately if opening a file directly ([ab69f95](https://github.com/AstroNvim/AstroNvim/commit/ab69f958bd7b2bf7bdaaeabd40ef5c6460d04c8d))

## [5.0.5](https://github.com/AstroNvim/AstroNvim/compare/v5.0.4...v5.0.5) (2025-03-31)


### Bug Fixes

* **blink:** incorrect order of tab operations, select should happen with highest priority ([4230a6f](https://github.com/AstroNvim/AstroNvim/commit/4230a6f7f53a6768dac77f9c1d4a941d9c29c0a0))

## [5.0.4](https://github.com/AstroNvim/AstroNvim/compare/v5.0.3...v5.0.4) (2025-03-29)


### Bug Fixes

* **snacks:** always enable `snacks.image` because utility function locks in configuration early ([bec1085](https://github.com/AstroNvim/AstroNvim/commit/bec1085c6886f0a9b20a48fdcf04544fc0b0da7c)), closes [#2774](https://github.com/AstroNvim/AstroNvim/issues/2774)

## [5.0.3](https://github.com/AstroNvim/AstroNvim/compare/v5.0.2...v5.0.3) (2025-03-29)


### Bug Fixes

* **snapshot:** temporarily pin todo-comments to commit until next release ([30b0d2f](https://github.com/AstroNvim/AstroNvim/commit/30b0d2fe6bcd057c5f8d57b22d820bc954603eeb))

## [5.0.2](https://github.com/AstroNvim/AstroNvim/compare/v5.0.1...v5.0.2) (2025-03-28)


### Bug Fixes

* **which-key:** disable all icons when icons are disabled ([10fd1c6](https://github.com/AstroNvim/AstroNvim/commit/10fd1c6d07e1ef1142ab33ff262b2c8abbbcc9c2)), closes [#2770](https://github.com/AstroNvim/AstroNvim/issues/2770)

## [5.0.1](https://github.com/AstroNvim/AstroNvim/compare/v5.0.0...v5.0.1) (2025-03-27)


### Bug Fixes

* **blink:** use ascii icons when icons are disabled ([a32c53f](https://github.com/AstroNvim/AstroNvim/commit/a32c53fe57fa15342cfe09dba7e1696d7ffb16ee))
* **blink:** use icon provider for snippets source ([57778ec](https://github.com/AstroNvim/AstroNvim/commit/57778ecc8e67bf31126fe24a56750562ad6312a8))
* **mason:** use ascii icons if icons are disabled ([533d716](https://github.com/AstroNvim/AstroNvim/commit/533d7166593d42886ca2e05f0997299472ac160a))
* **mini-icons:** set style to `ascii` if icons are disabled ([87d8642](https://github.com/AstroNvim/AstroNvim/commit/87d86425ed6f7a8aa831b3ef4a9fdb621d367492))

## [5.0.0](https://github.com/AstroNvim/AstroNvim/compare/v4.32.3...v5.0.0) (2025-03-26)


### ⚠ BREAKING CHANGES

* move from `nvim-cmp` to `blink.cmp`
* **plugins:** only use `nvim-ts-context-commentstring` if Neovim v0.10
* **plugins:** only use `Comment.nvim` if Neovim v0.10
* **plugins:** replace `alpha-nvim` with `snacks.dashboard`
* **plugins:** replace `telescope` with `snacks.picker`
* **plugins:** replace `indent-blankline` with `snacks.indent`
* **plugins:** replace `mini.bufremove` with `snacks.bufdelete`
* **plugins:** replace `nvim-notify` with `snacks.notifier`
* **plugins:** replace `dressing.nvim` with `snacks.input` and `snacks.picker`
* use built in Neovim folding in Neovim v0.11
* **astrocore:** use default `update_in_insert` value for diagnostic configuration
* **mappings:** move LSP implementation mapping from `gI` to `gri` to align with Neovim defaults
* **astrolsp:** do not configure any language servers out of the box, removes disabling third party checking in `lua_ls`
* require Neovim v0.10+
* **mappings:** use `<C-S>` in insert mode for signature help to align with default Neovim
* **config:** remove `astronvim.plugins.configs.heirline` function
* **config:** remove `astronvim.plugins.configs.guess-indent` function
* **plugins:** replace `nvim-web-devicons` and `lspkind.nvim` with `mini.icons`
* **plugins:** move from `nvim-colorizer` to `nvim-highlight-colors`
* **plugins:** migrate to `mason-tool-installer` for managing Mason installations

### Features

* **astrocore:** add new `<Leader>uv` and `<Leader>uV` for toggling virtual text and virtual lines ([fbc7c1e](https://github.com/AstroNvim/AstroNvim/commit/fbc7c1ec427e645727790b4352c892ecbc03ef00))
* **astrocore:** only enable large buffer detection for real file buffers by default ([d61f2b1](https://github.com/AstroNvim/AstroNvim/commit/d61f2b18c0c3dca88507b74f097e1535def27e89))
* **astrolsp:** enable LSP file operations by default ([870ddb2](https://github.com/AstroNvim/AstroNvim/commit/870ddb205a145a1d48bbc13ec448bccd9ee29881))
* **astrolsp:** trigger `willCreateFiles`/`didCreateFiles` when creating new files with vim ([a0dbcb6](https://github.com/AstroNvim/AstroNvim/commit/a0dbcb62e250dcad6314d5413c508404a9dfbf87))
* **astrolsp:** use the new `defaults` table for configuring `hover` and `signature_help` ([4bee581](https://github.com/AstroNvim/AstroNvim/commit/4bee581c99eee64716246be6e97cdb00a52d03e6))
* **autocmds:** add autocommand for restoring cursor position now that views are removed ([f164370](https://github.com/AstroNvim/AstroNvim/commit/f1643702f2c6a0a4b9cec9df9e4936b9ce3cf6bb))
* **commands:** add `AstroRename` for easily renaming the current file ([edc0d22](https://github.com/AstroNvim/AstroNvim/commit/edc0d22489234593d68237cc4d6e6da55d478820))
* **highlight-colors:** disable highlight colors on large buffers ([ce0a094](https://github.com/AstroNvim/AstroNvim/commit/ce0a09460aadc058dc700e6e059037a660fa1758))
* **mappings:** add `gco` and `gcO` for inserting comments above and below ([c6431b5](https://github.com/AstroNvim/AstroNvim/commit/c6431b5c29f7db7e782e3c9ce8640af8d366a5b6))
* **mappings:** backport new Neovim v0.11 default `gO` mapping for `vim.lsp.buf.document_symbol` ([7e104a8](https://github.com/AstroNvim/AstroNvim/commit/7e104a879a8fe2d30f542233ac2d14c2bb7e87ee))
* **mappings:** move LSP implementation mapping from `gI` to `gri` to align with Neovim defaults ([f3bb5ab](https://github.com/AstroNvim/AstroNvim/commit/f3bb5ab652ff839ea3a90696f028a506f82bc754))
* **mappings:** use `<C-S>` in insert mode for signature help to align with default Neovim ([1fba436](https://github.com/AstroNvim/AstroNvim/commit/1fba4363fabbf47c21f4b4d471629e0c210c8411))
* **mason-lspconfig:** use AstroLSP to register extra language server mappings to mason packages ([5b57025](https://github.com/AstroNvim/AstroNvim/commit/5b57025b578c2ab7488dc54f2c02cd9cdd3366bb))
* move from `nvim-cmp` to `blink.cmp` ([956bc1c](https://github.com/AstroNvim/AstroNvim/commit/956bc1cf899deaf931236ad444e6edd3f10bbe48))
* **options:** default `uselast` option for `tabclose` in Neovim v0.11 ([d0e7ade](https://github.com/AstroNvim/AstroNvim/commit/d0e7adeb1beab55102845f524f99348182b0f98d))
* **options:** disable completion messages with `shortmess` ([a1f02d0](https://github.com/AstroNvim/AstroNvim/commit/a1f02d02f24ae4b7fddbc74bf3178ee27db5c9f7))
* **plugins:** migrate to `mason-tool-installer` for managing Mason installations ([7c7822d](https://github.com/AstroNvim/AstroNvim/commit/7c7822d29f4f3312cd42b86aad611bc51813f7b1))
* **plugins:** move from `nvim-colorizer` to `nvim-highlight-colors` ([d7c525f](https://github.com/AstroNvim/AstroNvim/commit/d7c525fc65095f1ea7a22a72e5fc54c6804eaba1))
* **plugins:** only use `Comment.nvim` if Neovim v0.10 ([caba46d](https://github.com/AstroNvim/AstroNvim/commit/caba46d4b3fed212017cee6b1d601093ab36d059))
* **plugins:** only use `nvim-ts-context-commentstring` if Neovim v0.10 ([bfd4d0d](https://github.com/AstroNvim/AstroNvim/commit/bfd4d0dd987679159f70147645b15bf63707d941))
* **plugins:** replace `alpha-nvim` with `snacks.dashboard` ([f572528](https://github.com/AstroNvim/AstroNvim/commit/f5725287b2af1247612ec8b5307374db5a3e9ff4))
* **plugins:** replace `dressing.nvim` with `snacks.input` and `snacks.picker` ([6eea6e4](https://github.com/AstroNvim/AstroNvim/commit/6eea6e4af905a7e3cfbe249c4acc44a21e1171b3))
* **plugins:** replace `indent-blankline` with `snacks.indent` ([810236d](https://github.com/AstroNvim/AstroNvim/commit/810236d6bc596095ac1111790baf6036baf96d31))
* **plugins:** replace `mini.bufremove` with `snacks.bufdelete` ([83ddcb6](https://github.com/AstroNvim/AstroNvim/commit/83ddcb6c615559abb5b83d2201dc92adb74d7f87))
* **plugins:** replace `nvim-notify` with `snacks.notifier` ([ea175ff](https://github.com/AstroNvim/AstroNvim/commit/ea175ff4dc7dfb36f4889c403254e61f643c9af7))
* **plugins:** replace `nvim-web-devicons` and `lspkind.nvim` with `mini.icons` ([0c8e0fb](https://github.com/AstroNvim/AstroNvim/commit/0c8e0fb41292b5049e22eb0cf5e23b3b9d689083))
* **plugins:** replace `telescope` with `snacks.picker` ([a682e51](https://github.com/AstroNvim/AstroNvim/commit/a682e51a5486cad57b6ae71a60bfedb9a1628452))
* **plugins:** use `snacks.scope` along with `snacks.indent` ([b188030](https://github.com/AstroNvim/AstroNvim/commit/b188030868f4f427eca8933b5414a1cc09e3abc2))
* **snacks:** add `gitbrowse` mapping ([5ad8e64](https://github.com/AstroNvim/AstroNvim/commit/5ad8e6499af929dc177bc9201ed33c7b3856dcdf))
* **snacks:** configure zen mode and add `<Leader>uZ` mapping ([25884eb](https://github.com/AstroNvim/AstroNvim/commit/25884eb262184a1200c3cf0e2c55f3b18f335e3a))
* **snacks:** enable image support if terminal supports it ([3ab9ea2](https://github.com/AstroNvim/AstroNvim/commit/3ab9ea23cf82db54460e38515975a7c4dbc342dc))
* use built in Neovim folding in Neovim v0.11 ([6c34481](https://github.com/AstroNvim/AstroNvim/commit/6c34481218f133e97b95c3f51fd0c438ee470050))


### Bug Fixes

* **astrocore:** use correct `force` option in `:AstroRename` ([542cbde](https://github.com/AstroNvim/AstroNvim/commit/542cbde9034e7a5e8a787ea40f4e0483c45151de))
* **astrocore:** use default `update_in_insert` value for diagnostic configuration ([f26c0de](https://github.com/AstroNvim/AstroNvim/commit/f26c0de51b80d92c2199e205f76d91eb3768b1b4))
* **astrolsp:** do not configure any language servers out of the box, removes disabling third party checking in `lua_ls` ([709395c](https://github.com/AstroNvim/AstroNvim/commit/709395cb6894b373867ec3d1e1f61a2232d95ed7))
* **astrolsp:** remove lsp handler configuration for neovim 0.11 ([566f8cb](https://github.com/AstroNvim/AstroNvim/commit/566f8cb246bd1af24d9812c07df6a51db7de5cd3))
* **astrolsp:** update codelens on text changing in normal mode ([66faaa5](https://github.com/AstroNvim/AstroNvim/commit/66faaa5697692cc7c3bca3b39744214565c096e8))
* **astroui:** set up new folding configuration ([3d8b3d2](https://github.com/AstroNvim/AstroNvim/commit/3d8b3d21986dc8ba674d0f517036cc03364c2553))
* **cmp:** disable completion when recording macros ([699c086](https://github.com/AstroNvim/AstroNvim/commit/699c086d0ec67ba3b6668befd6eb13a24257d445))
* **heirline:** update winbar on `BufFilePost` ([3ed3497](https://github.com/AstroNvim/AstroNvim/commit/3ed3497d0fc3d5dd2fa2e81de6251a2e7208d3e1))
* make sure `colorscheme` is set after setting up after options ([e201003](https://github.com/AstroNvim/AstroNvim/commit/e2010037d0116bc6cbf4641a238a6bbf2fba0a86))
* **nvim-ufo:** disable `foldexpr` when setting up `nvim-ufo` ([8223350](https://github.com/AstroNvim/AstroNvim/commit/82233506b6be80389fce6559fc9fcd5c57f3f3e9))
* **plugins:** make sure all plugin specifications are merging properly ([220e338](https://github.com/AstroNvim/AstroNvim/commit/220e338de2758ee6854f99c19ed29e55f42414e1))
* **telescope:** have telescope follow symlinks by default ([0d87112](https://github.com/AstroNvim/AstroNvim/commit/0d87112899aaad690e8f0c900c7cb2ff17914812))
* use new `vim.diagnostic.jump` in Neovim v0.11 ([89c4af4](https://github.com/AstroNvim/AstroNvim/commit/89c4af432b101f31b2a1cea2dd938e43e3928503))


### Code Refactoring

* **config:** remove `astronvim.plugins.configs.guess-indent` function ([158c430](https://github.com/AstroNvim/AstroNvim/commit/158c4301a5964383431d6fb3ee9628681fdf220e))
* **config:** remove `astronvim.plugins.configs.heirline` function ([c06b096](https://github.com/AstroNvim/AstroNvim/commit/c06b096805ddcd28dad79167b448b4de2c178f73))
* require Neovim v0.10+ ([38715fa](https://github.com/AstroNvim/AstroNvim/commit/38715fa6be1c177d004cf057d084e4d4f788ad1e))

## [4.32.3](https://github.com/AstroNvim/AstroNvim/compare/v4.32.2...v4.32.3) (2025-03-18)


### Bug Fixes

* **gitsigns:** use the same signs for staged lines ([604b07d](https://github.com/AstroNvim/AstroNvim/commit/604b07d0ca6eff61607f6735786678ae1f18885d))

## [4.32.2](https://github.com/AstroNvim/AstroNvim/compare/v4.32.1...v4.32.2) (2025-03-15)


### Bug Fixes

* **autocmds:** fix `auto_hlsearch` `vim.on_key` function to only check for start of mapping commands ([445c0e3](https://github.com/AstroNvim/AstroNvim/commit/445c0e3995ff2074083b01e7de0a2731458b5559)), closes [#2765](https://github.com/AstroNvim/AstroNvim/issues/2765)

## [4.32.1](https://github.com/AstroNvim/AstroNvim/compare/v4.32.0...v4.32.1) (2025-02-19)


### Bug Fixes

* **_astrolsp:** use correct variable name 'operation' instead of 'module' in file operations ([52f6b2b](https://github.com/AstroNvim/AstroNvim/commit/52f6b2be972cb83923745961f714b3dd576263e0))

## [4.32.0](https://github.com/AstroNvim/AstroNvim/compare/v4.31.1...v4.32.0) (2025-02-17)


### Features

* **astrolsp:** add LSP based file operations and neo-tree integration ([71853c9](https://github.com/AstroNvim/AstroNvim/commit/71853c97440ac479a70c2dab507be6e029b4df9d))
* **autopairs:** only enable auto pairs in actual file editing buffers ([7e633c9](https://github.com/AstroNvim/AstroNvim/commit/7e633c9adc387b67452b971270422a29c0d36f0a))
* **mappings:** add `&lt;Leader&gt;R` to rename the current file ([415adc9](https://github.com/AstroNvim/AstroNvim/commit/415adc944ccf01e5df46a7705865abe2ed5161b2))


### Bug Fixes

* **astrolsp:** disable LSP file operations by default until v5 ([ac15557](https://github.com/AstroNvim/AstroNvim/commit/ac1555797980dc2791a391e9e40224ee5349d96b))

## [4.31.1](https://github.com/AstroNvim/AstroNvim/compare/v4.31.0...v4.31.1) (2025-02-13)


### Bug Fixes

* **treesitter:** load `nvim-treesitter` on `VeryLazy` as it can be needed before a file is opened ([54d7415](https://github.com/AstroNvim/AstroNvim/commit/54d741501bfbabf407f2b27a5ebd298638bf3b13))

## [4.31.0](https://github.com/AstroNvim/AstroNvim/compare/v4.30.3...v4.31.0) (2025-02-13)


### Features

* **astrocore:** enable large buffer notification by default ([ce26623](https://github.com/AstroNvim/AstroNvim/commit/ce26623bcbe1a863e6df0d2c238bdea7b282fc04))
* **astrocore:** increase the large file detection defaults ([b6a794f](https://github.com/AstroNvim/AstroNvim/commit/b6a794f95c075cdbbbb732451add60b53f1a5e01))


### Bug Fixes

* **astrocore:** fix incorrect diagnostic default setting ([0b6e721](https://github.com/AstroNvim/AstroNvim/commit/0b6e7211a0d304826a6bad936dc2c39930e9ac43))

## [4.30.3](https://github.com/AstroNvim/AstroNvim/compare/v4.30.2...v4.30.3) (2025-02-13)


### Bug Fixes

* fix incorrect large buffer function location ([5c2fb2c](https://github.com/AstroNvim/AstroNvim/commit/5c2fb2c660095e3bd2822c11d99254fa1aefc457))

## [4.30.2](https://github.com/AstroNvim/AstroNvim/compare/v4.30.1...v4.30.2) (2025-02-13)


### Bug Fixes

* **vim-illuminate:** disable fully on large buffers ([a64b2df](https://github.com/AstroNvim/AstroNvim/commit/a64b2df6152b4eb11023888ced7dc095af73ed46))

## [4.30.1](https://github.com/AstroNvim/AstroNvim/compare/v4.30.0...v4.30.1) (2025-02-12)


### Bug Fixes

* check if large buffer detection checks are enabled ([ec86d42](https://github.com/AstroNvim/AstroNvim/commit/ec86d42672c0fe82b153054e4a469fbf95a3715b))

## [4.30.0](https://github.com/AstroNvim/AstroNvim/compare/v4.29.3...v4.30.0) (2025-02-12)


### Features

* **astrocore:** add average line length to large buffer detection ([87dc70f](https://github.com/AstroNvim/AstroNvim/commit/87dc70f7761c3e9965315182f0c40bfbd2cbcd0e))


### Performance Improvements

* optimize large buffer detection ([1748b1d](https://github.com/AstroNvim/AstroNvim/commit/1748b1d2f8a0ecf46f26fca1d63b33723b300519))
* **treesitter:** evaluate large buffer detection immediately ([06c071d](https://github.com/AstroNvim/AstroNvim/commit/06c071d28fd7954996a8c1748bb4f1ed1dbc59b9))

## [4.29.3](https://github.com/AstroNvim/AstroNvim/compare/v4.29.2...v4.29.3) (2025-02-04)


### Bug Fixes

* **autopairs:** disable autopairs for more filetypes and make easily extendable ([f344658](https://github.com/AstroNvim/AstroNvim/commit/f34465805a3336127eae15b9f74ca9eb15cfc5a4))
* **lazydev:** use `luv` library bundled with `lua_ls` ([70a8a10](https://github.com/AstroNvim/AstroNvim/commit/70a8a10bbf356d290f83219e4f2e739a2134e7b5))
* use `opts_extend` for Mason registries ([4f6e3fa](https://github.com/AstroNvim/AstroNvim/commit/4f6e3faaf8853f6247b7a0bc2e2a7c0a43cdfdaf))

## [4.29.2](https://github.com/AstroNvim/AstroNvim/compare/v4.29.1...v4.29.2) (2025-01-13)


### Bug Fixes

* **notify:** pin `nvim-notify` to an older version for neovim v0.9 ([299a929](https://github.com/AstroNvim/AstroNvim/commit/299a92999d93ca922041e9af33ef94420cc3e487))

## [4.29.1](https://github.com/AstroNvim/AstroNvim/compare/v4.29.0...v4.29.1) (2025-01-08)


### Bug Fixes

* add hotpatch for Neovim v0.10.3 regression that breaks `:Inspect` ([c05308c](https://github.com/AstroNvim/AstroNvim/commit/c05308cdcbb21b3dc3fdc375be54238c167ba6cb))
* **snapshot:** update dependencies ([e341895](https://github.com/AstroNvim/AstroNvim/commit/e341895375a7994c90085e837b0384f3071f6463))

## [4.29.0](https://github.com/AstroNvim/AstroNvim/compare/v4.28.1...v4.29.0) (2024-12-10)


### Features

* **gitsigns:** add `[G`/`]G` mappings for first and last git hunk ([7077a2e](https://github.com/AstroNvim/AstroNvim/commit/7077a2eb548e8f8c19552f7da44c3d8c04eefabf))

## [4.28.1](https://github.com/AstroNvim/AstroNvim/compare/v4.28.0...v4.28.1) (2024-11-24)


### Bug Fixes

* **snapshot:** update dependencies ([9e5a0c9](https://github.com/AstroNvim/AstroNvim/commit/9e5a0c95a9ce28549784b9c00131bd652165159a))

## [4.28.0](https://github.com/AstroNvim/AstroNvim/compare/v4.27.2...v4.28.0) (2024-11-15)


### Features

* **astroui:** use new Lazygit theming in AstroUI ([e797484](https://github.com/AstroNvim/AstroNvim/commit/e7974843b7652f8bed38ff8ec6d4e5bab5d905ae))


### Bug Fixes

* **astroui:** improve LazyGit theming ([9f627ea](https://github.com/AstroNvim/AstroNvim/commit/9f627ea363b8de4ddcc5e8045c121e6be0f8c394))
* **autocmds:** `vim.highlight` getting deprecated ([31ea1b9](https://github.com/AstroNvim/AstroNvim/commit/31ea1b9d006b9c0732f8188c21fc01c7acc7cf40))

## [4.27.2](https://github.com/AstroNvim/AstroNvim/compare/v4.27.1...v4.27.2) (2024-11-07)


### Bug Fixes

* **snapshot:** update dependencies ([4da229b](https://github.com/AstroNvim/AstroNvim/commit/4da229bb799d277b0693e7c275b6f9364e264166))

## [4.27.1](https://github.com/AstroNvim/AstroNvim/compare/v4.27.0...v4.27.1) (2024-10-28)


### Reverts

* conflicting mapping health checks moved to individual plugins ([c4fa819](https://github.com/AstroNvim/AstroNvim/commit/c4fa819eabedd8b4d5ee6c69b72d0bfd2d855f06))

## [4.27.0](https://github.com/AstroNvim/AstroNvim/compare/v4.26.8...v4.27.0) (2024-10-28)


### Features

* **health:** add duplicate mapping report in `:checkhealth astronvim` ([33a90b5](https://github.com/AstroNvim/AstroNvim/commit/33a90b53b6089ab33a42203d570e75810f8f21bd))

## [4.26.8](https://github.com/AstroNvim/AstroNvim/compare/v4.26.7...v4.26.8) (2024-10-22)


### Reverts

* `mason-lspconfig.nvim` fixed, use original upstream ([a348a4e](https://github.com/AstroNvim/AstroNvim/commit/a348a4e9a21084bac047204a680dc5a415939a08))

## [4.26.7](https://github.com/AstroNvim/AstroNvim/compare/v4.26.6...v4.26.7) (2024-10-15)


### Bug Fixes

* **lspconfig:** use correct branch of `mason-lspconfig` fork ([5611677](https://github.com/AstroNvim/AstroNvim/commit/56116776c428328eeac2c5a3f50070daf2e49b2c))

## [4.26.6](https://github.com/AstroNvim/AstroNvim/compare/v4.26.5...v4.26.6) (2024-10-15)


### Bug Fixes

* **plugins:** use `mason-lspconfig` fork until PR fix is merged ([bee36ce](https://github.com/AstroNvim/AstroNvim/commit/bee36ce8b87ddf6c2e94288c61db1d748b216a1f))
* **snapshot:** fix `nvim-lspconfig` internal module renames ([4fd4781](https://github.com/AstroNvim/AstroNvim/commit/4fd4781ab0c2d9c876acef1fc5b3f01773c78be6))

## [4.26.5](https://github.com/AstroNvim/AstroNvim/compare/v4.26.4...v4.26.5) (2024-09-24)


### Bug Fixes

* **telescope:** unpin telescope as it doesn't truly follow semantic release and is not releasing new features ([f949939](https://github.com/AstroNvim/AstroNvim/commit/f949939cd09f1f3af9d419e04a5ecb21b697a8b3))

## [4.26.4](https://github.com/AstroNvim/AstroNvim/compare/v4.26.3...v4.26.4) (2024-09-24)


### Bug Fixes

* **telescope:** ensure `.git` folders are always ignored on Windows ([4cce0ca](https://github.com/AstroNvim/AstroNvim/commit/4cce0cad81c2089c3350f43b1accc16442d54823))


### Reverts

* remove all `jumpoptions` by default to avoid confusion ([e868e93](https://github.com/AstroNvim/AstroNvim/commit/e868e939cdfdd22a60ad182c398e5f6d519fbb06))

## [4.26.3](https://github.com/AstroNvim/AstroNvim/compare/v4.26.2...v4.26.3) (2024-09-17)


### Bug Fixes

* **dap:** revert back to using Plenary's JSON cleaning function ([cf31b6e](https://github.com/AstroNvim/AstroNvim/commit/cf31b6e33075ad0f0206c5aacd22fc375ab32ab6))

## [4.26.2](https://github.com/AstroNvim/AstroNvim/compare/v4.26.1...v4.26.2) (2024-09-16)


### Bug Fixes

* **alpha:** make plugin icon respect disable icons ([98cf96a](https://github.com/AstroNvim/AstroNvim/commit/98cf96a2a519ddfa480029124bc5288fdc82fa8d))

## [4.26.1](https://github.com/AstroNvim/AstroNvim/compare/v4.26.0...v4.26.1) (2024-09-09)


### Bug Fixes

* **telescope:** always ignore `.git` folders in results ([016c2cf](https://github.com/AstroNvim/AstroNvim/commit/016c2cfc5288118f315a7fb26082d90d86a529b6))

## [4.26.0](https://github.com/AstroNvim/AstroNvim/compare/v4.25.2...v4.26.0) (2024-09-09)


### Features

* **smart-splits:** add intelligent lazy loading of `smart-splits` ([9ac414d](https://github.com/AstroNvim/AstroNvim/commit/9ac414dfc4bfd580062f9a381e94dafacc3454e4))

## [4.25.2](https://github.com/AstroNvim/AstroNvim/compare/v4.25.1...v4.25.2) (2024-09-07)


### Bug Fixes

* **nvim-dap:** don't manually call `load_launchjs` ([a4e5fd8](https://github.com/AstroNvim/AstroNvim/commit/a4e5fd800a51f9d69d88e0717982682a32c08b26))

## [4.25.1](https://github.com/AstroNvim/AstroNvim/compare/v4.25.0...v4.25.1) (2024-09-04)


### Bug Fixes

* **which-key:** terminal mode trigger disabled upstream ([5a77860](https://github.com/AstroNvim/AstroNvim/commit/5a7786079a3ffd747c13a3b4160f22caaa57737b))

## [4.25.0](https://github.com/AstroNvim/AstroNvim/compare/v4.24.1...v4.25.0) (2024-08-30)


### Features

* **telescope:** add `&lt;Leader&gt;fg` to search git tracked files ([16db0c6](https://github.com/AstroNvim/AstroNvim/commit/16db0c64042419ded746ed858641abbd2bdaafac))

## [4.24.1](https://github.com/AstroNvim/AstroNvim/compare/v4.24.0...v4.24.1) (2024-08-29)


### Bug Fixes

* **cmp:** list extend `sources` table automatically ([53984b0](https://github.com/AstroNvim/AstroNvim/commit/53984b02dfa023439c4e7e086fb23e01e07a4c90))

## [4.24.0](https://github.com/AstroNvim/AstroNvim/compare/v4.23.11...v4.24.0) (2024-08-26)


### Features

* **astrolsp:** factor in `retriggerCharacters` in `signatureHelpProvider` ([fe6e596](https://github.com/AstroNvim/AstroNvim/commit/fe6e5961206b46d2c1b883ae538b971d5a7d6ac0))


### Bug Fixes

* **alpha:** improve window detection for dashboard ([6d43957](https://github.com/AstroNvim/AstroNvim/commit/6d439577678581b25eb86cc36e34c6e33369324d)), closes [#2691](https://github.com/AstroNvim/AstroNvim/issues/2691)
* **astrolsp:** make sure to clear automatic signature help internals when leaving insert ([1b68ef4](https://github.com/AstroNvim/AstroNvim/commit/1b68ef4d174f12cebf53e9d17c5cddc9a70a1ad6))


### Performance Improvements

* **astrolsp:** use set lookup for signature help triggering ([20815a7](https://github.com/AstroNvim/AstroNvim/commit/20815a7792caeef7b1d209084ed0766c7d2fa737))

## [4.23.11](https://github.com/AstroNvim/AstroNvim/compare/v4.23.10...v4.23.11) (2024-08-23)


### Bug Fixes

* **autocmds:** make sure to clean up `q_close_windows` cache ([622b7e8](https://github.com/AstroNvim/AstroNvim/commit/622b7e8d5f11f2451e1fb6363200de86931505b8))

## [4.23.10](https://github.com/AstroNvim/AstroNvim/compare/v4.23.9...v4.23.10) (2024-08-23)


### Bug Fixes

* **autocmds:** don't overwrite buffer-local `q` mapping if set ([a368bd2](https://github.com/AstroNvim/AstroNvim/commit/a368bd203220392589ac60deb6d47d02db9c7f5c))


### Performance Improvements

* **autocmds:** Only set `q` to close mapping at most once for a buffer ([6cb78a6](https://github.com/AstroNvim/AstroNvim/commit/6cb78a6cdb80e92abd53633d6b835771dd9ed747))

## [4.23.9](https://github.com/AstroNvim/AstroNvim/compare/v4.23.8...v4.23.9) (2024-08-22)


### Bug Fixes

* **snapshot:** move `aerial` and `indent-blankline` to pinning commits until their next releases ([3258357](https://github.com/AstroNvim/AstroNvim/commit/3258357293fb50cff543f39bf812df12b223d132))

## [4.23.8](https://github.com/AstroNvim/AstroNvim/compare/v4.23.7...v4.23.8) (2024-08-20)


### Bug Fixes

* **snapshot:** pin treesitter to older version until all plugins update ([96a5317](https://github.com/AstroNvim/AstroNvim/commit/96a5317b2de8028785dd92192afeac7008f0b5ca))

## [4.23.7](https://github.com/AstroNvim/AstroNvim/compare/v4.23.6...v4.23.7) (2024-08-19)


### Bug Fixes

* **which-key:** don't show which-key in terminal mode by default ([7d3020e](https://github.com/AstroNvim/AstroNvim/commit/7d3020edd868304b8cf6b5b8fd2806b5bcabb4f7))

## [4.23.6](https://github.com/AstroNvim/AstroNvim/compare/v4.23.5...v4.23.6) (2024-08-19)


### Bug Fixes

* **autocmds:** don't create directories for URI like buffers ([9168082](https://github.com/AstroNvim/AstroNvim/commit/9168082a268fa665be3b8a3194631dc30ba4e727)), closes [#2682](https://github.com/AstroNvim/AstroNvim/issues/2682)

## [4.23.5](https://github.com/AstroNvim/AstroNvim/compare/v4.23.4...v4.23.5) (2024-08-15)


### Bug Fixes

* **options:** make `&gt;`/`&lt;` follow `shiftwidth` ([0d35704](https://github.com/AstroNvim/AstroNvim/commit/0d357041a54fb18404250c05726dff2c4ad99068))
* **options:** make maintain view when jumping back to buffer ([f5dbbd2](https://github.com/AstroNvim/AstroNvim/commit/f5dbbd23f7cba8de14e697670acb3d2d7d82fad2))

## [4.23.4](https://github.com/AstroNvim/AstroNvim/compare/v4.23.3...v4.23.4) (2024-08-09)


### Reverts

* not using `on_attach` doesn't resolve aerial bug ([b0758c3](https://github.com/AstroNvim/AstroNvim/commit/b0758c334eb6f5074222d4811fee9075604d1066))

## [4.23.3](https://github.com/AstroNvim/AstroNvim/compare/v4.23.2...v4.23.3) (2024-08-08)


### Bug Fixes

* **aerial:** remove `on_attach` until upstream bug fixed ([43e3813](https://github.com/AstroNvim/AstroNvim/commit/43e38131799f0902e4c616dad1d0578514548d1a))
* **mappings:** don't set terminal movement commands in floating windows ([7d3214d](https://github.com/AstroNvim/AstroNvim/commit/7d3214d881e413ec7c4417a88bacc5982a4a5fe0))

## [4.23.2](https://github.com/AstroNvim/AstroNvim/compare/v4.23.1...v4.23.2) (2024-08-04)


### Bug Fixes

* **nvim-dap:** add nicer error message when parsing `.vscode/launch.json` file ([18b729b](https://github.com/AstroNvim/AstroNvim/commit/18b729bc4793393a40049a3744d7b2d920b146ba))
* **nvim-dap:** use AstroCore for JSON cleanup until plenary merges fix PR ([a84f11a](https://github.com/AstroNvim/AstroNvim/commit/a84f11ac4b8dfce4a2dfbdfca5d592fc6ac8ec9e))

## [4.23.1](https://github.com/AstroNvim/AstroNvim/compare/v4.23.0...v4.23.1) (2024-08-01)


### Bug Fixes

* **snapshot:** update `nvim-treesitter-text-objects` for bug fix ([85885ba](https://github.com/AstroNvim/AstroNvim/commit/85885bac4052fa3c3e1c2acc031a0ff1cae334cf))

## [4.23.0](https://github.com/AstroNvim/AstroNvim/compare/v4.22.2...v4.23.0) (2024-07-31)


### Features

* **astrolsp:** add the ability to automatically show signature help while editing ([4cb0e37](https://github.com/AstroNvim/AstroNvim/commit/4cb0e37aa0ce13a25850a2c77a953bdad166d416))
* **toggleterm:** use default `horizontal` direction for terminals ([fc1dfea](https://github.com/AstroNvim/AstroNvim/commit/fc1dfea6be2464a289be022ae6908cda58987298))

## [4.22.2](https://github.com/AstroNvim/AstroNvim/compare/v4.22.1...v4.22.2) (2024-07-30)


### Bug Fixes

* **astrolsp:** LSP signature help shouldn't be focusable ([101543f](https://github.com/AstroNvim/AstroNvim/commit/101543f2fe26ed53b742e4085ccbea8ed2940bf9))

## [4.22.1](https://github.com/AstroNvim/AstroNvim/compare/v4.22.0...v4.22.1) (2024-07-30)


### Bug Fixes

* **cmp:** protect against `nil` LSP kind in completion ([daf0b60](https://github.com/AstroNvim/AstroNvim/commit/daf0b604e8e1dabbe4d90e378c781a877b7ca966))
* **nvim-dap-ui:** fix incorrect loading order ([4f95228](https://github.com/AstroNvim/AstroNvim/commit/4f95228e559f938b80cb45223bef4bb54fd8ff95))

## [4.22.0](https://github.com/AstroNvim/AstroNvim/compare/v4.21.0...v4.22.0) (2024-07-25)


### Features

* **plugins:** migrate from `neodev` to `lazydev`, closes [#2618](https://github.com/AstroNvim/AstroNvim/issues/2618) ([0126d44](https://github.com/AstroNvim/AstroNvim/commit/0126d447633a5eddfb7cf0f93cdcae27c2df54fa))

## [4.21.0](https://github.com/AstroNvim/AstroNvim/compare/v4.20.1...v4.21.0) (2024-07-22)


### Features

* **dap:** automatically load vscode `launch.json` when loading DAP ([e43facb](https://github.com/AstroNvim/AstroNvim/commit/e43facbba4b904c27b96a73b46164ea0c73eeab5))


### Bug Fixes

* **better-escape:** load on "VeryLazy" now that `better-escape` works in all modes ([e0cb231](https://github.com/AstroNvim/AstroNvim/commit/e0cb23159376f47668d9395aa2b7f20405d22bfa))
* **better-escape:** only use `jj` and `jk` for escape in insert mode ([08399f6](https://github.com/AstroNvim/AstroNvim/commit/08399f6ead600d1ec45038e6b96a8240f06e8f91))
* **neo-tree:** extend sources list by default ([f97178d](https://github.com/AstroNvim/AstroNvim/commit/f97178d56b52cdfeafa0c57e4aced679bb8b05d3))
* **telescope:** automatically rebuild `telescope-fzf` if necessary ([7c6cb6f](https://github.com/AstroNvim/AstroNvim/commit/7c6cb6fe4d4888937881413a5377bd3a11ab02ec))
* **which-key:** extend `disable` lists by default as well ([b0df6ae](https://github.com/AstroNvim/AstroNvim/commit/b0df6aebc12bd54d4dea6e8dd34287a22fd3303d))

## [4.20.1](https://github.com/AstroNvim/AstroNvim/compare/v4.20.0...v4.20.1) (2024-07-16)


### Bug Fixes

* **astrolsp:** register LSP mapping group locally as well as globally ([ca129a7](https://github.com/AstroNvim/AstroNvim/commit/ca129a7b830877382877d9fc4a9c1ff18847e11a))
* **options:** don't set clipboard in SSH session with 0.10+ for OSC52 support ([b11f0d2](https://github.com/AstroNvim/AstroNvim/commit/b11f0d2b620fbced8e744e6675bb2982f0071886))
* **which-key:** automatically extend `spec` table in `which-key` ([5362d84](https://github.com/AstroNvim/AstroNvim/commit/5362d844d076b9bb6aa13ecb036750f58bbb5d23))


### Performance Improvements

* **ts-autotag:** remove unnecessary custom `config` ([7c6ff2e](https://github.com/AstroNvim/AstroNvim/commit/7c6ff2e4816b18c8796655c0af1d335503f7517a))

## [4.20.0](https://github.com/AstroNvim/AstroNvim/compare/v4.19.0...v4.20.0) (2024-07-12)


### Features

* **mappings:** add `&lt;Leader&gt;x` menu for quickfix/list access ([99c2b13](https://github.com/AstroNvim/AstroNvim/commit/99c2b13df7b4943b3f82ca772db3dfb8f13f42e7))


### Bug Fixes

* Move `editorconfig` ensurance back to `autocmd` for better user control ([309fb21](https://github.com/AstroNvim/AstroNvim/commit/309fb21c3679c13abb4d4b64a5f86fee7f21414d))
* **which-key:** update to the new v3 setup ([1839d93](https://github.com/AstroNvim/AstroNvim/commit/1839d93b078f38c5924cedcd8efefce9840e6869))


### Performance Improvements

* **vim-illuminate:** make large file detection more aggressive ([14a389f](https://github.com/AstroNvim/AstroNvim/commit/14a389fb114c9918b1bd79ebb2f2e5dba4f32e3d))

## [4.19.0](https://github.com/AstroNvim/AstroNvim/compare/v4.18.0...v4.19.0) (2024-07-10)


### Features

* **mappings:** add bindings for beginning and end of quickfix and location lists ([b0de586](https://github.com/AstroNvim/AstroNvim/commit/b0de586d0652505daee70849bf0bd5ac50ef0df0))


### Bug Fixes

* **astrolsp:** fix typo in mappings ([75bb91a](https://github.com/AstroNvim/AstroNvim/commit/75bb91a49400e4e0bd6f0d48b6036602a364e774))


### Performance Improvements

* **lspconfig:** optimize re-application of `editorconfig` ([8358cb2](https://github.com/AstroNvim/AstroNvim/commit/8358cb2e2dfcd598bf0185a1d437728d1c964333))

## [4.18.0](https://github.com/AstroNvim/AstroNvim/compare/v4.17.4...v4.18.0) (2024-07-10)


### Features

* **astrolsp:** add `&lt;Leader&gt;lA` for document source code actions ([5da7018](https://github.com/AstroNvim/AstroNvim/commit/5da70183cf72657a39d6eeead3ce4b7cf8dc45b7)), closes [#2655](https://github.com/AstroNvim/AstroNvim/issues/2655)


### Bug Fixes

* **astrolsp:** visual mode formatting should check for `rangeFormatting` capability ([27341c6](https://github.com/AstroNvim/AstroNvim/commit/27341c62626dfb525ac2490548bc65898d2d7e17))
* **autocmds:** only emit each `augroup` event once ([b4716f5](https://github.com/AstroNvim/AstroNvim/commit/b4716f5aa7b2a1fdfa6ba34a74b39a7f8c711070))

## [4.17.4](https://github.com/AstroNvim/AstroNvim/compare/v4.17.3...v4.17.4) (2024-07-09)


### Bug Fixes

* **autocmds:** collect `augroups` before `AstroFile` events are triggered ([649dca3](https://github.com/AstroNvim/AstroNvim/commit/649dca3b98df3b9d6a3ff039e534d8b6ebd349f5))

## [4.17.3](https://github.com/AstroNvim/AstroNvim/compare/v4.17.2...v4.17.3) (2024-07-09)


### Bug Fixes

* **autocmds:** only trigger `filetypedetect` events after `AstroFile`/`AstroGitFile` events ([97085c1](https://github.com/AstroNvim/AstroNvim/commit/97085c159d7e468fe4aebc50b1f45fd3ab4f18ef)), closes [#2651](https://github.com/AstroNvim/AstroNvim/issues/2651)

## [4.17.2](https://github.com/AstroNvim/AstroNvim/compare/v4.17.1...v4.17.2) (2024-07-08)


### Bug Fixes

* **astrolsp:** `servers` list should be extended by default ([167fd37](https://github.com/AstroNvim/AstroNvim/commit/167fd3780a66f9574d554f5e729073c782104829))

## [4.17.1](https://github.com/AstroNvim/AstroNvim/compare/v4.17.0...v4.17.1) (2024-07-08)


### Reverts

* **cmp:** visibility check was fine, move lazy loading back to `InsertEnter` ([4d7614f](https://github.com/AstroNvim/AstroNvim/commit/4d7614f65bd6afba5fa5f23ce9d1880bb5bd41b3))

## [4.17.0](https://github.com/AstroNvim/AstroNvim/compare/v4.16.2...v4.17.0) (2024-07-08)


### Features

* add support for more icon providers in `cmp` completion ([f633f03](https://github.com/AstroNvim/AstroNvim/commit/f633f03e1651d69203c1828c128ed1e36bdf6264))


### Bug Fixes

* **cmp:** centralize formatting function ([024428b](https://github.com/AstroNvim/AstroNvim/commit/024428bf96b5a7976cb52a55c001a268de520cb5))
* **cmp:** fix backwards compatibility for users using `lspkind` options ([d9edd6a](https://github.com/AstroNvim/AstroNvim/commit/d9edd6ab0555381299c00a392df8a700b2f459a4))


### Reverts

* **cmp:** use default `cmp.visible` function for checking visibility ([01a3aea](https://github.com/AstroNvim/AstroNvim/commit/01a3aea3982e1bdca7e4b70155bf1fabe3753bcb))

## [4.16.2](https://github.com/AstroNvim/AstroNvim/compare/v4.16.1...v4.16.2) (2024-07-01)


### Bug Fixes

* **astroui:** match `terminal` and `nofile` exactly in winbar disabling ([2869329](https://github.com/AstroNvim/AstroNvim/commit/28693294f01498d8137b4958f47c0be17407cb3b))
* **heirline:** fix type in winbar control ([7f4652f](https://github.com/AstroNvim/AstroNvim/commit/7f4652f09a03a665e5d8fcac6bc9d609e368e348))

## [4.16.1](https://github.com/AstroNvim/AstroNvim/compare/v4.16.0...v4.16.1) (2024-07-01)


### Bug Fixes

* **snapshot:** pin `nvim-dap` to commit as releases are not frequent ([bd696b7](https://github.com/AstroNvim/AstroNvim/commit/bd696b78b4c669631c6bebf37d60236da26b032c))

## [4.16.0](https://github.com/AstroNvim/AstroNvim/compare/v4.15.1...v4.16.0) (2024-07-01)


### Features

* **aerial:** add `]y`/`[y`/`]Y`/`[Y` to navigate between symbols ([16e09da](https://github.com/AstroNvim/AstroNvim/commit/16e09daa6c78ff30a47b5b69c904335f5bb543d4))
* **astrocore:** add `]e`/`[e` and `]w`/`[w` to navigate between errors and warnings ([24b59a7](https://github.com/AstroNvim/AstroNvim/commit/24b59a7275854e530440e7cd51d3d9cc2be8c131))

## [4.15.1](https://github.com/AstroNvim/AstroNvim/compare/v4.15.0...v4.15.1) (2024-06-30)


### Bug Fixes

* **telescope:** remove mappings that break default telescope behavior ([c5421e8](https://github.com/AstroNvim/AstroNvim/commit/c5421e8abf9bd209da5ef64892bbd68fbd2a06f2))

## [4.15.0](https://github.com/AstroNvim/AstroNvim/compare/v4.14.0...v4.15.0) (2024-06-28)


### Features

* **gitsigns:** add `ig` text objects for git hunks ([74686a2](https://github.com/AstroNvim/AstroNvim/commit/74686a2ae9f00daab08d770a66f671627f7ac107))
* **gitsigns:** set mappings with `on_attach` in `gitsigns` `opts` to make mappings context aware ([e0d2285](https://github.com/AstroNvim/AstroNvim/commit/e0d228527bca539b079dc5a1397ebd5aec2d90ad))


### Bug Fixes

* **gitsigns:** fix mappings incorrectly following lowercase/uppercase conventions ([35012ff](https://github.com/AstroNvim/AstroNvim/commit/35012ffdfaac0b9f472ac88111a227c49e693464))

## [4.14.0](https://github.com/AstroNvim/AstroNvim/compare/v4.13.0...v4.14.0) (2024-06-27)


### Features

* **astrocore:** add `]l`/`[l` for navigating loclist ([32c31d5](https://github.com/AstroNvim/AstroNvim/commit/32c31d5d6b3b544283344c9f2c4765be2fd41a08))
* **astrocore:** add `]q`/`[q` for navigating quickfix ([3624fc4](https://github.com/AstroNvim/AstroNvim/commit/3624fc479970917172445a08da851cbb634a5038))


### Bug Fixes

* **astroui:** set colorscheme to `astrotheme` rather than `astrodark` to respect light background on initial installation ([def9128](https://github.com/AstroNvim/AstroNvim/commit/def91287ce75fe5a43ff9d3a8fb361c3dff35b4c)), closes [#2639](https://github.com/AstroNvim/AstroNvim/issues/2639)
* **lspconfig:** do not use `astrocore` in `cmd` function of plugin spec ([b97a1b9](https://github.com/AstroNvim/AstroNvim/commit/b97a1b9da78abdd62cf4b8822855af07a67a620a))

## [4.13.0](https://github.com/AstroNvim/AstroNvim/compare/v4.12.1...v4.13.0) (2024-06-25)


### Features

* **telescope:** open multiple selected files ([#2637](https://github.com/AstroNvim/AstroNvim/issues/2637)) ([cc1d152](https://github.com/AstroNvim/AstroNvim/commit/cc1d1529da8c33c421b21c59f73b41648b32ea3c))


### Reverts

* `luarocks` support improved in Lazy.nvim ([cc4396c](https://github.com/AstroNvim/AstroNvim/commit/cc4396c9e8f5515298a701ae59a236db6cd3f15b))

## [4.12.1](https://github.com/AstroNvim/AstroNvim/compare/v4.12.0...v4.12.1) (2024-06-24)


### Bug Fixes

* **astrocore:** safely load astrocore for initial installation protection ([6f91c78](https://github.com/AstroNvim/AstroNvim/commit/6f91c788fe7c845094ee7093d4ae55fa63cef963))
* **gitsigns:** `winbar` configured upstream for blame window ([dee34f1](https://github.com/AstroNvim/AstroNvim/commit/dee34f111daca65d6e5428cb0c94e9399b725d2c))
* **lazy:** disable `luarocks` integration if it is not installed ([9a81c8c](https://github.com/AstroNvim/AstroNvim/commit/9a81c8c5415f0519c5ad816db33974e4479c0089))
* **plugins:** manually disable `luarocks` in `plenary` and `telescope` for now ([6a967f3](https://github.com/AstroNvim/AstroNvim/commit/6a967f3803238a5eda2b16af35c24cd5444b37f1))

## [4.12.0](https://github.com/AstroNvim/AstroNvim/compare/v4.11.1...v4.12.0) (2024-06-24)


### Features

* update to `lazy.nvim` v11 ([ac1746f](https://github.com/AstroNvim/AstroNvim/commit/ac1746f2e5a821597d30f50f72b3fe3a6667a241))

## [4.11.1](https://github.com/AstroNvim/AstroNvim/compare/v4.11.0...v4.11.1) (2024-06-21)


### Bug Fixes

* **cmp_luasnip:** add missing `command` mode mappings ([5a9551c](https://github.com/AstroNvim/AstroNvim/commit/5a9551cf78ada904371fc9ce1b9987ea1ce6e3b1))

## [4.11.0](https://github.com/AstroNvim/AstroNvim/compare/v4.10.5...v4.11.0) (2024-06-20)


### Features

* **astroui:** use `opts` table for configuring when winbar is enabled/disabled ([211e0d1](https://github.com/AstroNvim/AstroNvim/commit/211e0d187df5681f7610349e48ef6f8b0ad959b8))

## [4.10.5](https://github.com/AstroNvim/AstroNvim/compare/v4.10.4...v4.10.5) (2024-06-19)


### Bug Fixes

* **guess-indent:** update to new `guess-ident.nvim` refactor ([96e2dc7](https://github.com/AstroNvim/AstroNvim/commit/96e2dc7864f90a659e5a09c110f086d9911a1e28))

## [4.10.4](https://github.com/AstroNvim/AstroNvim/compare/v4.10.3...v4.10.4) (2024-06-17)


### Bug Fixes

* **telescope:** ignore built-in colorschemes if possible by default since they are not compatible anyway ([0888e1d](https://github.com/AstroNvim/AstroNvim/commit/0888e1d54ede843cf70ba33c21ec40f82bdaef46))

## [4.10.3](https://github.com/AstroNvim/AstroNvim/compare/v4.10.2...v4.10.3) (2024-06-13)


### Bug Fixes

* **dressing:** use AstroUI for default prompt ([2195fc5](https://github.com/AstroNvim/AstroNvim/commit/2195fc54c3ed767ffb835f67c030bd4de853c654))

## [4.10.2](https://github.com/AstroNvim/AstroNvim/compare/v4.10.1...v4.10.2) (2024-06-11)


### Bug Fixes

* **telescope:** remove LSP mappings as they are currently broken ([4a8443b](https://github.com/AstroNvim/AstroNvim/commit/4a8443bf46f9071f016bb94e1c2367f2c9956bf2))

## [4.10.1](https://github.com/AstroNvim/AstroNvim/compare/v4.10.0...v4.10.1) (2024-06-08)


### Bug Fixes

* **dap:** dap vscode filetype definition moved upstream to `mason-nvim-dap` ([69fa069](https://github.com/AstroNvim/AstroNvim/commit/69fa069ed02f69d690cfda1e516c7e4c469e9f29))

## [4.10.0](https://github.com/AstroNvim/AstroNvim/compare/v4.9.0...v4.10.0) (2024-06-07)


### Features

* **dap:** add a basic configuration of the VS Code `launch.json` support for `nvim-dap` ([f1f7230](https://github.com/AstroNvim/AstroNvim/commit/f1f7230461fb22d945927e3f4bc3f1ef353c9449))
* **dap:** add more sophisticated JSON parsing to `launch.json` support ([c86f07d](https://github.com/AstroNvim/AstroNvim/commit/c86f07d02c779c240e236cea3f7b4c7fb8b612af))

## [4.9.0](https://github.com/AstroNvim/AstroNvim/compare/v4.8.5...v4.9.0) (2024-06-07)


### Features

* use the new `opts_extend` in lazy.nvim to make `ensure_installed` lists extend ([e095b80](https://github.com/AstroNvim/AstroNvim/commit/e095b80e89c819dad7b5d07d5a89e2516d6104b6))


### Performance Improvements

* **cmp:** improve lazy loading ([a2aeaa1](https://github.com/AstroNvim/AstroNvim/commit/a2aeaa1edccbf43b446b4885bf342526e5c8626f))

## [4.8.5](https://github.com/AstroNvim/AstroNvim/compare/v4.8.4...v4.8.5) (2024-06-06)


### Bug Fixes

* **treesitter:** fail silently if  error loading query predicates ([88c1633](https://github.com/AstroNvim/AstroNvim/commit/88c1633813a132cfa263d92f992376ddc3c8b78d)), closes [#2620](https://github.com/AstroNvim/AstroNvim/issues/2620)

## [4.8.4](https://github.com/AstroNvim/AstroNvim/compare/v4.8.3...v4.8.4) (2024-06-05)


### Bug Fixes

* **astrocore:** decrease default large buffer size from 500kb to 250kb ([dc30375](https://github.com/AstroNvim/AstroNvim/commit/dc3037573a7bc17a22907990e08a1dbab0766655))
* **telescope:** add selected icon to multiple selection ([7aaa4ef](https://github.com/AstroNvim/AstroNvim/commit/7aaa4ef670d793655190da52fe94bdf7e95d7421))

## [4.8.3](https://github.com/AstroNvim/AstroNvim/compare/v4.8.2...v4.8.3) (2024-06-03)


### Bug Fixes

* **mappings:** `gx` mapping in visual mode ([8fc1f24](https://github.com/AstroNvim/AstroNvim/commit/8fc1f2492904b2f96b611690d86a652e5271e30e))


### Reverts

* use `$LAZY` for lazy dir if it's set ([bf099f2](https://github.com/AstroNvim/AstroNvim/commit/bf099f2d2b6f49e2f8a47e304894ede7a4f2760f))

## [4.8.2](https://github.com/AstroNvim/AstroNvim/compare/v4.8.1...v4.8.2) (2024-06-01)


### Bug Fixes

* **lazy:** don't use `$LAZY` for the lazy.nvim dir ([2c25760](https://github.com/AstroNvim/AstroNvim/commit/2c25760d4ecf3c4e32dbf8a2aaa4e006f07fe15f))

## [4.8.1](https://github.com/AstroNvim/AstroNvim/compare/v4.8.0...v4.8.1) (2024-05-31)


### Bug Fixes

* **snapshot:** update `nvim-lspconfig` to get ESLint bug fix ([ced9369](https://github.com/AstroNvim/AstroNvim/commit/ced9369b624f43b2342ad08f549f32dc9bf6b4e6))

## [4.8.0](https://github.com/AstroNvim/AstroNvim/compare/v4.7.9...v4.8.0) (2024-05-30)


### Features

* backport default LSP mappings in Neovim v0.11 ([36b88be](https://github.com/AstroNvim/AstroNvim/commit/36b88bef78f9726a0b28dda936e9f42fdc7bdbeb))


### Bug Fixes

* **astrocore:** handle `vim.diagnostic` changes in neovim v0.11 ([80498ac](https://github.com/AstroNvim/AstroNvim/commit/80498ac2f0ad635922b802644813d378a7bcf5b2))

## [4.7.9](https://github.com/AstroNvim/AstroNvim/compare/v4.7.8...v4.7.9) (2024-05-28)


### Bug Fixes

* **notify:** make sure to return the `vim.notify` result ([64757c3](https://github.com/AstroNvim/AstroNvim/commit/64757c325b376c490a329d5a715659fcc027d86a))

## [4.7.8](https://github.com/AstroNvim/AstroNvim/compare/v4.7.7...v4.7.8) (2024-05-28)


### Bug Fixes

* **astrocore:** add missing `&lt;Leader&gt;/` mappings for native commenting ([42cba10](https://github.com/AstroNvim/AstroNvim/commit/42cba1043e8b26fc92221643750121d7e8e847e7))
* **astrolsp:** code action mapping should be `x` mode instead of `v` ([84db33e](https://github.com/AstroNvim/AstroNvim/commit/84db33ef993d1972c9c8b9f2c4886522673c3293))

## [4.7.7](https://github.com/AstroNvim/AstroNvim/compare/v4.7.6...v4.7.7) (2024-05-24)


### Bug Fixes

* **astrocore:** add new `enabled` key to rooter ([0cf4960](https://github.com/AstroNvim/AstroNvim/commit/0cf496075a12627c9b333a81d5ddf58634efab36))

## [4.7.6](https://github.com/AstroNvim/AstroNvim/compare/v4.7.5...v4.7.6) (2024-05-23)


### Bug Fixes

* **cmp:** improve `cmp` visibility check ([a32371a](https://github.com/AstroNvim/AstroNvim/commit/a32371ac30d9cbdc3e44908342df3059ebeae8f7))

## [4.7.5](https://github.com/AstroNvim/AstroNvim/compare/v4.7.4...v4.7.5) (2024-05-21)


### Bug Fixes

* **astroui:** do not overwrite `colors` when modified in place ([c3d90b9](https://github.com/AstroNvim/AstroNvim/commit/c3d90b987287194f4375ed96d16ff9ab0849b771))

## [4.7.4](https://github.com/AstroNvim/AstroNvim/compare/v4.7.3...v4.7.4) (2024-05-21)


### Bug Fixes

* **ts-context-commentstring:** add support for native commenting in neovim 0.10+ ([9a16612](https://github.com/AstroNvim/AstroNvim/commit/9a166127de101a5318106b149808deaee48ca61d))

## [4.7.3](https://github.com/AstroNvim/AstroNvim/compare/v4.7.2...v4.7.3) (2024-05-18)


### Bug Fixes

* **mappings:** add back next/previous diagnostic mappings to neovim 0.10 ([f0c9a3f](https://github.com/AstroNvim/AstroNvim/commit/f0c9a3fff7f6cab815dd6b38d120cdb291cd393b))
* **mappings:** add missing default diagnostic mapping backport ([b853b01](https://github.com/AstroNvim/AstroNvim/commit/b853b0154d8b8daae78668e55469973f2d5a927f))

## [4.7.2](https://github.com/AstroNvim/AstroNvim/compare/v4.7.1...v4.7.2) (2024-05-17)


### Bug Fixes

* **indent-blankline:** limit updating of `indent-blankline` in Neovim &lt;0.10 ([ce2464c](https://github.com/AstroNvim/AstroNvim/commit/ce2464c90e024289d46557aadd20039bded22d3a))

## [4.7.1](https://github.com/AstroNvim/AstroNvim/compare/v4.7.0...v4.7.1) (2024-05-16)


### Bug Fixes

* **astroui:** use single character icon for `DapLogPoint` ([c7e2437](https://github.com/AstroNvim/AstroNvim/commit/c7e2437a4f24ee876b69fc3ae7bdd49c78e38173))
* **autocmd:** typo in unlist qf description ([#2597](https://github.com/AstroNvim/AstroNvim/issues/2597)) ([c14560e](https://github.com/AstroNvim/AstroNvim/commit/c14560ed0113342aa20a951de0098fef7c233bc5))

## [4.7.0](https://github.com/AstroNvim/AstroNvim/compare/v4.6.7...v4.7.0) (2024-05-14)


### Features

* **astroui:** add `runtime_condition` support to `null-ls` statusline integration ([5686c08](https://github.com/AstroNvim/AstroNvim/commit/5686c08563a8ecac2997435c1f1849a96dab1b03))

## [4.6.7](https://github.com/AstroNvim/AstroNvim/compare/v4.6.6...v4.6.7) (2024-05-11)


### Bug Fixes

* astrocore spelling in require ([#2588](https://github.com/AstroNvim/AstroNvim/issues/2588)) ([08622d6](https://github.com/AstroNvim/AstroNvim/commit/08622d6ef4c3b8872e0757c8ae0ce7611b943c40))

## [4.6.6](https://github.com/AstroNvim/AstroNvim/compare/v4.6.5...v4.6.6) (2024-05-09)


### Bug Fixes

* add missing windows `gdu` executable name possibility ([cb24728](https://github.com/AstroNvim/AstroNvim/commit/cb247284584b972f3ee071958f04e5809315433a)), closes [#2585](https://github.com/AstroNvim/AstroNvim/issues/2585)

## [4.6.5](https://github.com/AstroNvim/AstroNvim/compare/v4.6.4...v4.6.5) (2024-05-08)


### Bug Fixes

* **cmp:** `&lt;C-N&gt;` and `<C-P>` should start completion if not started ([54c9f6a](https://github.com/AstroNvim/AstroNvim/commit/54c9f6abcd383d8021a3ff7429c6b74fa9ed8a3a))


### Performance Improvements

* **notify:** optimize performance for notification pausing/resuming ([cd57fd4](https://github.com/AstroNvim/AstroNvim/commit/cd57fd4b8c81b168940dbfaf8bae861b6aa6866f))

## [4.6.4](https://github.com/AstroNvim/AstroNvim/compare/v4.6.3...v4.6.4) (2024-05-07)


### Bug Fixes

* notification deferment not playing nicely with `nvim-notify` ([d45edb1](https://github.com/AstroNvim/AstroNvim/commit/d45edb12bcc8f3709ae77ada53b2c72daf7f683e)), closes [#2579](https://github.com/AstroNvim/AstroNvim/issues/2579)

## [4.6.3](https://github.com/AstroNvim/AstroNvim/compare/v4.6.2...v4.6.3) (2024-05-07)


### Reverts

* use main upstream for `guess-indent` as lazy gets very confused ([3d094ea](https://github.com/AstroNvim/AstroNvim/commit/3d094ea7a6dafa90ac7bf6f48ffb399b28c22b12))

## [4.6.2](https://github.com/AstroNvim/AstroNvim/compare/v4.6.1...v4.6.2) (2024-05-06)


### Bug Fixes

* **guess-indent:** update to new API for silencing indentation notifications ([4952573](https://github.com/AstroNvim/AstroNvim/commit/4952573bde22cdba7805ec7f83bb589a59701e2a))
* **mappings:** remove neovim v0.10 lsp mappings as they got reverted ([0da22af](https://github.com/AstroNvim/AstroNvim/commit/0da22afb4dcdbf360bf65aa85ef44eabf96afa72))

## [4.6.1](https://github.com/AstroNvim/AstroNvim/compare/v4.6.0...v4.6.1) (2024-05-06)


### Bug Fixes

* **autocmds:** respect modeline when forwarding events ([5bd0684](https://github.com/AstroNvim/AstroNvim/commit/5bd0684ced37db0dba3f66f10d3e6c84fd526a21))


### Performance Improvements

* **guess-indent:** improve lazy loading ([#2561](https://github.com/AstroNvim/AstroNvim/issues/2561)) ([c1e8e74](https://github.com/AstroNvim/AstroNvim/commit/c1e8e74312284223a6faa816e6b75dbfcd4d1c2e))

## [4.6.0](https://github.com/AstroNvim/AstroNvim/compare/v4.5.1...v4.6.0) (2024-05-06)


### Features

* add `:AstroVersion` for displaying current version ([168b296](https://github.com/AstroNvim/AstroNvim/commit/168b29644be57e2a59333de554b92d931c9b0566))

## [4.5.1](https://github.com/AstroNvim/AstroNvim/compare/v4.5.0...v4.5.1) (2024-05-05)


### Bug Fixes

* decouple mappings to make it easier to override them individually ([3ed1a45](https://github.com/AstroNvim/AstroNvim/commit/3ed1a453dfd079f1477fbeba3d28965a13c92df9)), closes [#2574](https://github.com/AstroNvim/AstroNvim/issues/2574)

## [4.5.0](https://github.com/AstroNvim/AstroNvim/compare/v4.4.4...v4.5.0) (2024-05-03)


### Features

* **astrolsp:** add global inlay hints toggle ([7d73045](https://github.com/AstroNvim/AstroNvim/commit/7d730458b115bdc772ac926ce7818d8673b7abc7))


### Bug Fixes

* **astrolsp:** remove unnecessary backported `&lt;C-S&gt;` mapping. This is actually a bug because it overwrites a separate AstroNvim default ([1e36e3e](https://github.com/AstroNvim/AstroNvim/commit/1e36e3e7619957a708004b85a1de2c2761f5b354))

## [4.4.4](https://github.com/AstroNvim/AstroNvim/compare/v4.4.3...v4.4.4) (2024-05-02)


### Bug Fixes

* **comment:** make `&lt;Leader&gt;/` dot-repeatable ([e2edcc7](https://github.com/AstroNvim/AstroNvim/commit/e2edcc7e197d577912d29305f67d7c995ae47353)), closes [#2410](https://github.com/AstroNvim/AstroNvim/issues/2410)
* make `git` optional in the path for execution ([b10119d](https://github.com/AstroNvim/AstroNvim/commit/b10119d295e369fabf46d2648b0ab969cbc5c0bc))

## [4.4.3](https://github.com/AstroNvim/AstroNvim/compare/v4.4.2...v4.4.3) (2024-05-01)


### Bug Fixes

* **health:** check for ripgrep (`rg`) executable ([2f43843](https://github.com/AstroNvim/AstroNvim/commit/2f438432d6de5e9bdb9c806af24964393640059e))
* **telescope:** only map Telescope's `live_grep` picker if `rg` is available ([25a7ebf](https://github.com/AstroNvim/AstroNvim/commit/25a7ebf5383becedfdd4dfe4f94f70367a20e68f))

## [4.4.2](https://github.com/AstroNvim/AstroNvim/compare/v4.4.1...v4.4.2) (2024-05-01)


### Bug Fixes

* **treesitter:** guarantee mason loads before treesitter ([cfd992f](https://github.com/AstroNvim/AstroNvim/commit/cfd992f5661016e658475e946dec12f56870f125))

## [4.4.1](https://github.com/AstroNvim/AstroNvim/compare/v4.4.0...v4.4.1) (2024-04-30)


### Bug Fixes

* **cmp:** update `vim.snippet` to use updated `active` API ([#2560](https://github.com/AstroNvim/AstroNvim/issues/2560)) ([b505f4f](https://github.com/AstroNvim/AstroNvim/commit/b505f4ff41f851fa4a008586995f79408daf72bc))
* **smart-splits:** disable aggressive lazy loading for multiplexer setup ([242f728](https://github.com/AstroNvim/AstroNvim/commit/242f728ab5431d9b7142e4efe0894b5960fb6569))
* **vim-illuminate:** add missing `large_file_cutoff` default ([782fcb0](https://github.com/AstroNvim/AstroNvim/commit/782fcb069ba7879e1ad2b43db2351dad3f9a7ea0))

## [4.4.0](https://github.com/AstroNvim/AstroNvim/compare/v4.3.0...v4.4.0) (2024-04-29)


### Features

* **mappings:** backport new default neovim diagnostic and LSP mappings ([91191e6](https://github.com/AstroNvim/AstroNvim/commit/91191e60e26d0a5f9b1fbe46cd18ce6c4873c476))


### Bug Fixes

* clear up language in update notification for AstroNvim ([8ca570a](https://github.com/AstroNvim/AstroNvim/commit/8ca570aa99e47f50274c1d804900efb54f19be1c))
* **mappings:** fix incorrectly normalized mappings ([cc66460](https://github.com/AstroNvim/AstroNvim/commit/cc66460b62dfd2929622f3b39a03d1d489f6585f))

## [4.3.0](https://github.com/AstroNvim/AstroNvim/compare/v4.2.1...v4.3.0) (2024-04-26)


### Features

* **alpha:** show the actual leader key on the dashboard ([3dabdd0](https://github.com/AstroNvim/AstroNvim/commit/3dabdd06a92f3f7af61e34bd2477005ceafc7598))


### Bug Fixes

* **autocmds:** typo in terminal_settings description ([#2552](https://github.com/AstroNvim/AstroNvim/issues/2552)) ([4b4abca](https://github.com/AstroNvim/AstroNvim/commit/4b4abca875443a3d305d1fcfa854bc3f45bc59c1))

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
