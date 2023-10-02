#!/bin/bash

echo "Starting..."

if ! command -v fd &> /dev/null
then
    echo "`fd` could not be found; https://github.com/sharkdp/fd"
    exit 1
fi

# find $(pwd) -type f -exec chmod 644 "{}" \;
fd --type f --exec chmod 644 {}
# find $(pwd) -type d -exec chmod 755 "{}" \;
fd --type d --exec chmod 755 {}
chown -R $SUDO_UID:$SUDO_GID $(pwd)

echo "Done!"
