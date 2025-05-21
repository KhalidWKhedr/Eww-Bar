#!/bin/bash

# Log file location
LOG_FILE="/var/log/bluetooth_generate_devices.log"

# Logging function
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to handle Bluetooth device generation
generate_devices() {
    log_message "Starting Bluetooth device generation"

    # Prevent concurrent runs
    lockfile="/tmp/generate_devices.lock"
    if [ -e "$lockfile" ]; then
        log_message "Scanning already in progress - exiting"
        printf '(label :text "Scanning in progress, please wait")'
        exit 0
    fi
    touch "$lockfile"
    trap 'rm -f "$lockfile"; log_message "Removed lockfile"' EXIT
    log_message "Created lockfile"

    # Check if Bluetooth service is running
    if ! systemctl --quiet is-active bluetooth; then
        log_message "Error: Bluetooth service not running"
        printf '(label :text "Error: Bluetooth service not running")'
        exit 1
    fi
    log_message "Bluetooth service is active"

    # Check if Bluetooth is powered on
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        log_message "Error: Bluetooth is powered off"
        printf '(label :text "Error: Bluetooth is powered off")'
        exit 1
    fi
    log_message "Bluetooth is powered on"

    # Start scanning
    log_message "Starting Bluetooth scan"
    bluetoothctl scan on >/dev/null 2>&1
    sleep 3  # Increased scan time for better discovery
    bluetoothctl scan off >/dev/null 2>&1
    log_message "Bluetooth scan completed"

    # Get a list of all devices
    devices=$(bluetoothctl devices | awk '/^Device/ {print $2 " " substr($0, index($0, $3))}')
    log_message "Found ${devices:+$(echo "$devices" | wc -l)} devices"

    # Check if any devices are available
    if [ -z "$devices" ]; then
        log_message "No Bluetooth devices found"
        printf '(label :text "No Bluetooth devices found")'
        exit 0
    fi

    # Buffer output
    output="(box :orientation \"v\" :space-evenly \"true\""
    while read -r device; do
        mac_address=$(echo "$device" | awk '{print $1}' | tr '[:lower:]' '[:upper:]')
        device_name=$(echo "$device" | cut -d' ' -f2- | sed 's/"/\\"/g; s/[)(]/\\&/g; s/[^[:print:]]//g; s/  */ /g')
        # Skip empty or invalid device names
        [ -z "$device_name" ] && {
            log_message "Skipping device with empty/invalid name (MAC: $mac_address)"
            continue
        }

        log_message "Processing device: $device_name ($mac_address)"

        output+="$(cat <<INNER
 (box :class "container_devices"
      :orientation "h"
      :space-evenly "true"
   (button :class "device_name"
           :style "font-size: 14px; padding-left: 0px"
           :onclick "${HOME}/.config/eww/scripts/popup audio \"$device_name\""
           "$device_name")
   (box :class "container_options"
        :orientation "h"
        :space-evenly "true"
        :valign "center"
     (button :class "bluetooth_link"
             :style "font-size: 15px; padding-left: 0px"
             :onclick "${HOME}/.config/eww/scripts/bluetooth/bluetooth_manager.sh pair \"$mac_address\""
             "")
     (button :class "bluetooth_connect"
             :style "font-size: 20px; padding-left: 0px"
             :onclick "${HOME}/.config/eww/scripts/bluetooth/bluetooth_manager.sh connect \"$mac_address\""
             "󰂱")
     (button :class "bluetooth_trust"
             :style "font-size: 15px; padding-left: 0px"
             :onclick "${HOME}/.config/eww/scripts/bluetooth/bluetooth_manager.sh trust \"$mac_address\""
             "")))
INNER
)"
    done <<< "$devices"
    output+=")"
    log_message "Generated output for ${devices:+$(echo "$devices" | wc -l)} devices"

    # Output complete Yuck content
    printf "%s" "$output"
    log_message "Completed Bluetooth device generation"
}

# Ensure log file exists and has proper permissions
touch "$LOG_FILE" 2>/dev/null || {
    LOG_FILE="${HOME}/.cache/bluetooth_generate_devices.log"
    touch "$LOG_FILE"
}
chmod 644 "$LOG_FILE" 2>/dev/null
log_message "Script initialized"

# Call the function
generate_devices