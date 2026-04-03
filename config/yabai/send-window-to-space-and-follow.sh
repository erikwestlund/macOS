#!/usr/bin/env sh

target_space="$1"
window_id=$(/opt/homebrew/bin/yabai -m query --windows --window | /usr/bin/grep -o '"id":[[:space:]]*[0-9]*' | /usr/bin/grep -o '[0-9]*')

[ -n "$target_space" ] || exit 1
[ -n "$window_id" ] || exit 1

/opt/homebrew/bin/yabai -m window "$window_id" --space "$target_space" || exit 1
/opt/homebrew/bin/yabai -m space --focus "$target_space" || exit 1
~/.config/yabai/refresh-space-bar.sh
/bin/sleep 0.05
/opt/homebrew/bin/yabai -m window --focus "$window_id"
