#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin apt-get || errorMessage "This snippet requires apt-get. Install it please, and then run this tool again."
echo "" > /tmp/debian_base-packages_install.log

info "Starting..."

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

apt-get --yes --quiet install zsh autojump imagemagick ffmpeg zip unzip unrar-free ripgrep asciinema tmux git curl neovim detox >> /tmp/debian_base-packages_install.log
info "Install Done... (1/1)"

info "All Done!"
