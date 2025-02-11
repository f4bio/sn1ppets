#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin awk || errorMessage "This snippet requires awk. Install it please, and then run this tool again."
checkBin asdf || errorMessage "This snippet requires asdf. Install it please, and then run this tool again."

info "Starting..."

pluginNames=$(asdf current | awk '{print $1, $8}')

for p in $pluginNames; do
    asdf install $p latest
done

info "All Done!"
