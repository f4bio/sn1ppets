#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin find || errorMessage "This snippet requires fdfind. Install it please, and then run this tool again."
echo "" > /tmp/fix_permissions.log

info "Starting..."

export NEEDRESTART_MODE=a
UID="${SUDO_UID:-1000}"
GID="${SUDO_GID:-1000}"

# fdfind --type file --exec chmod o+r,g+r,u+rw >> /tmp/fix_permissions.log
find $(pwd) -type f -exec chmod o+rw,g+r,o+r "{}" \; >> /tmp/fix_permissions.log
info "Files-644 Done... (1/4)"
# fdfind --type directory --exec chmod o+rx,g+rx,u+rwx >> /tmp/fix_permissions.log
find $(pwd) -type d -exec chmod 755 "{}" \; >> /tmp/fix_permissions.log
info "Directories-755 Done... (2/4)"
chown -R $UID:$GID $(pwd) >> /tmp/fix_permissions.log
info "Chown-R Done... (3/4)"
sync >> /tmp/fix_permissions.log
info "Sync Done... (4/4)"

info "All Done!"
