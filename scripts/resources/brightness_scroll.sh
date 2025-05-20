#!/usr/bin/env bash

# Source configuration
source "$(dirname "$0")/../config.sh"

# Log file for brightness changes
BRIGHTNESS_LOG="$LOG_DIR/current_brightness"

get_brightness_values() {
    local current max
    current=$(brightnessctl -d "$BRIGHTNESS_DEVICE" g 2>/dev/null)
    handle_error $? "Failed to get current brightness"
    
    max=$(brightnessctl -d "$BRIGHTNESS_DEVICE" m 2>/dev/null)
    handle_error $? "Failed to get max brightness"
    
    echo "$current $max"
}

get_brightness_percentage() {
    local values current max
    values=($(get_brightness_values))
    current=${values[0]}
    max=${values[1]}
    
    if [ -z "$current" ] || [ -z "$max" ]; then
        log "Failed to get brightness values" "ERROR"
        exit 1
    fi
    
    echo $((current * 100 / max))
}

set_brightness() {
    local percentage=$1
    if [[ "$percentage" -gt 100 ]]; then
        percentage=100
    elif [[ "$percentage" -lt 0 ]]; then
        percentage=0
    fi
    
    log "Setting brightness to $percentage%"
    brightnessctl -d "$BRIGHTNESS_DEVICE" set "${percentage}%" 2>/dev/null
    handle_error $? "Failed to set brightness"
    
    echo "$percentage" >> "$BRIGHTNESS_LOG"
}

adjust_brightness() {
    local direction=$1
    local current_percentage new_percentage
    
    current_percentage=$(get_brightness_percentage)
    log "Current brightness percentage: $current_percentage"

    if [[ "$direction" == "up" ]]; then
        new_percentage=$((current_percentage + BRIGHTNESS_INCREMENT))
        [[ "$new_percentage" -gt 100 ]] && new_percentage=100
    elif [[ "$direction" == "down" ]]; then
        new_percentage=$((current_percentage - BRIGHTNESS_INCREMENT))
        [[ "$new_percentage" -lt 0 ]] && new_percentage=0
    else
        log "Invalid direction: $direction" "ERROR"
        exit 1
    fi

    set_brightness "$new_percentage"
}

# Main script
if [[ -z "$1" ]]; then
    log "Usage: $0 [up|down]" "ERROR"
    exit 1
fi

adjust_brightness "$1"
