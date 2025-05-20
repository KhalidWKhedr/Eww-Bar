#!/usr/bin/env bash

# Source configuration
source "$(dirname "$0")/../config.sh"

# Generate output filename
outputFile="snapshot_$(date +%Y-%m-%d_%H-%M-%S).png"
outputPath="$SCREENSHOT_DIR/$outputFile"

# Create screenshot directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Get mode from argument or default to area
mode=${1:-area}

# Validate mode
case "$mode" in
    active|output|area)
        log "Taking $mode screenshot"
        ;;
    *)
        log "Invalid option: $mode" "ERROR"
        log "Usage: $0 {active|output|area}" "ERROR"
        exit 1
        ;;
esac

# Take the screenshot
command="grimblast copysave $mode $outputPath"
if ! eval "$command" 2>/dev/null; then
    log "Failed to take screenshot" "ERROR"
    exit 1
fi

# Get the most recent screenshot
recentFile=$(find "$SCREENSHOT_DIR" -name 'snapshot_*.png' -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-)

if [ -z "$recentFile" ]; then
    log "Failed to find recent screenshot" "ERROR"
    exit 1
fi

# Send notification
if ! notify-send "Grimblast" "Your snapshot has been saved." \
    -i video-x-generic \
    -a "Grimblast" \
    -t "$NOTIFICATION_TIMEOUT" \
    -u normal \
    --action="scriptAction:-xdg-open $SCREENSHOT_DIR=Directory" \
    --action="scriptAction:-xdg-open $recentFile=View" 2>/dev/null; then
    log "Failed to send notification" "WARNING"
fi

log "Screenshot saved to $outputPath"