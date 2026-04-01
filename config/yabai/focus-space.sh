#!/usr/bin/env sh

target_space="$1"

[ -n "$target_space" ] || exit 1

/opt/homebrew/bin/yabai -m space --focus "$target_space" || exit 1

/bin/sleep 0.05

window_id=$(
  /opt/homebrew/bin/yabai -m query --windows --space "$target_space" | /opt/homebrew/bin/jq -r \
    '[.[] | select(."has-ax-reference" == true)] | sort_by(.id) | last | .id // empty'
)

[ -n "$window_id" ] || exit 0

/opt/homebrew/bin/yabai -m window --focus "$window_id" || true
