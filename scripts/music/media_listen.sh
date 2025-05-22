#!/bin/bash

# Dependencies: playerctl, jq

# Initial values
LAST_META_HASH=""
ARTIST=""
TITLE=""
DURATION=""
STATUS=""
ART_URL=""
ICON_PLAY=""

while true; do
    # Get position and static data
    POSITION=$(playerctl position 2>/dev/null | awk '{printf "%02d:%02d", int($1/60), int($1%60)}')

    # Get metadata
    META=$(playerctl metadata --format '{{status}}|{{artist}}|{{title}}|{{mpris:length}}|{{mpris:artUrl}}' 2>/dev/null)

    # Skip if nothing playing
    [[ -z "$META" ]] && sleep 1 && continue

    # Parse and extract
    IFS='|' read -r STATUS_NEW ARTIST_NEW TITLE_NEW LENGTH_US ART_URL_NEW <<< "$META"
    DURATION_NEW=$(awk -v us="$LENGTH_US" 'BEGIN { s=us/1000000; printf "%02d:%02d", int(s/60), int(s%60) }')
    ICON_PLAY_NEW=$([[ "$STATUS_NEW" == "Playing" ]] && echo "󰏦" || echo "󰐊")

    # Hash to check if static data changed
    CURRENT_META_HASH=$(echo "$STATUS_NEW|$ARTIST_NEW|$TITLE_NEW|$DURATION_NEW|$ART_URL_NEW" | sha256sum)

    if [[ "$CURRENT_META_HASH" != "$LAST_META_HASH" ]]; then
        # Update all values
        ARTIST="$ARTIST_NEW"
        TITLE="$TITLE_NEW"
        DURATION="$DURATION_NEW"
        STATUS="$STATUS_NEW"
        ART_URL="$ART_URL_NEW"
        ICON_PLAY="$ICON_PLAY_NEW"
        LAST_META_HASH="$CURRENT_META_HASH"
    fi

    # Emit full JSON
    jq -c -n \
      --arg status "$STATUS" \
      --arg title "$TITLE" \
      --arg artist "$ARTIST" \
      --arg position "$POSITION" \
      --arg duration "$DURATION" \
      --arg art_url "$ART_URL" \
      --arg icon_play "$ICON_PLAY" \
      '{
        status: $status,
        title: $title,
        artist: $artist,
        position: $position,
        duration: $duration,
        art_url: $art_url,
        "icon-play": $icon_play
      }'


    sleep 1
done
