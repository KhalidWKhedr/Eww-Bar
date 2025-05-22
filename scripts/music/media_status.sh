#!/bin/bash

# Get a list of all available players
PLAYERS=$(playerctl -l 2>/dev/null)

# Initialize variables
CURRENT_PLAYER=""
CURRENT_STATUS=""
CURRENT_TITLE=""
CURRENT_ARTIST=""
CURRENT_POSITION=""
CURRENT_DURATION=""
CURRENT_ART_URL=""
PAUSED_PLAYER=""
PAUSED_TITLE=""
PAUSED_ARTIST=""
PAUSED_POSITION=""
PAUSED_DURATION=""
PAUSED_ART_URL=""

# Loop through all players
for PLAYER in $PLAYERS; do
    STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null || echo "stopped")

    if [[ "$STATUS" == "Playing" ]]; then
        CURRENT_PLAYER="$PLAYER"
        CURRENT_STATUS="$STATUS"
        CURRENT_TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
        CURRENT_ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
        CURRENT_POSITION=$(playerctl -p "$PLAYER" position 2>/dev/null | awk '{printf "%02d:%02d", $1/60, $1%60}')
        CURRENT_DURATION=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null | awk '{printf "%02d:%02d", $1/60000000, ($1/1000000)%60}')
        CURRENT_ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)
    elif [[ "$STATUS" == "Paused" && -z "$CURRENT_PLAYER" ]]; then
        PAUSED_PLAYER="$PLAYER"
        PAUSED_STATUS="$STATUS"
        PAUSED_TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
        PAUSED_ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
        PAUSED_POSITION=$(playerctl -p "$PLAYER" position 2>/dev/null | awk '{printf "%02d:%02d", $1/60, $1%60}')
        PAUSED_DURATION=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null | awk '{printf "%02d:%02d", $1/60000000, ($1/1000000)%60}')
        PAUSED_ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)
    fi
done

if [[ -z "$CURRENT_PLAYER" && -z "$PAUSED_PLAYER" ]]; then
    echo '{"status":"none","title":"","artist":"","position":"00:00","duration":"00:00","art_url":"","icon-play":"󰐍"}'
    exit 0
fi

if [[ -z "$CURRENT_PLAYER" ]]; then
    CURRENT_PLAYER="$PAUSED_PLAYER"
    CURRENT_STATUS="$PAUSED_STATUS"
    CURRENT_TITLE="$PAUSED_TITLE"
    CURRENT_ARTIST="$PAUSED_ARTIST"
    CURRENT_POSITION="$PAUSED_POSITION"
    CURRENT_DURATION="$PAUSED_DURATION"
    CURRENT_ART_URL="$PAUSED_ART_URL"
fi

CURRENT_ART_URL=${CURRENT_ART_URL:-"/path/to/default/image.png"}

if [[ "$CURRENT_STATUS" == "Playing" ]]; then
    PLAY_ICON="󰏦"
else
    PLAY_ICON="󰐍"
fi

cat <<EOF
{
  "status": "$CURRENT_STATUS",
  "title": "$CURRENT_TITLE",
  "artist": "$CURRENT_ARTIST",
  "position": "$CURRENT_POSITION",
  "duration": "$CURRENT_DURATION",
  "art_url": "$CURRENT_ART_URL",
  "icon-play": "$PLAY_ICON"
}
EOF
e