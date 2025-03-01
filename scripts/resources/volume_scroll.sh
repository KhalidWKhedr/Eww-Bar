#!/bin/bash

# Get the scroll direction from the event
DIRECTION=$1

# Change volume based on the direction
if [ "$DIRECTION" == "up" ]; then
  # Increase volume by 5%
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
elif [ "$DIRECTION" == "down" ]; then
  # Decrease volume by 5%
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
fi

# After changing, fetch the updated volume level
current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')

# Append the current volume to the file, but avoid duplicates
last_logged_volume=$(tail -n 1 /home/khalidwaleedkhedr/.config/eww/extra_stuff/logs/current_volume)

# Only append if the new volume is different from the last one
if [ "$current_volume" != "$last_logged_volume" ]; then
  echo $current_volume >> /home/khalidwaleedkhedr/.config/eww/extra_stuff/logs/current_volume
fi
