#!/bin/bash

command -v apt-get >/dev/null 2>&1 || { echo >&2 "This snippet requires apt-get. Install it please, and then run this tool again."; exit 1; }

echo "" > /tmp/debian_base-packages_install.log

echo "Starting..."

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

apt-get --yes --quiet install zsh autojump imagemagick ffmpeg zip unzip unrar-free ripgrep asciinema tmux git curl neovim detox >> /tmp/debian_base-packages_install.log
echo "Install Done... (1/1)"

echo "All Done!"
