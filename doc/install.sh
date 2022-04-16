
#######################################################
# pre-requisits
#######################################################

# homebrew: https://www.how2shout.com/linux/how-to-install-brew-ubuntu-20-04-lts-linux/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
# echo 'export "PATH=$PATH:~/linuxbrew/.linuxbrew/bin/brew" >> ~/.zshrc'
# echo 'export "PATH=$PATH:~/linuxbrew/.linuxbrew/bin/brew" >> ~/.bashrc'
brew install gcc
brew doctor

sudo apt -y install npm

#######################################################
# install packages and tools
#######################################################

# -- general --
sudo apt-get install xclip

# -- markdwon --
sudo npm install -g markdownlint-cli
brew install vale
yarn add mermaid

# python:
sudo pip install pyright pylsp
sudo python3 -m pip install pyright pyls

# -- lazy git --
sudo add-apt-repository ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install lazygit

# =======================================================

# brew install luarocks
# luarocks install luacheck  # if you want to use luacheck
cargo install selene  # if you want to use selene instead of luacheck
# brew install hadolint  # if you want to lint dockerfiles
pip install vim-vint  # for vim linting
# install llvm and clang_format for clang stuff
npm install -g @fsouza/prettierd # if you want to use prettierd
pip install yapf flake8 black  # for python stuff

# if you want to use the markdown thingy
# brew install vale markdownlint-cli
# cp -r ~/.config/lvim/.vale ~/.config/vale
# fix the address inside .vale.ini
# cp ~/.config/lvim/vale_config.ini ~/.vale.ini
# if you want the latex stuff
# brew install --cask mactex-no-gui # for mac
# or install zathura and chktex on linux
`
