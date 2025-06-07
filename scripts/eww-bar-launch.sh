#!/bin/bash

# Get monitor info from Hyprland
MONITORS=$(hyprctl monitors -j)

declare -a INSTANCES=()
declare -a ARGS=()

while read -r monitor; do
    MODEL=$(echo "$monitor" | jq -r '.model')
    WIDTH=$(echo "$monitor" | jq -r '.width')
    DPMS=$(echo "$monitor" | jq -r '.dpmsStatus')
    [ "$DPMS" = "false" ] && continue

    GUI_SIZE=$([ "$WIDTH" -gt 1920 ] && echo "large" || echo "small")
    ID="monitor_$(echo "$MODEL" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')"

    INSTANCES+=("window_bar:$ID")
    ARGS+=("--arg" "$ID:monitor=$MODEL" "--arg" "$ID:gui_size=$GUI_SIZE")
done < <(echo "$MONITORS" | jq -c '.[]')

if [ ${#INSTANCES[@]} -gt 0 ]; then
    eww open-many "${INSTANCES[@]}" "${ARGS[@]}"
else
    echo "No monitors found or active"
fi
