#!/usr/bin/env bash

set -euo pipefail

action="${1:-update}"

battery_info=$(pmset -g batt)
percentage=$(printf '%s\n' "$battery_info" | grep -Eo '[0-9]+%' | cut -d% -f1)

if [[ -z "$percentage" ]]; then
  exit 0
fi

show_popup() {
  sketchybar --remove '/battery\.detail/' >/dev/null 2>&1 || true

  sketchybar --add item battery.detail popup.battery \
             --set battery.detail \
               icon.drawing=off \
               label="${percentage}%" \
               label.font="SF Pro Text:Semibold:14.0" \
               label.padding_left=8 \
               label.padding_right=8 \
               width=54

  sketchybar --set "$NAME" popup.drawing=toggle
}

if printf '%s\n' "$battery_info" | grep -q 'AC Power'; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [[ "$action" == "popup" ]]; then
  show_popup
  exit 0
fi

case "$percentage" in
  9[0-9]|100) icon='󰁹' ;;
  [7-8][0-9]) icon='󰂀' ;;
  [5-6][0-9]) icon='󰁾' ;;
  [3-4][0-9]) icon='󰁼' ;;
  [1-2][0-9]) icon='󰁺' ;;
  *) icon='󰂎' ;;
esac

if [[ "$percentage" -lt 20 ]]; then
  icon_color='0xffbf616a'
else
  icon_color='0xffabc5da'
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$icon" \
  icon.color="$icon_color" \
  label.drawing=off
