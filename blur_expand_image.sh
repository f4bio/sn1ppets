#!/bin/bash

command -v magick >/dev/null 2>&1 || { echo >&2 "This snippet requires imagemagick. Install it please, and then run this tool again."; exit 1; }
command -v bc >/dev/null 2>&1 || { echo >&2 "This snippet requires bc. Install it please, and then run this tool again."; exit 1; }

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
