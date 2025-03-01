#!/bin/bash

# Function to get the battery level of a Bluetooth device
get_battery_level() {
    local mac_address=$1
    local battery_info=$(bluetoothctl info "$mac_address" | grep "Battery Percentage")

    if [[ -n $battery_info ]]; then
        echo "$battery_info"
    else
        echo "Battery information is not available for $mac_address."
    fi
}

# Function to pair a Bluetooth device
pair_device() {
    local mac_address=$1
    if bluetoothctl pair "$mac_address"; then
        echo "Successfully paired with $mac_address."
    else
        echo "Failed to pair with $mac_address."
    fi
}

# Function to connect to a Bluetooth device
connect_device() {
    local mac_address=$1
    if bluetoothctl connect "$mac_address"; then
        echo "Successfully connected to $mac_address."
    else
        echo "Failed to connect to $mac_address."
    fi
}

# Function to trust a Bluetooth device
trust_device() {
    local mac_address=$1
    if bluetoothctl trust "$mac_address"; then
        echo "Successfully trusted $mac_address."
    else
        echo "Failed to trust $mac_address."
    fi
}

# Main function to parse arguments and call the appropriate action
main() {
    local action=$1
    local mac_address=$2

    if [[ -z $action || -z $mac_address ]]; then
        echo "Usage: $0 {pair|connect|trust|battery} <MAC_ADDRESS>"
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
            echo "Invalid action: $action. Use {pair|connect|trust|battery}."
            exit 1
            ;;
    esac
}

# Execute the main function with arguments
main "$@"
