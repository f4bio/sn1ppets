#!/bin/bash

command -v find >/dev/null 2>&1 || { echo >&2 "This snippet requires find. Install it please, and then run this tool again."; exit 1; }

echo "" > /tmp/fix_permissions.log

echo "Starting..."

export NEEDRESTART_MODE=a
OWNER_USER_ID="${SUDO_UID:-1000}"
OWNER_GROUP_ID="${SUDO_GID:-1000}"
TARGET_DIR="${TARGET_DIR:-$(pwd)}"

echo "OWNER_USER_ID: ${OWNER_USER_ID}"
echo "OWNER_GROUP_ID: ${OWNER_GROUP_ID}"
echo "TARGET_DIR: ${TARGET_DIR}"

# fdfind --type file --exec chmod o+r,g+r,u+rw >> /tmp/fix_permissions.log
# echo "find $TARGET_DIR -type f -exec chmod o+rw,g+r,o+r "{}" \; >> /tmp/fix_permissions.log"
find $TARGET_DIR -type f -exec chmod o+rw,g+r,o+r "{}" \; >> /tmp/fix_permissions.log
echo "Files-644 Done... (1/4)"

# fdfind --type directory --exec chmod o+rx,g+rx,u+rwx >> /tmp/fix_permissions.log
# echo "find $TARGET_DIR -type d -exec chmod 755 "{}" \; >> /tmp/fix_permissions.log"
find $TARGET_DIR -type d -exec chmod 755 "{}" \; >> /tmp/fix_permissions.log
echo "Directories-755 Done... (2/4)"

# echo "chown -R $OWNER_USER_ID:$OWNER_GROUP_ID $TARGET_DIR >> /tmp/fix_permissions.log"
chown -R $OWNER_USER_ID:$OWNER_GROUP_ID $TARGET_DIR >> /tmp/fix_permissions.log
echo "Chown-R Done... (3/4)"

# echo "sync >> /tmp/fix_permissions.log"
sync >> /tmp/fix_permissions.log
echo "Sync Done... (4/4)"

echo "All Done!"
