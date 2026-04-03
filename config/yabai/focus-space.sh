#!/usr/bin/env sh

target_space="$1"

[ -n "$target_space" ] || exit 1

/opt/homebrew/bin/yabai -m space --focus "$target_space" || exit 1
~/.config/yabai/refresh-space-bar.sh
