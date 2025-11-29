#!/bin/bash

command -v apt-get >/dev/null 2>&1 || { echo >&2 "This snippet requires apt-get. Install it please, and then run this tool again."; exit 1; }

echo "---" >> /tmp/debian_package_upgrade.log

echo "Starting..."

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

apt-get --yes --quiet update 2> /tmp/debian_package_upgrade.log
echo "Update Done... (1/4)"
apt-get --yes --quiet full-upgrade 2> /tmp/debian_package_upgrade.log
echo "Full Upgrade Done... (2/4)"
apt-get --yes --quiet autoclean 2> /tmp/debian_package_upgrade.log
echo "Autoclean Done... (3/4)"
apt-get --yes --quiet autoremove 2> /tmp/debian_package_upgrade.log
echo "Autoremove Done... (4/4)"

echo "All Done!"
