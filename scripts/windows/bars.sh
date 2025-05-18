#!/bin/bash

# Start Eww daemon safely and wait until it's ready
eww daemon &> /dev/null &
while ! eww ping &>/dev/null; do sleep 0.1; done

# Get monitor info
MONITORS=$(hyprctl monitors -j)

# Arrays for instances and args
declare -a INSTANCES=()
declare -a ARGS=()

# Optional: Enable debug output
DEBUG=true

log() {
    [ "$DEBUG" = true ] && echo "$@"
}

# Parse each monitor dynamically
while read -r monitor; do
    MODEL=$(echo "$monitor" | jq -r '.model')
    WIDTH=$(echo "$monitor" | jq -r '.width')
    DPMS=$(echo "$monitor" | jq -r '.dpmsStatus')

    # Skip DPMS-off monitors
    [ "$DPMS" = "false" ] && continue

    # Determine GUI size
    GUI_SIZE=$([ "$WIDTH" -gt 1920 ] && echo "large" || echo "small")

    # Create a sanitized ID from model name
    ID="monitor_$(echo "$MODEL" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')"

    log "Setting up $MODEL as $ID ($GUI_SIZE)"

    # Append window instance and arguments
    INSTANCES+=("window_bar:$ID")
    ARGS+=("--arg" "$ID:monitor=$MODEL" "--arg" "$ID:gui_size=$GUI_SIZE")
done < <(echo "$MONITORS" | jq -c '.[]')

# Launch bars if any active monitors
if [ ${#INSTANCES[@]} -gt 0 ]; then
    eww close-all 2>/dev/null || true
    eww open-many "${INSTANCES[@]}" "${ARGS[@]}"
else
    echo "No active monitors found"
    exit 0
fi
