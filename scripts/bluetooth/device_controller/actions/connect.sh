#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../../utils/log.sh"

connect_device() {
    if bluetoothctl connect "$1"; then
        log "Successfully connected to $1" "INFO"
    else
        log "Failed to connect to $1" "ERROR"
    fi
}
