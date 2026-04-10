#!/bin/bash

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "This snippet requires ffmpeg. Install it please, and then run this tool again."; exit 1; }

# Check if at least 1 argument is provided
if [ "$#" -lt 1 ]; then
    echo "Error: Missing input video."
    echo "Usage: $0 <input_video> [final_output_name] [temp_directory]"
    echo "Example: $0 movie.mp4"
    exit 1
fi

INPUT_FILE="$1"
FINAL_OUTPUT="${2:-${INPUT_FILE%.*}_highlights.mp4}"
FINAL_WEBP="${FINAL_OUTPUT%.*}.webp" # Automatically replace .mp4 with .webp
TEMP_DIR="${3:-./temp_clips}"

# --- CONFIGURATION ---
CLIP_DURATION=1          # Length of each extracted clip (in seconds)
MAX_FINAL_DURATION=20    # Maximum length of the final stitched video (in seconds)
OFFSET_PERCENT=5         # Percentage of video to skip at the start and end
# ---------------------

TARGET_CLIPS=$((MAX_FINAL_DURATION / CLIP_DURATION))

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Get total video duration in seconds using ffprobe
TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
TOTAL_DURATION=${TOTAL_DURATION%.*} # Truncate decimals

if [ -z "$TOTAL_DURATION" ] || [ "$TOTAL_DURATION" -le 0 ]; then
    echo "Error: Could not determine video duration. Is ffprobe installed and is this a valid video?"
    exit 1
fi

# --- DYNAMIC MATH ---
START_OFFSET=$((TOTAL_DURATION * OFFSET_PERCENT / 100))
END_OFFSET=$((TOTAL_DURATION * OFFSET_PERCENT / 100))

AVAILABLE_DURATION=$((TOTAL_DURATION - START_OFFSET - END_OFFSET))
END_TIME=$((TOTAL_DURATION - END_OFFSET))

# Safety check
if [ "$AVAILABLE_DURATION" -le 0 ]; then
    echo "Error: Video ($TOTAL_DURATION sec) is too short to process with a $OFFSET_PERCENT% offset."
    exit 1
fi

STEP=$((AVAILABLE_DURATION / TARGET_CLIPS))

if [ "$STEP" -le "$CLIP_DURATION" ]; then
    STEP=$((CLIP_DURATION + 1))
    echo "Warning: Video is very short. Spacing clips tightly."
fi

# Create a fresh temporary directory
mkdir -p "$TEMP_DIR"
CONCAT_LIST="$TEMP_DIR/concat_list.txt"
> "$CONCAT_LIST"

echo "Input Video: $INPUT_FILE"
echo "Total duration: $TOTAL_DURATION seconds."
echo "Skipping first $START_OFFSET seconds and last $END_OFFSET seconds."
echo "Extracting ~$TARGET_CLIPS clips to keep final video under $MAX_FINAL_DURATION seconds."
echo "Extracting into '$TEMP_DIR/'..."

CURRENT_TIME=$START_OFFSET
COUNTER=0

# Step 1: Extract the clips
while [ $CURRENT_TIME -lt $END_TIME ] && [ $COUNTER -lt $TARGET_CLIPS ]; do
    PADDED_COUNTER=$(printf "%03d" $COUNTER)
    CLIP_NAME="clip_${PADDED_COUNTER}.mp4"
    OUTPUT_FILE="${TEMP_DIR}/${CLIP_NAME}"

    echo "Extracting clip $PADDED_COUNTER at timestamp ${CURRENT_TIME}s..."

    # Extract the individual clip
    ffmpeg -y -ss "$CURRENT_TIME" -i "$INPUT_FILE" -t "$CLIP_DURATION" -c:v libx264 -preset fast -c:a aac "$OUTPUT_FILE" -loglevel warning

    # Add the filename to the concat list
    echo "file '$CLIP_NAME'" >> "$CONCAT_LIST"

    CURRENT_TIME=$((CURRENT_TIME + STEP))
    COUNTER=$((COUNTER + 1))
done

echo "Extracted $COUNTER clips. Stitching them together into MP4..."

# Step 2: Stitch the clips together into the final MP4
ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$FINAL_OUTPUT" -loglevel warning

# Step 3: Convert the stitched MP4 into an optimized animated WebP
echo "Converting MP4 into an optimized animated WebP..."
# -vf: drops framerate to 15, scales width to 800px (keeps aspect ratio)
# -loop 0: loops infinitely
# -an: removes audio stream
ffmpeg -y -i "$FINAL_OUTPUT" -vcodec libwebp -vf "fps=15,scale=800:-1:flags=lanczos" -lossless 0 -q:v 70 -loop 0 -an "$FINAL_WEBP" -loglevel warning

# Step 4: Clean up the artifacts
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

ACTUAL_FINAL_DURATION=$((COUNTER * CLIP_DURATION))
echo "Success! Processing complete."
echo "🎬 Video saved as: $FINAL_OUTPUT ($ACTUAL_FINAL_DURATION seconds)"
echo "🖼️  Animation saved as: $FINAL_WEBP"
