#!/bin/bash

# Paths
EWW_CONFIG_DIR="$HOME/.config/eww"
LOG_DIR="$EWW_CONFIG_DIR/extra_stuff/logs"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Bluetooth settings
BLUETOOTH_SCAN_TIME=15
BLUETOOTH_DEBUG_LOG="/tmp/bluetooth_debug.log"

# Volume and Brightness settings
VOLUME_INCREMENT=5
BRIGHTNESS_INCREMENT=5
BRIGHTNESS_DEVICE="amdgpu_bl1"

# Monitor settings
LARGE_MONITOR_WIDTH=1920

# Notification settings
NOTIFICATION_TIMEOUT=7000

# Network settings
WIFI_INTERFACE="w*"

# Music settings
DEFAULT_ART_URL="/path/to/default/image.png"

# Create necessary directories
mkdir -p "$LOG_DIR"
mkdir -p "$SCREENSHOT_DIR"

# Error handling function
handle_error() {
    local exit_code=$1
    local error_message=$2
    if [ $exit_code -ne 0 ]; then
        echo "Error: $error_message" >&2
        exit $exit_code
    fi
}

# Logging function
log() {
    local message=$1
    local level=${2:-"INFO"}
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_DIR/eww.log"
}