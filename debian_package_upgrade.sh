#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin apt-get || errorMessage "This snippet requires apt-get. Install it please, and then run this tool again."

info "\nStarting...\n"

export NEEDRESTART_MODE=auto

apt-get --yes --quiet update
info "Update Done...\n"
apt-get --yes --quiet full-upgrade
info "Full Upgrade Done...\n"
apt-get --yes --quiet autoclean
info "Autoclean Done...\n"
apt-get --yes --quiet autoremove
info "Autoremove Done...\n"

info "\nAll Done!\n"
