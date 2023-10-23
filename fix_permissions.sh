#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

info "=== === ==="
info "Starting..."
info "=== === ==="

checkBin find || errorMessage "This snippet requires find. Install it please, and then run this tool again."


find $(pwd) -type f -exec chmod 644 "{}" \;
# fd --type f --exec chmod 644 {}
find $(pwd) -type d -exec chmod 755 "{}" \;
# fd --type d --exec chmod 755 {}
chown -R $SUDO_UID:$SUDO_GID $(pwd)

info "=== === ==="
info "Done!"
info "=== === ==="
