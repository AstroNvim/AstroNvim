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
      checkmake postgresql github-cli sqlite openssl readline xz zlib
    yay -S rebar3 hadolint rbenv
  elif [ "$distro" = "Ubuntu Linux" ]; then
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install git curl
  fi
elif [ "$platform" = "darwin" ]; then
  echo "Determined platform: $platform" 
  brew update && brew upgrade
  brew install git curl node python erlang elixir ruby rust lua go \
    typescript ghc perl rebar3 shellcheck ripgrep fd lazygit ncdu \
    nvm hadolint checkmake postgresql gh openssl readline sqlite3 \
    xz zlib rbenv
fi

curl https://pyenv.run | bash
sudo luarocks install luacheck
cargo install selene stylua macchina
go install mvdan.cc/sh/v3/cmd/shfmt@latest
pip install flake8 black isort
npm i -g eslint vscode-langservers-extracted markdownlint-cli write-good \
  fixjson @fsouza/prettierd stylelint shopify-cli cross-env webpack \
  sass serverless npm-run-all nativescript
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

