#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../../utils/log.sh"

get_battery_level() {
    info=$(bluetoothctl info "$1")
    if echo "$info" | grep -q "Battery"; then
        battery=$(echo "$info" | grep "Battery" | awk '{print $2}')
        log "Battery level for $1: $battery" "INFO"
        echo "Battery level: $battery"
    else
        log "Battery level not available for $1" "WARNING"
        echo "Battery level not available."
    fi
}
