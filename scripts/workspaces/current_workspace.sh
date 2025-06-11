#!/bin/bash

# Enable debugging if DEBUG=1
[[ -n "$DEBUG" ]] && set -x

# Ensure required environment variables are set
if [[ -z "$XDG_RUNTIME_DIR" || -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Error: Required environment variables (XDG_RUNTIME_DIR or HYPRLAND_INSTANCE_SIGNATURE) are not set." >&2
    exit 1
fi

# Define the socket path
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Check if the socket exists initially
if [[ ! -S "$SOCKET" ]]; then
    echo "Error: Socket $SOCKET does not exist or is not a socket." >&2
    exit 1
fi

# Ignore SIGPIPE to handle broken pipe gracefully
trap '' SIGPIPE

# Function to escape JSON strings and force single line output
escape_json_single_line() {
    local str="$1"
    # Remove carriage returns and newlines characters (real ones)
    str="${str//$'\r'/ }"
    str="${str//$'\n'/ }"
    # Replace literal backslash + n (two chars) with a space
    str="${str//\\n/ }"
    # Replace literal backslash + r (two chars) with a space
    str="${str//\\r/ }"
    # Remove multiple spaces
    str="$(echo "$str" | tr -s ' ')"
    # Trim spaces on both ends
    str="$(echo "$str" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    # Escape double quotes
    str="${str//\"/\\\"}"
    printf '%s' "$str"
}

# Function to process events
process_events() {
    while IFS= read -r event; do
        [[ -n "$DEBUG" ]] && echo "Raw event: '$event'" >&2
        if [[ "$event" == activewindow* ]]; then
            window_info="${event#*>>}"
            [[ -n "$DEBUG" ]] && echo "Window info: '$window_info'" >&2
            IFS=',' read -r app_name config_name <<< "$window_info"
            [[ -n "$DEBUG" ]] && echo "App name: '$app_name', Config name: '$config_name'" >&2
            if [[ ! "$app_name" =~ ^[0-9a-f]{12}$ && -n "$app_name" ]]; then
                printf '{"title":"%s","sublabel":"%s"}\n' "$(escape_json_single_line "$app_name")" "$(escape_json_single_line "$config_name")"
            else
                [[ -n "$DEBUG" ]] && echo "Filtered out: app_name='$app_name' is invalid or empty" >&2
            fi
        else
            [[ -n "$DEBUG" ]] && echo "Event ignored: not an activewindow event" >&2
        fi
    done
}

# Main loop to handle socat and socket failures
while true; do
    if [[ ! -S "$SOCKET" ]]; then
        [[ -n "$DEBUG" ]] && echo "Socket $SOCKET unavailable, retrying in 0.2 seconds..." >&2
        sleep 0.2
        continue
    fi
    if ! timeout 30 socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null | process_events; then
        [[ -n "$DEBUG" ]] && echo "socat timed out or failed, restarting in 0.2 seconds..." >&2
        sleep 0.2
    fi
done
