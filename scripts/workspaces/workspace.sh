#!/bin/bash

# Define Nerd Font moon phase icons for workspaces 1-9
chess=("♔" "♕" "♖" "♗" "♘" "♙" "♚" "♛" "♜")

workspaces() {

  unset -v \
  o1 o2 o3 o4 o5 o6 o7 o8 o9 \
  f1 f2 f3 f4 f5 f6 f7 f8 f9

# Get occupied workspaces and remove workspace -99 aka scratchpad if it exists
ows="$(hyprctl workspaces -j | grep -v '"id": -99' | awk -F'"id":' '{print $2}' | sed 's/[ ,]*//g')"

for num in $ows; do
  export o"$num"="$num"
done

# Get Focused workspace for current monitor ID
arg="$1"
num="$(hyprctl monitors -j | grep -Po '"id":\s*\K[0-9]+' | grep -A 1 "$arg" | tail -n 1)"
export f"$num"="$num"

echo "(eventbox :onscroll \"echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace\" \
      (box :class \"workspace\" :orientation \"h\" :space-evenly \"true\" :halign \"center\" :valign \"center\" \
        (button :onclick \"scripts/workspaces/dispatch.sh 1\" :class \"w0$o1$f1\" :tooltip \"Workspace\" :width 40 :height 36 :hexpand true :vexpand false :style \"font-size: 20px; padding-left: 6px\" \"${chess[0]}₁ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 2\" :class \"w0$o2$f2\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[1]}₂ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 3\" :class \"w0$o3$f3\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[2]}₃ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 4\" :class \"w0$o4$f4\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[3]}₄ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 5\" :class \"w0$o5$f5\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[4]}₅ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 6\" :class \"w0$o6$f6\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[5]}₆ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 7\" :class \"w0$o7$f7\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[6]}₇ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 8\" :class \"w0$o8$f8\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[7]}₈ \") \
        (button :onclick \"scripts/workspaces/dispatch.sh 9\" :class \"w0$o9$f9\" :tooltip \"Workspace\" :style \"font-size: 20px; padding-left: 6px\" \"${chess[8]}₉ \") \
    ) \
  )"
}

workspaces $1
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r event; do
workspaces $1
done
