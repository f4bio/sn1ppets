#!/bin/bash

echo "Starting..."

find $(pwd) -type f -exec chmod 644 "{}" \;
find $(pwd) -type d -exec chmod 755 "{}" \;
chown -R $SUDO_UID:$SUDO_GID $(pwd)

echo "Done!"
