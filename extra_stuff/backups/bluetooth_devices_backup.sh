#!/bin/bash

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
    #echo "Bluetooth is off. Please turn it on."
    exit 1
fi

# List available devices
#echo "Scanning for devices..."
bluetoothctl scan on >/dev/null 2>&1 &
sleep 5  # Allow some time for scanning
bluetoothctl scan off >/dev/null 2>&1

# Get a list of all devices
devices=$(bluetoothctl devices | awk '{print $2 " " substr($0, index($0, $3))}')

# Check if any devices are available
if [ -z "$devices" ]; then
    #echo "No Bluetooth devices found."
    exit 0
fi

# Generate device list for `defwidget`
echo "(defwidget bluetooth []" \
echo "  (box :class \"container_bluetooth\"" \
echo "       :orientation \"v\"" \
echo "       :space-evenly \"true\"" \

# Labels Box
echo "    ;; Labels Box" \
echo "    (box :class \"container_labels\"" \
echo "         (label :class \"label_devices\"" \
echo "                :justify \"left\"" \
echo "                :style \"font-size: 15px; padding-left: 0px\"" \
echo "                :text \"Devices\")" \
echo "         (label :class \"label_options\"" \
echo "                :justify \"left\"" \
echo "                :style \"font-size: 15px; padding-left: 0px\"" \
echo "                :text \"Options\"))" \

# Generate buttons dynamically for each Bluetooth device
while read -r device; do \
    mac_address=$(echo "$device" | awk '{print $1}') \
    device_name=$(echo "$device" | cut -d' ' -f2-) \
    safe_device_name=$(echo "$device_name" | sed 's/[^a-zA-Z0-9_-]/_/g') # Sanitize for safe usage

    # Device Box for each Bluetooth device
    echo "    ;; Device Box for $device_name" \
    echo "    (box :class \"container_devices\"" \
    echo "         :orientation \"h\"" \
    echo "         :space-evenly \"true\"" \

    # Button for each device (device name displayed inside button)
    echo "         (button :class \"volume_button\"" \
    echo "                 :style \"font-size: 14px; padding-left: 0px\"" \
    echo "                 :onclick \"scripts/popup audio\"" \
    echo "                 \"$device_name\")" \

    echo "         (box :class \"container_options\"" \
    echo "              :orientation \"h\"" \
    echo "              :space-evenly \"true\"" \
    echo "              :valign \"right\"" \

    # Bluetooth action buttons with icons, directly in the button text
    echo "              (button :class \"bluetooth_link\"" \
    echo "                      :style \"font-size: 15px; padding-left: 0px\"" \
    echo "                      :onclick \"scripts/bluetooth_pair.sh '$mac_address'\"" \
    echo "                      \"\")" \

    echo "              (button :class \"bluetooth_connect\"" \
    echo "                      :style \"font-size: 20px; padding-left: 0px\"" \
    echo "                      :onclick \"scripts/bluetooth_connect.sh '$mac_address'\"" \
    echo "                      \"󰂱\")" \

    echo "              (button :class \"bluetooth_trust\"" \
    echo "                      :style \"font-size: 15px; padding-left: 0px\"" \
    echo "                      :onclick \"scripts/bluetooth_trust.sh '$mac_address'\"" \
    echo "                      \"\")))"  # This closes the container_options correctly for each device

done <<< "$devices" \

# End the widget
echo "))" \
