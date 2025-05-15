#!/bin/bash

# Function to handle Bluetooth device generation
generate_devices() {
    # Prevent concurrent runs
    lockfile="/tmp/generate_devices.lock"
    if [ -e "$lockfile" ]; then
        printf '(label :text "Scanning in progress, please wait")'
        exit 0
    fi
    touch "$lockfile"
    trap 'rm -f "$lockfile"' EXIT

    # Check if Bluetooth service is running
    if ! systemctl --quiet is-active bluetooth; then
        printf '(label :text "Error: Bluetooth service not running")'
        exit 1
    fi

    # Check if Bluetooth is powered on
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        printf '(label :text "Error: Bluetooth is powered off")'
        exit 1
    fi

    # Start scanning (foreground for reliability)
    bluetoothctl scan on >/dev/null 2>&1
    sleep 15  # Increased scan time for better discovery
    bluetoothctl scan off >/dev/null 2>&1

    # Get a list of all devices (including cached ones)
    devices=$(bluetoothctl devices | awk '/^Device/ {print $2 " " substr($0, index($0, $3))}')

    # Check if any devices are available
    if [ -z "$devices" ]; then
        printf '(label :text "No Bluetooth devices found")'
        exit 0
    fi

    # Buffer output to ensure complete generation
    output="(box :orientation \"v\" :space-evenly \"true\""
    while read -r device; do
        mac_address=$(echo "$device" | awk '{print $1}')
        device_name=$(echo "$device" | cut -d' ' -f2- | sed 's/"/\\"/g; s/[)(]/\\&/g; s/[^[:print:]]//g')
        # Skip empty or invalid device names
        [ -z "$device_name" ] && continue

        output+="$(cat <<INNER
 (box :class "container_devices"
      :orientation "h"
      :space-evenly "true"
   (button :class "device_name"
           :style "font-size: 14px; padding-left: 0px"
           :onclick "scripts/popup audio \"$device_name\""
           "$device_name")
   (box :class "container_options"
        :orientation "h"
        :space-evenly "true"
        :valign "center"
     (button :class "bluetooth_link"
             :style "font-size: 15px; padding-left: 0px"
             :onclick "scripts/bluetooth/bluetooth_manager.sh pair \"$mac_address\""
             "")
     (button :class "bluetooth_connect"
             :style "font-size: 20px; padding-left: 0px"
             :onclick "scripts/bluetooth/bluetooth_manager.sh connect \"$mac_address\""
             "󰂱")
     (button :class "bluetooth_trust"
             :style "font-size: 15px; padding-left: 0px"
             :onclick "scripts/bluetooth/bluetooth_manager.sh trust \"$mac_address\""
             "")))
INNER
)"
    done <<< "$devices"
    output+=")"

    # Output complete Yuck content
    printf "%s" "$output"
}

# Call the function to generate device content
generate_devices