#!/bin/sh

platform='unknown'
unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then
   platform='linux'
elif [ "$unamestr" = 'Darwin' ]; then
   platform='darwin'
fi

if [ "$platform" = "linux" ]; then
  distro=$(cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"')
  echo "Determined platform: $distro"
  if [ "$distro" = "Garuda Linux" ]; then
    sudo pacman -Syy
    sudo pacman -Su
    sudo pacman -S git curl nodejs python erlang elixir ruby rust lua go \
      typescript ghc perl shellcheck ripgrep fd lazygit ncdu nvm \
      checkmake postgresql github-cli sqlite openssl readline xz zlib gum \
      rust-analyzer iniparser fftw ncurses base-devel espeak-ng prettier \
      luarocks hledger libtool automake portaudio astyle shfmt cppcheck \
      lua-language-server bash-language-server haskell-language-server gopls
    yay -S rebar3 hadolint rbenv cava tetris-terminal-git elixir-ls
  elif [ "$distro" = "Ubuntu Linux" ]; then
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install git curl gum rust-analyzer libfftw3-dev \
      libasound2-dev libncursesw5-dev libpulse-dev libtool automake \
      cava espeak-ng
  fi
elif [ "$platform" = "darwin" ]; then
  echo "Determined platform: $platform" 
  brew update && brew upgrade
  brew install git curl node python erlang elixir ruby rust lua go \
    typescript ghc perl rebar3 shellcheck ripgrep fd lazygit ncdu \
    nvm hadolint checkmake postgresql gh openssl readline sqlite3 \
    xz zlib rbenv gum rust-analyzer fftw ncurses libtool automake \
    portaudio cava astyle shfmt cppcheck gitlint golangci-lint \
    lua-language-server elixir-ls samtay/tui/tetris espeak autoconf-archive \
    Code-Hex/tap/neo-cowsay youtube-dl achannarasappa/tap/ticker \
    circumflex hledger clang-format bash-language-server haskell-language-server \
    efm-langserver gopls 
  sudo gem update
  sudo gem install rubocop neovim
  export LIBTOOL='which glibtool'
  export LIBTOOLIZE='which glibtoolize'
  ln -s 'which glibtoolize' /usr/local/bin/libtoolize
  ln -s /usr/lib/libncurses.dylib /usr/local/lib/libncursesw.dylib
fi

curl https://pyenv.run | bash

sudo luarocks install luacheck

cargo install selene stylua macchina efmt

go install mvdan.cc/sh/v3/cmd/shfmt@latest
go install github.com/maaslalani/nap@main
go install github.com/DyegoCosta/snake-game@latest
go install github.com/maaslalani/typer@latest
go install github.com/mritd/gitflow-toolkit/v2@latest
go install github.com/ntk148v/goignore@latest

sudo gitflow-toolkit install

gh extension install dlvhdr/gh-dash

pip install flake8 black isort cmake-language-server djlint pynvim

npm i -g eslint vscode-langservers-extracted markdownlint-cli write-good \
  fixjson @fsouza/prettierd stylelint shopify-cli cross-env webpack \
  sass serverless npm-run-all nativescript dockerfile-language-server-nodejs \
  neovim

  curl -s "https://get.sdkman.io" | bash

if [ -n "$ZSH_VERSION" ]; then
  zsh_shell=true
elif [ -n "$FISH_VERSION" ]; then
  fish_shell=true
  curl -sL https://git.io/fisher | . && fisher install jorgebucaran/fisher
  fisher install reitzig/sdkman-for-fish@v1.4.0
elif [ -n "$BASH_VERSION" ]; then
  bash_shell=true
fi

