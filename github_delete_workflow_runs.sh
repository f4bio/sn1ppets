#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin gh || errorMessage "This snippet requires github-cli. Install it please, and then run this tool again."

info "=== === ==="
info "Starting..."
info "=== === ==="

echo "This will delete up to 20 workflow runs for the current repository."

gh run list --json databaseId -q '.[].databaseId' | xargs -IID gh run delete ID

info "=== === ==="
info "Done!"
info "=== === ==="
