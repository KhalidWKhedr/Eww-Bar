#!/bin/bash

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
    exit 1  # Exit if Bluetooth is off
fi

# List available devices
bluetoothctl scan on >/dev/null 2>&1 &
sleep 0  # Allow some time for scanning
bluetoothctl scan off >/dev/null 2>&1

# Get a list of all devices
devices=$(bluetoothctl devices | awk '{print $2 " " substr($0, index($0, $3))}')

# Check if any devices are available
if [ -z "$devices" ]; then
    exit 0  # Exit if no devices are found
fi

# Start generating content for literal
# Generate the output in a single echo block
echo "$(cat <<EOF
(box :class "containing_everything" \
$(while read -r device; do \
    mac_address=$(echo "$device" | awk '{print $1}') \
    device_name=$(echo "$device" | cut -d' ' -f2-) \

    # Add the nested device structure
    cat <<INNER
    (box :class "container_devices" \
         :orientation "h" \
         :space-evenly "true" \
         (button :class "device_name" \
                :style "font-size: 14px; padding-left: 0px" \
                :onclick "scripts/popup audio" "$device_name") \
                (box :class "container_options" \
                     :orientation "h" :space-evenly "true" :valign "center" \
                    (button :class "bluetooth_link" \
                            :style "font-size: 15px; padding-left: 0px" \
                            :onclick "scripts/bluetooth_pair.sh '$mac_address'" "") \
                    (button :class "bluetooth_connect" \
                            :style "font-size: 20px; padding-left: 0px" \
                            :onclick "scripts/bluetooth_connect.sh '$mac_address'" "󰂱") \
                    (button :class "bluetooth_trust" \
                            :style "font-size: 15px; padding-left: 0px" \
                            :onclick "scripts/bluetooth_trust.sh '$mac_address'" "") \
                    ) \
                ) \
            
INNER
done <<< "$devices") \
        
EOF
) "

