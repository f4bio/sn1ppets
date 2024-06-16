#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin apt-get || errorMessage "This snippet requires apt-get. Install it please, and then run this tool again."

runDateTime=$(getFormattedDatetime '%Y-%m-%d-%H-%M-%S')
echo "---" > /tmp/debian_package_upgrade.log
echo "$runDateTime" >> /tmp/debian_package_upgrade.log
echo "---" >> /tmp/debian_package_upgrade.log

info "Starting..."

export NEEDRESTART_MODE=a

apt-get --yes --quiet update 2> /tmp/debian_package_upgrade.log
info "Update Done... (1/4)"
apt-get --yes --quiet full-upgrade 2> /tmp/debian_package_upgrade.log
info "Full Upgrade Done... (2/4)"
apt-get --yes --quiet autoclean 2> /tmp/debian_package_upgrade.log
info "Autoclean Done... (3/4)"
apt-get --yes --quiet autoremove 2> /tmp/debian_package_upgrade.log
info "Autoremove Done... (4/4)"

info "All Done!"
