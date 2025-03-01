#!/bin/bash
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | \
while IFS= read -r event; do
    if [[ "$event" == *'activewindow'* ]]; then
        # Extract app_name and config_name using awk
        window_info=$(echo "$event" | awk -F '>>' '{print $2}')
        app_name=$(echo "$window_info" | awk -F ',' '{print $1}')
        config_name=$(echo "$window_info" | awk -F ',' '{print $2}')

        # Filter out invalid app_name and empty sublabels
        if [[ ! "$app_name" =~ ^[0-9a-f]{12}$ && -n "$app_name" ]]; then
            # Output JSON
            echo "{\"title\":\"$app_name\",\"sublabel\":\"$config_name\"}"
        fi
    fi
done
