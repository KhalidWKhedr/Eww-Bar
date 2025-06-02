#!/bin/bash

# Enable debugging
DEBUG=${DEBUG:-0}
[[ "$DEBUG" -eq 1 ]] && set -x

# Configuration
BUTTON_WIDTH=36
BUTTON_HEIGHT=32
PADDING_LEFT="0px"
CHESS=("♔" "♕" "♖" "♗" "♘" "♙" "♚" "♛" "♜")
SUBSCRIPTS=("₀" "₁" "₂" "₃" "₄" "₅" "₆" "₇" "₈" "₉")

# Check dependencies
for cmd in hyprctl socat jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found" >&2
        exit 1
    fi
done

# Validate environment
if [[ -z "$XDG_RUNTIME_DIR" || -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Error: XDG_RUNTIME_DIR or HYPRLAND_INSTANCE_SIGNATURE not set" >&2
    exit 1
fi

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
[[ ! -S "$SOCKET" ]] && {
    echo "Error: Socket $SOCKET not found" >&2
    exit 1
}

generate_buttons() {
    local monitor_id="$1"
    declare -A occupied focused

    # Read workspaces into occupied
    readarray -t ws_ids < <(hyprctl workspaces -j | jq -r '.[] | select(.id != -99) | .id')
    for ws in "${ws_ids[@]}"; do
        occupied[$ws]=1
    done

    # Get focused workspace
    focused_ws=$(hyprctl monitors -j | jq -r --argjson id "$monitor_id" '.[] | select(.id == $id) | .activeWorkspace.id')
    [[ -n "$focused_ws" ]] && focused[$focused_ws]=1

    local buttons=""
    for ((i = 1; i <= 9; i++)); do
        local icon="${CHESS[i-1]}"
        local subscript="${SUBSCRIPTS[i]}"
        local class="w0"
        [[ ${occupied[$i]+set} ]] && class="w1"
        [[ ${focused[$i]+set} ]] && class="w2"

        buttons+="(button :onclick \"scripts/workspaces/dispatch.sh $i\" \
                          :class \"$class\" \
                          :tooltip \"Workspace $i\" \
                          :width $BUTTON_WIDTH :height $BUTTON_HEIGHT \
                          :hexpand true :vexpand false \
                          :style \"padding-left: $PADDING_LEFT\" \
                          (label :class \"icon\" :text \"${icon}${subscript}\")) "
    done

    echo "(eventbox :onscroll \"echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace\" \
(box :class \"workspace\" :orientation \"h\" :space-evenly true :halign \"center\" :valign \"center\" $buttons))"
}


# Render initial UI
generate_buttons "$1" || exit 1

# Listen for events
while true; do
    if ! socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null | while IFS= read -r event; do
        [[ "$DEBUG" -eq 1 ]] && echo "Event: $event" >&2
        generate_buttons "$1"
    done; then
        echo "socat failed, retrying in 0.2 seconds..." >&2
        sleep 0.2
    fi
done
