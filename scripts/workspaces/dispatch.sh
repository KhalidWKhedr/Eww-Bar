#!/bin/bash

# Argument validation
[[ -z "$1" ]] && echo "Usage: $0 <workspace_id>" && exit 1

target_ws="$1"

active_monitor=$(hyprctl monitors -j | jq '.[] | select(.focused == true).id')
passive_monitor=$(hyprctl monitors -j | jq '.[] | select(.focused == false).id')
active_ws=$(hyprctl monitors -j | jq '.[] | select(.focused == true).activeWorkspace.id')
passive_ws=$(hyprctl monitors -j | jq '.[] | select(.focused == false).activeWorkspace.id')

# Logic: if target is currently on the passive monitor and we're switching, swap it
if [[ "$target_ws" -eq "$passive_ws" ]] && [[ "$passive_monitor" != "$active_monitor" ]]; then
    hyprctl dispatch swapactiveworkspaces "$active_monitor $passive_monitor"
fi

# Move workspace to active monitor, focus it
hyprctl dispatch moveworkspacetomonitor "$target_ws $active_monitor"
hyprctl dispatch focusmonitor "$active_monitor"
hyprctl dispatch workspace "$target_ws"
