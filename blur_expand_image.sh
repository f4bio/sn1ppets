#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
source "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin magick || errorMessage "This snippet requires imagemagick. Install it please, and then run this tool again."
checkBin bc || errorMessage "This snippet requires bc. Install it please, and then run this tool again."

filesDone=0
dimension="1920x1080"
extensions="png"
filesCount=$(ls -1 *."$extensions" | wc -l)

echo "expanding $filesCount \*\.$extensions-files to $dimension"
mkdir -p ./_originals

for currentFile in *."$extensions"; do
	outFile="${currentFile%.*}-expanded"
  outFileExtension="${currentFile##*.}"
	echo "processing: $currentFile..."
	magick \
		-size "$dimension" xc:skyblue \
		"$currentFile" -blur 0x25 -geometry "$dimension" -gravity northwest -composite \
		"$currentFile" -geometry "$dimension" -blur 0x25 -gravity southeast -composite \
		"$currentFile" -geometry "$dimension" -gravity center -composite \
		"$outFile.$outFileExtension"
	filesDone=$((filesDone+1))
	percentDone=$(echo "$filesDone / $filesCount * 100" | bc -l)
	echo "$percentDone% done ($filesDone of $filesCount files)"
	mv "$currentFile" "_originals/$currentFile"
done
