#!/usr/bin/env sh

note_path="$HOME/Vault/Working Memory.md"
rule_label="working-memory-once"

[ -f "$note_path" ] || exit 1

previous_window_id=$(
  /opt/homebrew/bin/yabai -m query --windows | /usr/bin/jq -r '
    map(select(.app == "Zed" and (.title | contains("Working Memory.md")) and ."has-ax-reference" == true))
    | sort_by(.id)
    | last
    | .id // empty
  '
)

display_json=$(/opt/homebrew/bin/yabai -m query --displays --display 2>/dev/null)
[ -n "$display_json" ] || exit 1

space_index=$(/opt/homebrew/bin/yabai -m query --spaces --space | /usr/bin/jq -r '.index')

usable_frame=$(
  /opt/homebrew/bin/yabai -m query --windows | /usr/bin/jq -c --argjson space "$space_index" '
    [ .[]
      | select(.space == $space)
      | select(."has-ax-reference" == true)
      | select(."is-floating" == false)
      | select(."is-native-fullscreen" == false)
      | select(."is-minimized" == false)
      | select(.app != "Zed")
    ] as $wins
    | if ($wins | length) > 0 then
        {
          x: ($wins | map(.frame.x) | min | floor),
          y: ($wins | map(.frame.y) | min | floor),
          w: (($wins | map(.frame.x + .frame.w) | max) - ($wins | map(.frame.x) | min) | floor),
          h: (($wins | map(.frame.y + .frame.h) | max) - ($wins | map(.frame.y) | min) | floor)
        }
      else
        empty
      end'
)

if [ -z "$usable_frame" ]; then
  usable_frame=$(printf '%s' "$display_json" | /usr/bin/jq -c '{x: (.frame.x + 8 | floor), y: (.frame.y + 40 | floor), w: (.frame.w - 16 | floor), h: (.frame.h - 48 | floor)}')
fi

/opt/homebrew/bin/yabai -m rule --add label="$rule_label" app="^Zed$" title="^Working Memory\.md.*$" manage=off

"/Applications/Zed.app/Contents/MacOS/cli" -n "$note_path" >/dev/null 2>&1 || exit 1

window_id=""
attempt=0
while [ "$attempt" -lt 40 ]; do
  window_id=$(
    /opt/homebrew/bin/yabai -m query --windows | /usr/bin/jq -r '
      map(select(.app == "Zed" and (.title | contains("Working Memory.md")) and ."has-ax-reference" == true))
      | sort_by(.id)
      | last
      | .id // empty
    '
  )

  if [ -n "$window_id" ] && [ "$window_id" != "$previous_window_id" ]; then
    break
  fi

  attempt=$((attempt + 1))
  /bin/sleep 0.1
done

/opt/homebrew/bin/yabai -m rule --remove "$rule_label" >/dev/null 2>&1 || true

[ -n "$window_id" ] || exit 1

attempt=0
while [ "$attempt" -lt 20 ]; do
  is_floating=$(
    /opt/homebrew/bin/yabai -m query --windows --window "$window_id" | /usr/bin/jq -r '."is-floating"'
  )

  [ "$is_floating" = "true" ] && break
  attempt=$((attempt + 1))
  /bin/sleep 0.1
done

[ "$is_floating" = "true" ] || exit 1

/opt/homebrew/bin/yabai -m window --focus "$window_id" || exit 1

/opt/homebrew/bin/yabai -m window "$window_id" --resize "abs:1200:950" || exit 1
/bin/sleep 0.1

read -r display_x display_y display_w display_h <<EOF
$(printf '%s' "$usable_frame" | /usr/bin/jq -r '[.x, .y, .w, .h] | @tsv')
EOF

read -r window_w window_h <<EOF
$(/opt/homebrew/bin/yabai -m query --windows --window "$window_id" | /usr/bin/jq -r '[.frame.w, .frame.h] | @tsv')
EOF

frame_x=$(/usr/bin/printf '%.0f' "$(/usr/bin/awk "BEGIN { print $display_x + (($display_w - $window_w) / 2) }")")
frame_y=$(/usr/bin/printf '%.0f' "$(/usr/bin/awk "BEGIN { print $display_y + (($display_h - $window_h) / 2) }")")

/opt/homebrew/bin/yabai -m window "$window_id" --move "abs:${frame_x}:${frame_y}"
