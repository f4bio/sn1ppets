#!/bin/bash

echo "Starting..."

apt-get --yes update
apt-get --yes full-upgrade
apt-get --yes autoclean
apt-get --yes autoremove

echo "Done!"
