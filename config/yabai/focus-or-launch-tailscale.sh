#!/usr/bin/env sh

app_path="/Applications/Tailscale.app"

/usr/bin/open -a "$app_path" || exit 1

window_id=""
attempt=0
while [ "$attempt" -lt 30 ]; do
  window_id=$(
    /opt/homebrew/bin/yabai -m query --windows | /usr/bin/jq -r '
      map(select(.app == "Tailscale" and ."has-ax-reference" == true))
      | sort_by(.id)
      | last
      | .id // empty
    '
  )

  [ -n "$window_id" ] && break
  attempt=$((attempt + 1))
  /bin/sleep 0.1
done

[ -n "$window_id" ] || exit 0

/opt/homebrew/bin/yabai -m window --focus "$window_id" || exit 0

is_floating=$(/opt/homebrew/bin/yabai -m query --windows --window "$window_id" | /usr/bin/jq -r '."is-floating"')
if [ "$is_floating" != "true" ]; then
  /opt/homebrew/bin/yabai -m window "$window_id" --toggle float || true
fi
