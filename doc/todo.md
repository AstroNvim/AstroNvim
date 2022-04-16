
# To Dos

toggle virutal text without signs:

Commands and keypbindings for

nnoremap <silent> <Plug>(toggle-lsp-diag-underline) <cmd>lua require'toggle_lsp_diagnostics'.toggle_underline()<CR>
nnoremap <silent> <Plug>(toggle-lsp-diag-signs) <cmd>lua require'toggle_lsp_diagnostics'.toggle_signs()<CR>
nnoremap <silent> <Plug>(toggle-lsp-diag-vtext) <cmd>lua require'toggle_lsp_diagnostics'.toggle_virtual_text()<CR>
nnoremap <silent> <Plug>(toggle-lsp-diag-update_in_insert) <cmd>lua require'toggle_lsp_diagnostics'.toggle_update_in_insert()<CR>
 
- [ ] add matlab support
- [ ] add vimwiki
- [ ] add Gina
- [ ] how to format with Lsp-formatter
- [ ] jbyuki/one-small-step-for-vimkind
- [ ] python virtual envs
- [ ] open link under cursor see:
  - [ ] ...
- [◐] DAP: functionality:
  - [ ] automatically open repl
  - [✓] how to bring up scope, frames, ...
  - [ ] DAP telescope? Multiple adapters?
- [ ] apply right fonts such that also luatree items are all correct (especially file types)
- [ ] machakann/vim-sandwich or appelgriebsch/surround.nvim (surround)
- [ ] Telekasten
- [ ] CheckBox:
  - [ ] toggle checkBox function:
    - lua/utils/mkd.lua  (combination of functionality of bullets.nvim and Telekasten)
    - simply apply right function with <c-space> given the line pattern (normal and visual model. Visual mode via loop)
  - [ ] Telekasten: nnoremap <leader>zt :lua require('telekasten').toggle_todo()<CR>    (does also include a box)
  - [ ] Telekasten: inoremap <leader>zt <ESC>:lua require('telekasten').toggle_todo({ i=true })<CR>
  - [ ] unmap <leader>x for ToggleCheckbox in plugin bullets.vim
  - [ ] toggle mulitple items (with loop)
- [✓] close Telescope with "q"
- [✓] LSP signature plugin?
- [✓] load local settings
- [✓] nmap: z[ z]
- [ ] markdown: open link under cursor (see vimwiki)
- [ ] Gitblame sidebar

  asdf [[00_Do_Read]]
  adf #tag

  ```vim
  let g:local_source_dir = fnamemodify(expand('<sfile>'), ':h').'/local/'

  " load local config / setting files
  if exists('g:local_source_dir') && isdirectory(g:local_source_dir)
     for file in split(globpath(g:local_source_dir, '*.vim'), '\n')
        " local/init.vim already loaded in init.vim (main init.vim file in parent directory)
        if file == g:local_source_dir . 'init.vim'
     continue
        endif
        execute 'source' file
     endfor
  endif
  ```

## Longer term / second prio

- [ ] copilot (tpope): https://github.com/github/copilot.vim
