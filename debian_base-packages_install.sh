#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin apt-get || errorMessage "This snippet requires apt-get. Install it please, and then run this tool again."

info "=== === ==="
info "Starting..."
info "=== === ==="

apt-get --yes install zsh imagemagick ffmpeg zip unzip rar unrar ripgrep asciinema tmux git curl neovim detox

info "=== === ==="
info "Done!"
info "=== === ==="
