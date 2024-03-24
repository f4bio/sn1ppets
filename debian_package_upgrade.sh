#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin apt-get || errorMessage "This snippet requires apt-get. Install it please, and then run this tool again."
echo "" > /tmp/debian_package_upgrade.log

info "Starting..."

export NEEDRESTART_MODE=auto

apt-get --yes --quiet update >> /tmp/debian_package_upgrade.log
debug "Update Done..."
apt-get --yes --quiet full-upgrade >> /tmp/debian_package_upgrade.log
debug "Full Upgrade Done..."
apt-get --yes --quiet autoclean >> /tmp/debian_package_upgrade.log
debug "Autoclean Done..."
apt-get --yes --quiet autoremove >> /tmp/debian_package_upgrade.log
debug "Autoremove Done..."

info "All Done!"
