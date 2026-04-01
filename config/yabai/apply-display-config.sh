#!/usr/bin/env sh

machine_scope=

if [ -f "$HOME/.machine" ]; then
  machine_scope="$(/usr/bin/tr -d '[:space:]' < "$HOME/.machine")"
fi

if [ "$machine_scope" = "desktop" ]; then
  /opt/homebrew/bin/yabai -m config external_bar all:34:0
else
  /opt/homebrew/bin/yabai -m config external_bar all:0:0
fi
