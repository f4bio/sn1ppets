#!/bin/bash

## script-commons:
currentDir=$(dirname "$(command -v "$0")")
scriptsCommonUtilities="$currentDir/scripts-common/utilities.sh"
[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must initialize your git submodule once after you cloned the repository:\ngit submodule init\ngit submodule update" >&2 && exit 1
# shellcheck disable=1090
. "$scriptsCommonUtilities"
## :script-commons

checkBin curl || errorMessage "This snippet requires curl. Install it please, and then run this tool again."

info "Starting..."

fileNames=(
    "dot_commitlintrc.yml"
    "dot_editorconfig"
    "dot_eslintrc.yml"
    "dot_eslintignore"
    "dot_dockerignore"
    "dot_gitignore"
    "dot_gowebly.yml"
    "dot_htmllinrc.json"
    "dot_pre-commit-config.yaml"
    "dot_prettierignore"
    "dot_prettierrc.yaml"
    "dot_stylelintignore"
    "dot_stylelintrc.json"
    "dot_tools-versions"
    "Dockerfile"
    "LICENSE"
    "package.json"
    "postcss.config.js"
    "README.md"
    "tailwind.config.js"
)

for f in $fileNames; do
    localName=$(echo "$f" | sed "s/^dot_/./g")
    remoteUrl="https://raw.githubusercontent.com/f4bio/sn1ppets/main/assets/$f"

    getURLContents $remoteUrl $localName
done

info "Done!"
