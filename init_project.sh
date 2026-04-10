#!/bin/bash

command -v curl >/dev/null 2>&1 || { echo >&2 "This snippet requires curl. Install it please, and then run this tool again."; exit 1; }

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

  curl -fsSL -o "$localName" "$remoteUrl"
done

info "All Done!"
