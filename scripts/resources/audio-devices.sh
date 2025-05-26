#!/bin/bash

echo "=== Outputs ==="
pactl list short sinks | grep -E 'alsa_output\.(usb|pci)' | while read -r line; do
  name=$(echo "$line" | awk '{print $2}')
  desc=$(pactl list sinks | awk -v dev="$name" '
    $1 == "Name:" && $2 == dev {found=1}
    found && $1 == "Description:" {print substr($0, index($0,$2)); exit}
  ')
  echo "🔊 $desc ($name)"
done

echo ""
echo "=== Inputs ==="
pactl list short sources | grep -E 'alsa_input\.(usb|pci)' | while read -r line; do
  name=$(echo "$line" | awk '{print $2}')
  desc=$(pactl list sources | awk -v dev="$name" '
    $1 == "Name:" && $2 == dev {found=1}
    found && $1 == "Description:" {print substr($0, index($0,$2)); exit}
  ')
  echo "🎤 $desc ($name)"
done
