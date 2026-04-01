#!/usr/bin/env bash

set -euo pipefail

yabai_bin="/opt/homebrew/bin/yabai"
jq_bin="/opt/homebrew/bin/jq"

direction="${1:-}"

case "$direction" in
  west|east|north|south)
    ;;
  *)
    exit 1
    ;;
esac

opposite_direction() {
  case "$1" in
    west) printf 'east\n' ;;
    east) printf 'west\n' ;;
    north) printf 'south\n' ;;
    south) printf 'north\n' ;;
  esac
}

set_insert_mode() {
  local window_id="$1"
  local target_direction="$2"
  local alternate_direction

  alternate_direction="$(opposite_direction "$target_direction")"

  "$yabai_bin" -m window "$window_id" --insert "$alternate_direction" >/dev/null 2>&1 || true
  "$yabai_bin" -m window "$window_id" --insert "$target_direction" >/dev/null 2>&1
}

clear_insert_mode() {
  local window_id="$1"
  local target_direction="$2"

  "$yabai_bin" -m window "$window_id" --insert "$target_direction" >/dev/null 2>&1 || true
}

is_positioned_correctly() {
  local focused_x="${1%.*}"
  local focused_y="${2%.*}"
  local other_x="${3%.*}"
  local other_y="${4%.*}"

  case "$direction" in
    west) [[ "$focused_x" -lt "$other_x" ]] ;;
    east) [[ "$focused_x" -gt "$other_x" ]] ;;
    north) [[ "$focused_y" -lt "$other_y" ]] ;;
    south) [[ "$focused_y" -gt "$other_y" ]] ;;
  esac
}

focused_window_json="$($yabai_bin -m query --windows --window)"
focused_window_id="$(printf '%s\n' "$focused_window_json" | "$jq_bin" -r '.id')"
current_space="$(printf '%s\n' "$focused_window_json" | "$jq_bin" -r '.space')"
current_display="$(printf '%s\n' "$focused_window_json" | "$jq_bin" -r '.display')"
space_type="$($yabai_bin -m query --spaces --space "$current_space" | "$jq_bin" -r '.type')"
is_floating="$(printf '%s\n' "$focused_window_json" | "$jq_bin" -r '."is-floating"')"

if [[ "$space_type" != "bsp" || "$is_floating" == "true" ]]; then
  exit 0
fi

sibling_window_ids=($(
  "$yabai_bin" -m query --windows --space "$current_space" | "$jq_bin" -r \
    --argjson focused_window_id "$focused_window_id" \
    '.[] | select(.id != $focused_window_id and ."is-floating" == false and ."can-move" == true and ."is-visible" == true) | .id'
))

if [[ "${#sibling_window_ids[@]}" -eq 0 ]]; then
  exit 0
fi

saved_insertion_point="$($yabai_bin -m config window_insertion_point)"
temp_space=""
first_other_window_id="${sibling_window_ids[0]}"

cleanup() {
  local remaining_temp_windows=()

  "$yabai_bin" -m config window_insertion_point "$saved_insertion_point" >/dev/null 2>&1 || true

  if [[ -n "$temp_space" ]]; then
    remaining_temp_windows=($(
      "$yabai_bin" -m query --windows --space "$temp_space" 2>/dev/null | "$jq_bin" -r '.[].id' 2>/dev/null || true
    ))

    if (( ${#remaining_temp_windows[@]} > 0 )); then
      for window_id in "${remaining_temp_windows[@]}"; do
        "$yabai_bin" -m window "$window_id" --space "$current_space" >/dev/null 2>&1 || true
      done
    fi

    "$yabai_bin" -m space "$temp_space" --destroy >/dev/null 2>&1 || true
  fi

  "$yabai_bin" -m space --focus "$current_space" >/dev/null 2>&1 || true
  "$yabai_bin" -m window --focus "$focused_window_id" >/dev/null 2>&1 || true
}

trap cleanup EXIT

"$yabai_bin" -m space --focus "$current_space" >/dev/null 2>&1 || true
"$yabai_bin" -m config window_insertion_point focused >/dev/null 2>&1

before_spaces="$($yabai_bin -m query --spaces --display "$current_display" | "$jq_bin" -r '.[].index')"
"$yabai_bin" -m space --create >/dev/null 2>&1
temp_space="$($yabai_bin -m query --spaces --display "$current_display" | "$jq_bin" -r --arg before_spaces "$before_spaces" '.[] | select((.index | tostring) as $idx | ($before_spaces | split("\n") | index($idx) | not)) | .index' | tail -n 1)"

if [[ -z "$temp_space" ]]; then
  exit 1
fi

for window_id in "${sibling_window_ids[@]}"; do
  "$yabai_bin" -m window "$window_id" --space "$temp_space" >/dev/null 2>&1
done

"$yabai_bin" -m space --focus "$current_space" >/dev/null 2>&1 || true
"$yabai_bin" -m window --focus "$focused_window_id" >/dev/null 2>&1 || true
set_insert_mode "$focused_window_id" "$direction"
"$yabai_bin" -m window "$first_other_window_id" --space "$current_space" >/dev/null 2>&1

focused_frame_json="$($yabai_bin -m query --windows --window "$focused_window_id")"
other_frame_json="$($yabai_bin -m query --windows --window "$first_other_window_id")"
focused_x="$(printf '%s\n' "$focused_frame_json" | "$jq_bin" -r '.frame.x')"
focused_y="$(printf '%s\n' "$focused_frame_json" | "$jq_bin" -r '.frame.y')"
other_x="$(printf '%s\n' "$other_frame_json" | "$jq_bin" -r '.frame.x')"
other_y="$(printf '%s\n' "$other_frame_json" | "$jq_bin" -r '.frame.y')"

if ! is_positioned_correctly "$focused_x" "$focused_y" "$other_x" "$other_y"; then
  "$yabai_bin" -m window "$focused_window_id" --swap "$direction" >/dev/null 2>&1 || true
fi

"$yabai_bin" -m window "$focused_window_id" --ratio abs:0.5 >/dev/null 2>&1 || true
clear_insert_mode "$focused_window_id" "$direction"

anchor_window_id="$first_other_window_id"
anchor_direction="$(opposite_direction "$direction")"
"$yabai_bin" -m window --focus "$anchor_window_id" >/dev/null 2>&1
set_insert_mode "$anchor_window_id" "$anchor_direction"
clear_insert_mode "$anchor_window_id" "$anchor_direction"

for window_id in "${sibling_window_ids[@]:1}"; do
  "$yabai_bin" -m window "$window_id" --space "$current_space" >/dev/null 2>&1
  anchor_window_id="$window_id"
  "$yabai_bin" -m window --focus "$anchor_window_id" >/dev/null 2>&1 || true
  set_insert_mode "$anchor_window_id" "$anchor_direction"
  clear_insert_mode "$anchor_window_id" "$anchor_direction"
done

"$yabai_bin" -m window --focus "$focused_window_id" >/dev/null 2>&1
