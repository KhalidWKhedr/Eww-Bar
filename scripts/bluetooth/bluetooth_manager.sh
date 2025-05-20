#!/bin/bash

# Source configuration
source "$(dirname "$0")/../config.sh"

# Function to get the battery level of a Bluetooth device
get_battery_level() {
    local mac_address=$1
    
    if [ -z "$mac_address" ]; then
        log "MAC address is required" "ERROR"
        return 1
    fi
    
    local battery_info
    battery_info=$(bluetoothctl info "$mac_address" 2>/dev/null | grep "Battery Percentage")
    handle_error $? "Failed to get battery info for $mac_address"

    if [[ -n $battery_info ]]; then
        log "Battery info for $mac_address: $battery_info"
        echo "$battery_info"
    else
        log "Battery information is not available for $mac_address" "WARNING"
        echo "Battery information is not available for $mac_address."
    fi
}

# Function to pair a Bluetooth device
pair_device() {
    local mac_address=$1
    
    if [ -z "$mac_address" ]; then
        log "MAC address is required" "ERROR"
        return 1
    fi
    
    log "Attempting to pair with $mac_address"
    if bluetoothctl pair "$mac_address" 2>/dev/null; then
        log "Successfully paired with $mac_address"
        echo "Successfully paired with $mac_address."
    else
        log "Failed to pair with $mac_address" "ERROR"
        echo "Failed to pair with $mac_address."
        return 1
    fi
}

# Function to connect to a Bluetooth device
connect_device() {
    local mac_address=$1
    
    if [ -z "$mac_address" ]; then
        log "MAC address is required" "ERROR"
        return 1
    fi
    
    log "Attempting to connect to $mac_address"
    if bluetoothctl connect "$mac_address" 2>/dev/null; then
        log "Successfully connected to $mac_address"
        echo "Successfully connected to $mac_address."
    else
        log "Failed to connect to $mac_address" "ERROR"
        echo "Failed to connect to $mac_address."
        return 1
    fi
}

# Function to trust a Bluetooth device
trust_device() {
    local mac_address=$1
    
    if [ -z "$mac_address" ]; then
        log "MAC address is required" "ERROR"
        return 1
    fi
    
    log "Attempting to trust $mac_address"
    if bluetoothctl trust "$mac_address" 2>/dev/null; then
        log "Successfully trusted $mac_address"
        echo "Successfully trusted $mac_address."
    else
        log "Failed to trust $mac_address" "ERROR"
        echo "Failed to trust $mac_address."
        return 1
    fi
}

# Main function to parse arguments and call the appropriate action
main() {
    local action=$1
    local mac_address=$2

    if [[ -z $action || -z $mac_address ]]; then
        log "Usage: $0 {pair|connect|trust|battery} <MAC_ADDRESS>" "ERROR"
        exit 1
    fi

    case $action in
        pair)
            pair_device "$mac_address"
            ;;
        connect)
            connect_device "$mac_address"
            ;;
        trust)
            trust_device "$mac_address"
            ;;
        battery)
            get_battery_level "$mac_address"
            ;;
        *)
            log "Invalid action: $action. Use {pair|connect|trust|battery}." "ERROR"
            exit 1
            ;;
    esac
}

# Execute the main function with arguments
main "$@"
