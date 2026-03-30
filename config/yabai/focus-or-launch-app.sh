#!/usr/bin/env sh

app_name="$1"
app_path="$2"

[ -n "$app_name" ] || exit 1
[ -n "$app_path" ] || exit 1

window_json=$(/opt/homebrew/bin/yabai -m query --windows | /usr/bin/jq -c --arg app "$app_name" 'map(select(.app == $app and ."has-ax-reference" == true)) | sort_by(.id) | last')

if [ "$window_json" = "null" ] || [ -z "$window_json" ]; then
  /usr/bin/open -a "$app_path"
  exit 0
fi

target_space=$(printf '%s' "$window_json" | /usr/bin/jq -r '.space')
window_id=$(printf '%s' "$window_json" | /usr/bin/jq -r '.id')

[ -n "$target_space" ] || exit 1
[ -n "$window_id" ] || exit 1

/opt/homebrew/bin/yabai -m space --focus "$target_space" || exit 1
/usr/bin/open -a "$app_path"
/bin/sleep 0.05
/opt/homebrew/bin/yabai -m window --focus "$window_id"
