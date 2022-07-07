#!/bin/sh

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='darwin'
fi

if [[ $platform == 'linux' ]]; then
  distro=$(cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"')
  echo "Determined platform: $distro"
  if [[ $distro == 'Garuda Linux' ]]; then
    sudo pacman -Syy
    sudo pacman -Su
    sudo pacman -S git curl nodejs python erlang elixir ruby rust lua go typescript rebar3 shellcheck ripgrep fd lazygit ncdu 
  fi
elif [[ $platform == 'darwin' ]]; then
  echo "Determined platform: $platform" 
  brew update && brew upgrade
  brew install git curl node python erlang elixir ruby rust lua go typescript rebar3 shellcheck ripgrep fd lazygit ncdu hadolint checkmake
fi

sudo luarocks install luacheck
cargo install selene stylua
go install mvdan.cc/sh/v3/cmd/shfmt@latest
pip install flake8 black isort
npm i -g eslint vscode-langservers-extracted markdownlint-cli write-good fixjson @fsouza/prettierd stylelint

