
-- directories
dirDbox = '~/Dropbox/'
dirOnedrive = '/home/dave/OneDrive/'
dirPkd = dirDbox .. 'PKD'
dirNvim = '~/.config/nvim'
dirLvimConf = '~/.config/lvim'
local fileSufixIds = '00_Private/Notes/id.txt'

-- directories for vimscript
vim.g.dirDbox = dirDbox
vim.g.dirOnedrive = dirOnedrive
vim.g.dirPkd = dirPkd
vim.g.Nvim = dirNvim
vim.g.dirLvim = dirLvim
vim.g.dirBlog =  '~/Dropbox/PKD/blog_posts/'
vim.g.sufixOut = 'out/'

-- kraxli/vim-snips
vim.g.dir_screenshots = '/home/dave/Pictures'
vim.g.dir_board = ''
vim.g.signature = "David Scherrer"

-- TODO:
-- lvim.builtin.which_key.mappings["I"] = {}
-- lvim.builtin.which_key.mappings["S"] = {}
-- lvim.builtin.which_key.mappings["I"] = {"<cmd>execute('e " .. dirOnedrive .. fileSufixIds .. "')<cr>", "Ids file"}
-- lvim.builtin.which_key.mappings["S"] = {"<cmd>execute('e " .. dirOnedrive .. fileSufixIds .. "')<cr>", "Ids file"}


vim.cmd([[

  " ┌────────────────┐
  " │ local settings │
  " └────────────────┘

  if has('unix')
    let g:python_host_prog = '/usr/bin/python'
    let g:python3_host_prog = '/usr/bin/python3'
    " let g:python3_host_prog = '/~/.pyenv/versions/python364/bin/python'

    "" To disable Python 2 support:
    " let g:loaded_python_provider = 1
  else
    let g:python3_host_prog = 'C:/ProgramData/Anaconda3-5.2.0/python.exe'
  endif


  " Commpands
  command! HelpVim :execute('e ' . g:dirOnedrive . 'VimWiki/VimCommands_learning_Vi_Vim.wiki')
  command! InstUbuntu :execute('e ' . g:dirOnedrive . 'ActiveHome/Linux/install/B_my_ubuntu_install_2018.sh')
  command! Inst :execute('e ' . g:dirOnedrive . 'ActiveHome/Linux/install/A_linux_mint_install_2019.sh')
  command! Ids :execute('e ' . g:dirOnedrive . '00_Private/Notes/id.txt')

  command! Bash :execute('e ' . g:dirOnedrive . 'SoftwareTools/Linux/Shell/bash_summary.sh')
  command! TBash :execute('e ' . g:dirOnedrive . 'SoftwareTools/Linux/Shell/bash_summary.sh')
  command! Plugins :e /home/dave/.config/nvim/config/plugins.yaml

  command! Cd2Pkd :execute('cd ' . g:dirPkd)
  command! Cd2Nvim :cd g:dirNvim
  command! Cd2D :execute('cd ' . g:dirOnedrive . '03_Coding/D')
  command! Cd2Python :execute('cd ' . g:dirOnedrive . '03_Coding/Python')

]])

