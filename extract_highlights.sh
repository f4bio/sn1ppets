#!/bin/bash

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "This snippet requires ffmpeg. Install it please, and then run this tool again."; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo >&2 "This snippet requires ffprobe. Install it please, and then run this tool again."; exit 1; }
command -v vimg >/dev/null 2>&1 || { echo >&2 "This snippet requires vimg. Install it please, and then run this tool again."; exit 1; }

# --- PARSE ARGUMENTS ---
DEBUG=0
INPUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--debug) 
            DEBUG=1 
            ;;
        -*) 
            echo "Error: Unknown parameter passed: $1"
            echo "Usage: $0 [-d|--debug] <input_video>"
            exit 1 
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            else
                echo "Error: Only one input video is allowed."
                exit 1
            fi
            ;;
    esac
    shift
done

# Check if input file was provided
if [ -z "$INPUT_FILE" ]; then
    echo "Error: Missing input video."
    echo "Usage: $0 [-d|--debug] <input_video>"
    echo "Example: $0 movie.mp4"
    exit 1
fi

# Set FFmpeg log level based on the debug flag
if [ "$DEBUG" -eq 1 ]; then
    LOG_LEVEL="info"
else
    LOG_LEVEL="error" # 'error' makes FFmpeg completely silent unless it crashes
fi

# 1. Extract the base name (everything before the .mp4 extension)
BASE_NAME="${INPUT_FILE%.*}"

# 2. Assign the exact hyphenated names
FINAL_TMP_OUTPUT="/tmp/${BASE_NAME}-highlights.mp4"
FINAL_TMP_WEBP="/tmp/${BASE_NAME}-highlights.webp"
FINAL_TMP_CONCAT_WEBP="/tmp/${BASE_NAME}-concatsheet.webp"

# Hardcoded temporary directory
TEMP_DIR=$(mktemp -d)
TEMP_CONCAT_SHEET="$TEMP_DIR/temp_concatsheet.avif"

# Set up cleanup trap
trap "rm -rf '$TEMP_DIR'" EXIT

# --- CONFIGURATION ---
CLIP_DURATION=1          # Length of each extracted clip (in seconds)
MAX_FINAL_DURATION=20    # Maximum length of final video (in seconds)
OFFSET_PERCENT=5         # Percentage of video to skip at the start and end
# ---------------------

TARGET_CLIPS=$((MAX_FINAL_DURATION / CLIP_DURATION))

if [ "$TARGET_CLIPS" -le 0 ]; then
    echo "Error: Invalid target clips calculation."
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

if [ ! -r "$INPUT_FILE" ]; then
    echo "Error: Cannot read input file '$INPUT_FILE'."
    exit 1
fi

# Get total video duration
TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
TOTAL_DURATION=${TOTAL_DURATION%.*}

if [ -z "$TOTAL_DURATION" ] || [ "$TOTAL_DURATION" -le 0 ]; then
    echo "Error: Could not determine video duration. Is ffprobe installed and valid?"
    exit 1
fi

# --- DYNAMIC MATH ---
START_OFFSET=$((TOTAL_DURATION * OFFSET_PERCENT / 100))
END_OFFSET=$((TOTAL_DURATION * OFFSET_PERCENT / 100))
AVAILABLE_DURATION=$((TOTAL_DURATION - START_OFFSET - END_OFFSET))
END_TIME=$((TOTAL_DURATION - END_OFFSET))

if [ "$AVAILABLE_DURATION" -le 0 ]; then
    echo "Error: Video ($TOTAL_DURATION sec) is too short for a $OFFSET_PERCENT% offset."
    exit 1
fi

STEP=$((AVAILABLE_DURATION / TARGET_CLIPS))

if [ "$STEP" -le "$CLIP_DURATION" ]; then
    STEP=$((CLIP_DURATION + 1))
    if [ "$DEBUG" -eq 1 ]; then echo "Warning: Video is very short. Spacing tightly."; fi
fi

mkdir -p "$TEMP_DIR"
CONCAT_LIST="$TEMP_DIR/concat_list.txt"
> "$CONCAT_LIST"

# --- PROGRESS BAR FUNCTION ---
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$(( current * 100 / total ))
    local filled=$(( width * current / total ))
    local empty=$(( width - filled ))

    # Create strings of spaces, then replace them with # and -
    printf -v filled_str "%${filled}s" ""
    printf -v empty_str "%${empty}s" ""
    printf "\r[${filled_str// /#}${empty_str// /-}] %d%%" "$percent"
}

# --- SCRIPT EXECUTION ---
echo "Input Video: $INPUT_FILE ($TOTAL_DURATION seconds)"
if [ "$DEBUG" -eq 1 ]; then
    echo "Skipping first $START_OFFSET sec and last $END_OFFSET sec."
    echo "Target: ~$TARGET_CLIPS clips spaced $STEP seconds apart."
fi

CURRENT_TIME=$START_OFFSET
COUNTER=0
CLIP_COUNT=0
TOTAL_STEPS=$(( TARGET_CLIPS + 4 ))

