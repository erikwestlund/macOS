#!/usr/bin/env sh

direction="$1"
max_space=12

current_space=$(/opt/homebrew/bin/yabai -m query --spaces --space | /usr/bin/grep -o '"index":[[:space:]]*[0-9]*' | /usr/bin/grep -o '[0-9]*')

[ -n "$current_space" ] || exit 1

occupied_spaces=""
space=1
while [ "$space" -le "$max_space" ]; do
  count=$(/opt/homebrew/bin/yabai -m query --windows --space "$space" | /usr/bin/grep -c '"has-ax-reference":true')
  if [ "$count" -gt 0 ]; then
    occupied_spaces="$occupied_spaces $space"
  fi
  space=$((space + 1))
done

[ -n "$occupied_spaces" ] || exit 0

set -- $occupied_spaces
spaces="$*"
target_space=""

case "$direction" in
  next)
    for space in $spaces; do
      if [ "$space" -gt "$current_space" ]; then
        target_space=$space
        break
      fi
    done
    if [ -z "$target_space" ]; then
      for space in $spaces; do
        target_space=$space
        break
      done
    fi
    ;;
  prev)
    for space in $spaces; do
      if [ "$space" -lt "$current_space" ]; then
        target_space=$space
      fi
    done
    if [ -z "$target_space" ]; then
      for space in $spaces; do
        target_space=$space
      done
    fi
    ;;
  *)
    exit 1
    ;;
esac

[ -n "$target_space" ] || exit 0
/opt/homebrew/bin/yabai -m space --focus "$target_space"
