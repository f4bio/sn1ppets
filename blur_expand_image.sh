#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin magick || errorMessage "This snippet requires imagemagick. Install it please, and then run this tool again."

filesDone=0
dimension="1920x1080"
extension="jpg"
filesCount=$(ls -1 *."$extension" | wc -l)

echo "expanding $filesCount \*\.$extension-files to $dimension"
mkdir -p ./_originals

for currentFile in *."$extension"; do
	outFile="${currentFile%.*}-expanded"
	echo "processing: $currentFile..."
	magick \
		-size "$dimension" xc:skyblue \
		"$currentFile" -blur 0x25 -geometry "$dimension" -gravity northwest -composite \
		"$currentFile" -geometry "$dimension" -blur 0x25 -gravity southeast -composite \
		"$currentFile" -geometry "$dimension" -gravity center -composite \
		"$outFile.$extension"
	filesDone=$((filesDone+1))
	percentDone=$((filesDone/filesCount*100))
	echo "$percentDone% done ($filesDone of $filesCount files)"
	mv "$currentFile" "_originals/$currentFile"
done