# Step 1: Extract the clips
while [ $CURRENT_TIME -lt $END_TIME ] && [ $CLIP_COUNT -lt $TARGET_CLIPS ]; do
    PADDED_COUNTER=$(printf "%03d" $CLIP_COUNT)
    CLIP_NAME="clip_${PADDED_COUNTER}.mp4"
    OUTPUT_FILE="${TEMP_DIR}/${CLIP_NAME}"

    if [ "$DEBUG" -eq 1 ]; then
        echo "Extracting clip $PADDED_COUNTER at timestamp ${CURRENT_TIME}s..."
    else
        draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    fi

    ffmpeg -y -ss "$CURRENT_TIME" -i "$INPUT_FILE" -t "$CLIP_DURATION" -c:v libx264 -preset fast -c:a aac "$OUTPUT_FILE" -loglevel "$LOG_LEVEL" || { echo "Error: Failed to extract clip $PADDED_COUNTER."; exit 1; }

    echo "file '$CLIP_NAME'" >> "$CONCAT_LIST"

    CURRENT_TIME=$(( CURRENT_TIME + STEP ))
    COUNTER=$(( COUNTER + 1))
    CLIP_COUNT=$(( CLIP_COUNT + 1))
done

# Print final 100% progress bar and clear the line if not in debug mode
if [ "$DEBUG" -eq 0 ]; then
    draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    echo "" 
fi

# Step 2: Stitch the clips
echo "Stitching clips into final MP4..."
ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$FINAL_TMP_OUTPUT" -loglevel "$LOG_LEVEL" || { echo "Error: Failed to stitch clips."; exit 1; }
COUNTER=$(( COUNTER + 1))
if [ "$DEBUG" -eq 0 ]; then
    draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    echo "" 
fi

# Step 3: Convert to WebP
echo "Converting MP4 to animated WebP..."
ffmpeg -y -i "$FINAL_TMP_OUTPUT" -vcodec libwebp -vf "fps=15,scale=800:-1:flags=lanczos" -lossless 0 -q:v 70 -loop 0 -an "$FINAL_TMP_WEBP" -loglevel "$LOG_LEVEL" || { echo "Error: Failed to convert to WebP."; exit 1; }
COUNTER=$(( COUNTER + 1 ))
if [ "$DEBUG" -eq 0 ]; then
    draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    echo "" 
fi

# Step 4: Generate Concat Sheet
echo "Generating animated contact sheet..."
# Updated: --capture-frames=40 applied below
if [ "$DEBUG" -eq 1 ]; then
    vimg vcs --columns=4 --number=24 --capture-width=350 --capture-frames=40 --ignore-start=${START_OFFSET}s --ignore-end=${END_OFFSET}s --output="$TEMP_CONCAT_SHEET" "$INPUT_FILE" || { echo "Error: Failed to generate contact sheet."; exit 1; }
else
    vimg vcs --columns=4 --number=24 --capture-width=350 --capture-frames=40 --ignore-start=${START_OFFSET}s --ignore-end=${END_OFFSET}s --output="$TEMP_CONCAT_SHEET" "$INPUT_FILE" > /dev/null 2>&1 || { echo "Error: Failed to generate contact sheet."; exit 1; }
fi
COUNTER=$(( COUNTER + 1 ))
if [ "$DEBUG" -eq 0 ]; then
    draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    echo ""
fi

# Step 5: Convert Concat Sheet to WebP
echo "Converting contact sheet to WebP..."
ffmpeg -y -i "$TEMP_CONCAT_SHEET" -vcodec libwebp -lossless 0 -q:v 70 -loop 0 "$FINAL_TMP_CONCAT_WEBP" -loglevel "$LOG_LEVEL" || { echo "Error: Failed to convert contact sheet to WebP."; exit 1; }
COUNTER=$(( COUNTER + 1 ))
if [ "$DEBUG" -eq 0 ]; then
    draw_progress_bar "$COUNTER" "$TOTAL_STEPS"
    echo "" 
fi

# Step 6: Cleanup
rm -rf "$TEMP_DIR"

ACTUAL_FINAL_DURATION=$(( CLIP_COUNT * CLIP_DURATION ))

FINAL_OUTPUT="${BASE_NAME}-highlights.mp4"
FINAL_WEBP="${BASE_NAME}-highlights.webp"
FINAL_CONCAT_WEBP="${BASE_NAME}-concatsheet.webp"

if [ -f "$FINAL_OUTPUT" ]; then echo "Warning: Overwriting existing $FINAL_OUTPUT"; fi
mv "$FINAL_TMP_OUTPUT" "$FINAL_OUTPUT"
if [ -f "$FINAL_WEBP" ]; then echo "Warning: Overwriting existing $FINAL_WEBP"; fi
mv "$FINAL_TMP_WEBP" "$FINAL_WEBP"
if [ -f "$FINAL_CONCAT_WEBP" ]; then echo "Warning: Overwriting existing $FINAL_CONCAT_WEBP"; fi
mv "$FINAL_TMP_CONCAT_WEBP" "$FINAL_CONCAT_WEBP"

echo "======================================"
echo "Success! Processing complete."
echo "🎬 Highlights MP4 saved as:   $FINAL_OUTPUT ($ACTUAL_FINAL_DURATION seconds)"
echo "🖼️  Highlights WebP saved as: $FINAL_WEBP"
echo "🗂️  Contact Sheet WebP saved: $FINAL_CONCAT_WEBP"
echo "======================================"
