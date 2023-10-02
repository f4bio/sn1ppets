#!/bin/bash

## script-commons:
#currentDir=$( dirname "$( command -v "$0" )" )
#scriptsCommonUtilities="$currentDir/scripts-common/utilities.sh"
#[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must initialize your git submodule once after you cloned the repository:\ngit submodule init\ngit submodule update" >&2 && exit 1
# shellcheck disable=1090
#. "$scriptsCommonUtilities"
## :script-commons

echo "Starting..."

apt-get --yes install zsh imagemagick ffmpeg zip unzip rar unrar ripgrep asciinema tmux git curl neovim detox

echo "Done!"
