#!/usr/bin/env bash

set -euo pipefail

yabai_bin="/opt/homebrew/bin/yabai"
jq_bin="/opt/homebrew/bin/jq"
layout_name="${1:-}"

window_for_app() {
  local app_name="$1"

  "$yabai_bin" -m query --windows | "$jq_bin" -r \
    --arg app_name "$app_name" \
    '[.[] | select(.app == $app_name and ."has-ax-reference" == true and .layer == "normal" and ."is-floating" == false and ."can-move" == true)] | sort_by(.id) | last | .id // empty'
}

ensure_window() {
  local app_name="$1"
  local app_path="$2"
  local window_id

  window_id="$(window_for_app "$app_name")"
  if [[ -n "$window_id" ]]; then
    printf '%s\n' "$window_id"
    return 0
  fi

  /usr/bin/open -a "$app_path" >/dev/null 2>&1 || true

  for _ in {1..80}; do
    window_id="$(window_for_app "$app_name")"
    if [[ -n "$window_id" ]]; then
      printf '%s\n' "$window_id"
      return 0
    fi

    /bin/sleep 0.1
  done

  return 1
}

ensure_tiled() {
  local window_id="$1"
  local is_floating

  is_floating="$("$yabai_bin" -m query --windows --window "$window_id" | "$jq_bin" -r '."is-floating"')"
  if [[ "$is_floating" == "true" ]]; then
    "$yabai_bin" -m window "$window_id" --toggle float >/dev/null 2>&1 || true
    /bin/sleep 0.05
  fi
}

move_to_space() {
  local window_id="$1"
  local target_space="$2"
  local current_space

  current_space="$("$yabai_bin" -m query --windows --window "$window_id" | "$jq_bin" -r '.space')"
  if [[ "$current_space" != "$target_space" ]]; then
    "$yabai_bin" -m window "$window_id" --space "$target_space" >/dev/null 2>&1
    /bin/sleep 0.05
  fi
}

set_insert_mode() {
  local window_id="$1"
  local direction="$2"

  "$yabai_bin" -m window "$window_id" --insert "$direction" >/dev/null 2>&1 || true
}

clear_insert_mode() {
  local window_id="$1"
  local direction="$2"

  "$yabai_bin" -m window "$window_id" --insert "$direction" >/dev/null 2>&1 || true
}

focus_window_on_space() {
  local target_space="$1"
  local window_id="$2"

  "$yabai_bin" -m space --focus "$target_space" >/dev/null 2>&1 || exit 1
  /bin/sleep 0.05
  "$yabai_bin" -m window --focus "$window_id" >/dev/null 2>&1 || true
  /bin/sleep 0.05
}

space_display() {
  local target_space="$1"
  "$yabai_bin" -m query --spaces --space "$target_space" | "$jq_bin" -r '.display'
}

create_temp_space() {
  local display_id="$1"
  local before_spaces temp_space

  before_spaces="$("$yabai_bin" -m query --spaces --display "$display_id" | "$jq_bin" -r '.[].index')"
  "$yabai_bin" -m space --create >/dev/null 2>&1
  temp_space="$("$yabai_bin" -m query --spaces --display "$display_id" | "$jq_bin" -r --arg before_spaces "$before_spaces" '.[] | select((.index | tostring) as $idx | ($before_spaces | split("\n") | index($idx) | not)) | .index' | /usr/bin/tail -n 1)"

  [[ -n "$temp_space" ]] || return 1
  printf '%s\n' "$temp_space"
}

destroy_temp_space() {
  local temp_space="$1"
  [[ -n "$temp_space" ]] || return 0
  "$yabai_bin" -m space "$temp_space" --destroy >/dev/null 2>&1 || true
}

prepare_windows() {
  local temp_space="$1"
  shift

  for window_id in "$@"; do
    ensure_tiled "$window_id"
    move_to_space "$window_id" "$temp_space"
  done
}

restore_two_column_layout() {
  local target_space="$1"
  local left_window_id="$2"
  local right_window_id="$3"
  local display_id temp_space

  display_id="$(space_display "$target_space")"
  temp_space="$(create_temp_space "$display_id")"

  prepare_windows "$temp_space" "$left_window_id" "$right_window_id"
  move_to_space "$left_window_id" "$target_space"
  move_to_space "$right_window_id" "$target_space"
  focus_window_on_space "$target_space" "$left_window_id"
  "$HOME/.config/yabai/snap-window.sh" west >/dev/null 2>&1 || true
  focus_window_on_space "$target_space" "$left_window_id"
  destroy_temp_space "$temp_space"
}

case "$layout_name" in
  ws10)
    restore_two_column_layout \
      10 \
      "$(ensure_window "Microsoft Outlook" "/Applications/Microsoft Outlook.app")" \
      "$(ensure_window "Microsoft Teams" "/Applications/Microsoft Teams.app")"
    ;;
  ws11)
    restore_two_column_layout \
      11 \
      "$(ensure_window "Fastmail" "/Applications/Fastmail.app")" \
      "$(ensure_window "Morgen" "/Applications/Morgen.app")"
    ;;
  scratch)
    restore_two_column_layout \
      13 \
      "$(ensure_window "Messages" "/System/Applications/Messages.app")" \
      "$(ensure_window "YouTube" "$HOME/Applications/Chrome Apps.localized/YouTube.app")"
    ;;
  *)
    exit 1
    ;;
esac
