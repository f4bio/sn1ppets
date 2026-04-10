#!/bin/bash

command -v gh >/dev/null 2>&1 || { echo >&2 "This snippet requires github-cli. Install it please, and then run this tool again."; exit 1; }

info "Starting..."

echo "This will delete up to 20 workflow runs for the current repository."

gh run list --json databaseId -q '.[].databaseId' | xargs -IID gh run delete ID

info "All Done!"
