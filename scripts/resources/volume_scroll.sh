#!/bin/bash

# Source configuration
source "$(dirname "$0")/../config.sh"

# Log file for volume changes
VOLUME_LOG="$LOG_DIR/current_volume"

# Get the scroll direction from the event
DIRECTION=$1

if [ -z "$DIRECTION" ]; then
    log "Usage: $0 [up|down]" "ERROR"
    exit 1
fi

# Change volume based on the direction
if [ "$DIRECTION" == "up" ]; then
    log "Increasing volume by ${VOLUME_INCREMENT}%"
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${VOLUME_INCREMENT}%+" 2>/dev/null
    handle_error $? "Failed to increase volume"
elif [ "$DIRECTION" == "down" ]; then
    log "Decreasing volume by ${VOLUME_INCREMENT}%"
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${VOLUME_INCREMENT}%-" 2>/dev/null
    handle_error $? "Failed to decrease volume"
else
    log "Invalid direction: $DIRECTION" "ERROR"
    exit 1
fi

# After changing, fetch the updated volume level
current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%d", $2 * 100}')
handle_error $? "Failed to get current volume"

# Get the last logged volume
last_logged_volume=$(tail -n 1 "$VOLUME_LOG" 2>/dev/null || echo "0")

# Only append if the new volume is different from the last one
if [ "$current_volume" != "$last_logged_volume" ]; then
    log "Volume changed to $current_volume%"
    echo "$current_volume" >> "$VOLUME_LOG"
fi
