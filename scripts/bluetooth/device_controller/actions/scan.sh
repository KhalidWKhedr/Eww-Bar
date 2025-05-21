#!/bin/bash
# device_controller/actions/scan.sh

# Resolve to the device_controller directory
CONTROLLER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"

# Load dependencies
source "${CONTROLLER_DIR}/config.sh"
source "${CONTROLLER_DIR}/../utils/log.sh"

lockfile="/tmp/bluetooth_scan.lock"
SCAN_DURATION="${SCAN_DURATION:-10}"

scan_devices() {
    # Check for existing scan
    if [ -e "$lockfile" ]; then
        log "Scan already in progress" "WARN"
        echo "SCAN_IN_PROGRESS"
        return 1
    fi

    # Create lockfile
    touch "$lockfile" || {
        log "Lockfile creation failed" "ERROR"
        return 1
    }
    trap 'rm -f "$lockfile"; log "Scan cleanup complete" "INFO"' EXIT

    # Bluetooth service check
    if ! systemctl is-active bluetooth &>/dev/null; then
        log "Bluetooth service inactive" "ERROR"
        echo "BLUETOOTH_SERVICE_INACTIVE"
        return 1
    fi

    if ! bluetoothctl show | grep -q "Powered: yes"; then
        log "Bluetooth powered off" "ERROR"
        echo "BLUETOOTH_POWERED_OFF"
        return 1
    fi

    log "Starting Bluetooth scan" "INFO"
    bluetoothctl scan on &>/dev/null
    sleep "$SCAN_DURATION"
    bluetoothctl scan off &>/dev/null

    # Retrieve and format devices
    devices=$(bluetoothctl devices | awk '/^Device/ {
        mac = $2
        name = substr($0, index($0, $3))
        gsub(/[^[:alnum:] _-]/, "", name)
        printf "%s|%s\n", mac, name
    }')

    if [ -z "$devices" ]; then
        log "No devices found" "INFO"
        echo "NO_DEVICES_FOUND"
    else
        log "Found devices" "INFO"
        echo "$devices"
    fi
}
