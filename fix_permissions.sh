#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin find || errorMessage "This snippet requires find. Install it please, and then run this tool again."
echo "" > /tmp/fix_permissions.log

info "Starting..."

export NEEDRESTART_MODE=a

#find $(pwd) -type f -exec chmod o+rw,g+r,o+r "{}" \; >> /tmp/fix_permissions.log
fdfind --type file --exec chmod o+rw,g+r,o+r >> /tmp/fix_permissions.log
info "Files-644 Done... (1/4)"
#find $(pwd) -type d -exec chmod 755 "{}" \; >> /tmp/fix_permissions.log
fdfind --type directory --exec chmod o+rwx,g+rx,o+rx >> /tmp/fix_permissions.log
info "Directories-755 Done... (2/4)"
chown -R $SUDO_UID:$SUDO_GID $(pwd) >> /tmp/fix_permissions.log
info "Chown-R Done... (3/4)"
sync >> /tmp/fix_permissions.log
info "Sync Done... (4/4)"

info "All Done!"
