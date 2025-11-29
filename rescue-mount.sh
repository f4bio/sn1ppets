#!/bin/bash

lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID


mkdir /mnt/root
mount /dev/md124 /mnt/root
mount /dev/md125 /mnt/root/boot

mount --bind /dev /mnt/root/dev
mount --bind /dev/pts /mnt/root/dev/pts
mount --bind /sys /mnt/root/sys
mount -t proc none /mnt/root/proc
mount -t tmpfs tmpfs /mnt/root/tmp

chroot /mnt/root
