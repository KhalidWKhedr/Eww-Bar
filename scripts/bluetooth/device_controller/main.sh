#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/../utils/log.sh"

ACTION="$1"
MAC_ADDRESS=$(echo "$2" | tr '[:lower:]' '[:upper:]')

if [[ -z "$ACTION" ]]; then
    log "Usage: $0 {pair|connect|trust|battery|scan} <MAC_ADDRESS>" "ERROR"
    echo "Usage: $0 {pair|connect|trust|battery|scan} <MAC_ADDRESS>"
    exit 1
fi

case "$ACTION" in
    pair)
        [[ -z "$MAC_ADDRESS" ]] && { echo "MAC address required"; exit 1; }
        source "$SCRIPT_DIR/actions/pair.sh"
        pair_device "$MAC_ADDRESS"
        ;;
    connect)
        [[ -z "$MAC_ADDRESS" ]] && { echo "MAC address required"; exit 1; }
        source "$SCRIPT_DIR/actions/connect.sh"
        connect_device "$MAC_ADDRESS"
        ;;
    trust)
        [[ -z "$MAC_ADDRESS" ]] && { echo "MAC address required"; exit 1; }
        source "$SCRIPT_DIR/actions/trust.sh"
        trust_device "$MAC_ADDRESS"
        ;;
    battery)
        [[ -z "$MAC_ADDRESS" ]] && { echo "MAC address required"; exit 1; }
        source "$SCRIPT_DIR/battery/get_battery.sh"
        get_battery_level "$MAC_ADDRESS"
        ;;
    scan)
        source "$SCRIPT_DIR/actions/scan.sh"
        scan_devices
        ;;
    *)
        log "Invalid action: $ACTION" "ERROR"
        echo "Invalid action: $ACTION. Use {pair|connect|trust|battery|scan}."
        exit 1
        ;;
esac
