#!/bin/bash

command -v awk >/dev/null 2>&1 || { echo >&2 "This snippet requires awk. Install it please, and then run this tool again."; exit 1; }
command -v asdf >/dev/null 2>&1 || { echo >&2 "This snippet requires asdf. Install it please, and then run this tool again."; exit 1; }

info "Starting..."

pluginNames=$(asdf current | awk '{print $1, $8}')

for p in $pluginNames; do
    asdf install $p latest
done

info "All Done!"
