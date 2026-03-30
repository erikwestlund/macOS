#!/usr/bin/env sh

direction="$1"
max_space=12

current_space=$(/opt/homebrew/bin/yabai -m query --spaces --space | /usr/bin/grep -o '"index":[[:space:]]*[0-9]*' | /usr/bin/grep -o '[0-9]*')

[ -n "$current_space" ] || exit 1

case "$direction" in
  next)
    target_space=$((current_space + 1))
    if [ "$target_space" -gt "$max_space" ]; then
      target_space=1
    fi
    ;;
  prev)
    target_space=$((current_space - 1))
    if [ "$target_space" -lt 1 ]; then
      target_space=$max_space
    fi
    ;;
  *)
    exit 1
    ;;
esac

/opt/homebrew/bin/yabai -m space --focus "$target_space"
