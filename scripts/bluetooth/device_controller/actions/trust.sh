#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../../utils/log.sh"

trust_device() {
    if bluetoothctl trust "$1"; then
        log "Trusted $1" "INFO"
    else
        log "Failed to trust $1" "ERROR"
    fi
}
