#!/usr/bin/env bash

set -euo pipefail

ITEM_NAME="${NAME:-workspace_apps}"
ACTION="${1:-toggle}"

clear_popup() {
  sketchybar --remove '/workspace\.apps\..*/' >/dev/null 2>&1 || true
}

space_label() {
  case "$1" in
    14) printf 'Utility' ;;
    13) printf 'Scratch' ;;
    *) printf '%s' "$1" ;;
  esac
}

truncate_label() {
  local text="$1"
  local limit=52

  if [[ ${#text} -le $limit ]]; then
    printf '%s' "$text"
  else
    printf '%s...' "${text:0:$((limit - 3))}"
  fi
}

add_row() {
  local index="$1"
  local space_index="$2"
  local label="$3"

  sketchybar --add item "workspace.apps.$index" popup."$ITEM_NAME" \
             --set "workspace.apps.$index" \
               icon.drawing=off \
               icon.width=0 \
               label="$label" \
               label.font="JetBrainsMono Nerd Font:Regular:12.0" \
               label.align=left \
               label.padding_left=14 \
               label.padding_right=14 \
               width=320 \
               click_script="/opt/homebrew/bin/yabai -m space --focus $space_index; /opt/homebrew/bin/sketchybar --set $ITEM_NAME popup.drawing=off"
}

show_popup() {
  local spaces_json rows index line space_index apps label

  spaces_json=$(/opt/homebrew/bin/yabai -m query --spaces)
  clear_popup
  rows=()

  while IFS=$'\t' read -r space_index; do
    apps=$( /opt/homebrew/bin/yabai -m query --windows --space "$space_index" | /usr/bin/jq -r 'map(select(."has-ax-reference" == true) | .app) | unique | join(", ")' )
    [[ -n "$apps" ]] || continue
    label="$(space_label "$space_index"): $(truncate_label "$apps")"
    rows+=("$space_index|$label")
  done < <(printf '%s' "$spaces_json" | /usr/bin/jq -r '.[] | select(.index == 14) | .index')

  while IFS=$'\t' read -r space_index; do
    apps=$( /opt/homebrew/bin/yabai -m query --windows --space "$space_index" | /usr/bin/jq -r 'map(select(."has-ax-reference" == true) | .app) | unique | join(", ")' )
    [[ -n "$apps" ]] || continue
    label="$(space_label "$space_index"): $(truncate_label "$apps")"
    rows+=("$space_index|$label")
  done < <(printf '%s' "$spaces_json" | /usr/bin/jq -r '.[] | select(.index >= 1 and .index <= 12) | .index' | sort -n)

  while IFS=$'\t' read -r space_index; do
    apps=$( /opt/homebrew/bin/yabai -m query --windows --space "$space_index" | /usr/bin/jq -r 'map(select(."has-ax-reference" == true) | .app) | unique | join(", ")' )
    [[ -n "$apps" ]] || continue
    label="$(space_label "$space_index"): $(truncate_label "$apps")"
    rows+=("$space_index|$label")
  done < <(printf '%s' "$spaces_json" | /usr/bin/jq -r '.[] | select(.index == 13) | .index')

  if [[ ${#rows[@]} -eq 0 ]]; then
    sketchybar --set "$ITEM_NAME" popup.drawing=off
    exit 0
  fi

  index=0
  for line in "${rows[@]}"; do
    index=$((index + 1))
    space_index=${line%%|*}
    label=${line#*|}
    add_row "$index" "$space_index" "$label"
  done

  sketchybar --set "$ITEM_NAME" popup.drawing=toggle
}

toggle_popup() {
  local popup_state

  popup_state=$(sketchybar --query "$ITEM_NAME" | /usr/bin/jq -r '.popup.drawing')
  if [[ "$popup_state" == "on" ]]; then
    sketchybar --set "$ITEM_NAME" popup.drawing=off
    exit 0
  fi

  show_popup
}

case "$ACTION" in
  toggle)
    toggle_popup
    ;;
  popup)
    show_popup
    ;;
esac
