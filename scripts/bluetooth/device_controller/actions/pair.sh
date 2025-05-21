#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../../utils/log.sh"

pair_device() {
    if bluetoothctl pair "$1"; then
        log "Successfully paired with $1" "INFO"
    else
        log "Failed to pair with $1" "ERROR"
    fi
}
