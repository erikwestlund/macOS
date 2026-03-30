#!/bin/sh

space_index=${NAME#space.}
windows=$(/opt/homebrew/bin/yabai -m query --windows --space "$space_index" | /usr/bin/grep -c '"has-ax-reference":true')

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=off icon.color=0xffffffff icon.font="SF Pro Text:Bold:13.0"
elif [ "$windows" -gt 0 ]; then
  sketchybar --set "$NAME" background.drawing=off icon.color=0xff6f8ea8 icon.font="SF Pro Text:Semibold:13.0"
else
  sketchybar --set "$NAME" background.drawing=off icon.color=0x66707882 icon.font="SF Pro Text:Semibold:13.0"
fi
