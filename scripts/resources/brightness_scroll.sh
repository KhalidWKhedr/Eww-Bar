#!/usr/bin/env bash

INCREMENT=5                            
DEVICE="amdgpu_bl1"                   
LOG_FILE="$HOME/.config/eww/extra_stuff/logs/current_brightness"

get_brightness_values() {
    local current max
    current=$(brightnessctl -d "$DEVICE" g)  
    max=$(brightnessctl -d "$DEVICE" m)      
    echo "$current $max"
}

get_brightness_percentage() {
    local values current max
    values=($(get_brightness_values))
    current=${values[0]}
    max=${values[1]}
    echo $((current * 100 / max))
}

set_brightness() {
    local percentage
    percentage=$1
    if [[ "$percentage" -gt 100 ]]; then
        percentage=100
    elif [[ "$percentage" -lt 0 ]]; then
        percentage=0
    fi
    echo "Setting brightness to $percentage%"
    brightnessctl -d "$DEVICE" set "${percentage}%"
    echo "$percentage" >> "$LOG_FILE"
}

adjust_brightness() {
    local direction current_percentage new_percentage
    direction=$1
    current_percentage=$(get_brightness_percentage)
    echo "Current brightness percentage: $current_percentage"

    if [[ "$direction" == "up" ]]; then
        new_percentage=$((current_percentage + INCREMENT))
        [[ "$new_percentage" -gt 100 ]] && new_percentage=100
    elif [[ "$direction" == "down" ]]; then
        new_percentage=$((current_percentage - INCREMENT))
        [[ "$new_percentage" -lt 0 ]] && new_percentage=0
    else
        echo "Invalid direction: $direction" >&2
        exit 1
    fi

    set_brightness "$new_percentage"
}

if [[ -z "$1" ]]; then
    echo "Usage: $0 [up|down]" >&2
    exit 1
fi

adjust_brightness "$1"
