#!/bin/bash

## script-commons:
currentDir=$(dirname "$(command -v "$0")")
scriptsCommonUtilities="$currentDir/scripts-common/utilities.sh"
[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must initialize your git submodule once after you cloned the repository:\ngit submodule init\ngit submodule update" >&2 && exit 1
# shellcheck disable=1090
. "$scriptsCommonUtilities"
## :script-commons

checkBin awk || errorMessage "This snippet requires awk. Install it please, and then run this tool again."
checkBin asdf || errorMessage "This snippet requires asdf. Install it please, and then run this tool again."

info "\n\nStarting...\n\n"

pluginNames=$(asdf current | awk '{print $1, $8}')

for p in $pluginNames; do
    asdf install $p latest
done

info "\n\nDone!\n\n"
