#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
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

info "All Done!"
