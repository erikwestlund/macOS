#!/usr/bin/env sh

current_space=$(/opt/homebrew/bin/yabai -m query --spaces --space | /usr/bin/grep -o '"index":[[:space:]]*[0-9]*' | /usr/bin/grep -o '[0-9]*')

if [ "$current_space" = "14" ]; then
  /opt/homebrew/bin/yabai -m space --focus recent
else
  /opt/homebrew/bin/yabai -m space --focus 14
fi
