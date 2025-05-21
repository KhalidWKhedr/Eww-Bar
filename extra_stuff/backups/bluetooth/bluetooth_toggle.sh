#!/bin/bash

# Log output to debug.txt
exec > >(tee -a /tmp/bluetooth_debug.log) 2>&1

echo "Running Bluetooth Toggle Script"

# Check the current Bluetooth state
if bluetoothctl show | grep -q 'Powered: yes'; then
    echo "Bluetooth is ON, turning it OFF"
    # Bluetooth is ON, turn it OFF
    bluetoothctl power off
    # Update eww state to reflect Bluetooth being OFF
    eww update bluetooth-enabled=false
else
    echo "Bluetooth is OFF, turning it ON"
    # Bluetooth is OFF, turn it ON
    bluetoothctl power on
    # Update eww state to reflect Bluetooth being ON
    eww update bluetooth-enabled=true
fi

echo "Bluetooth toggle complete"
