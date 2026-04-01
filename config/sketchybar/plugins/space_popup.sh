#!/usr/bin/env bash

set -euo pipefail

space_index="${1:?space index required}"
item_name="space.${space_index}"
popup_pattern="/space\.popup\.${space_index}\..*/"

truncate_label() {
  local text="$1"
  local limit=34

  if [[ ${#text} -le $limit ]]; then
    printf '%s' "$text"
  else
    printf '%s...' "${text:0:$((limit - 3))}"
  fi
}

clear_popup() {
  sketchybar --remove "$popup_pattern" >/dev/null 2>&1 || true
}

windows_json=$(/opt/homebrew/bin/yabai -m query --windows --space "$space_index")
window_count=$(printf '%s' "$windows_json" | jq 'map(select(."has-ax-reference" == true)) | length')

if [[ "$window_count" -eq 0 ]]; then
  /opt/homebrew/bin/yabai -m space --focus "$space_index" >/dev/null 2>&1 || true
  exit 0
fi

/opt/homebrew/bin/yabai -m space --focus "$space_index" >/dev/null 2>&1 || true

clear_popup

index=0
while IFS=$'\t' read -r window_id app_name window_title; do
  [[ -n "$window_id" ]] || continue
  index=$((index + 1))

  label="$app_name"
  if [[ -n "$window_title" && "$window_title" != "$app_name" ]]; then
    label="$app_name: $window_title"
  fi
  label="$(truncate_label "$label")"

  sketchybar --add item "space.popup.${space_index}.${index}" popup."$item_name" \
             --set "space.popup.${space_index}.${index}" \
               icon.drawing=off \
               icon.width=0 \
               label="$label" \
               label.font="JetBrainsMono Nerd Font:Regular:12.0" \
               label.align=left \
               label.padding_left=14 \
               label.padding_right=14 \
               width=265 \
               click_script="/opt/homebrew/bin/yabai -m space --focus $space_index; /opt/homebrew/bin/yabai -m window --focus $window_id; /opt/homebrew/bin/sketchybar --set $item_name popup.drawing=off"
done < <(printf '%s' "$windows_json" | jq -r '.[] | select(."has-ax-reference" == true) | [.id, .app, (.title // "")] | @tsv')

sketchybar --set "$item_name" popup.drawing=toggle
