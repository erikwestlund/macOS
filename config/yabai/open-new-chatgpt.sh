#!/usr/bin/env bash

set -euo pipefail

chatgpt_app="$HOME/Applications/Chrome Apps.localized/ChatGPT.app"
chrome_bin="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
info_plist="$chatgpt_app/Contents/Info.plist"

current_space=$(/opt/homebrew/bin/yabai -m query --spaces --space | /opt/homebrew/bin/jq -r '.index')
previous_window_id=$(
  /opt/homebrew/bin/yabai -m query --windows | /opt/homebrew/bin/jq -r \
    --argjson current_space "$current_space" \
    '[.[] | select(.app == "ChatGPT" and .space == $current_space)] | sort_by(.id) | last | .id // 0'
)
app_id=$(/usr/libexec/PlistBuddy -c 'Print :CrAppModeShortcutID' "$info_plist")

"$chrome_bin" "--app-id=$app_id" --new-window >/dev/null 2>&1 &

for _ in {1..40}; do
  new_window_id=$(
    /opt/homebrew/bin/yabai -m query --windows | /opt/homebrew/bin/jq -r \
      --argjson current_space "$current_space" \
      --argjson previous_window_id "$previous_window_id" \
      '[.[] | select(.app == "ChatGPT" and .space == $current_space and .id > $previous_window_id)] | sort_by(.id) | last | .id // empty'
  )

  if [[ -n "$new_window_id" ]]; then
    /opt/homebrew/bin/yabai -m window --focus "$new_window_id"
    exit 0
  fi

  /bin/sleep 0.1
done
