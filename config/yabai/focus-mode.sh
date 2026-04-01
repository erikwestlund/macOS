#!/usr/bin/env sh

window_json=$(/opt/homebrew/bin/yabai -m query --windows --window 2>/dev/null)

[ -n "$window_json" ] || exit 1

window_state=$(printf '%s' "$window_json" | /usr/bin/ruby -rjson -e '
window = JSON.parse(STDIN.read)
puts [
  window["is-floating"] ? "true" : "false",
  window.fetch("display", 1)
].join(" ")
')

read -r is_floating display_id <<EOF
$window_state
EOF

if [ "$is_floating" = "true" ]; then
  exec /opt/homebrew/bin/yabai -m window --toggle float
fi

display_json=$(/opt/homebrew/bin/yabai -m query --displays --display "$display_id" 2>/dev/null)
[ -n "$display_json" ] || exit 1

display_frame=$(printf '%s' "$display_json" | /usr/bin/ruby -rjson -e '
display = JSON.parse(STDIN.read)
frame = display.fetch("frame", {})
width = 1500
width = [width, frame.fetch("w", 0)].min
height = (frame.fetch("h", 0) * 0.9).round
x = (frame.fetch("x", 0) + ((frame.fetch("w", 0) - width) / 2.0)).round
y = (frame.fetch("y", 0) + ((frame.fetch("h", 0) - height) / 2.0)).round
puts [x, y, width, height].join(" ")
')

read -r frame_x frame_y frame_w frame_h <<EOF
$display_frame
EOF

/opt/homebrew/bin/yabai -m window --toggle float || exit 1
/bin/sleep 0.05
/opt/homebrew/bin/yabai -m window --resize "abs:${frame_w}:${frame_h}" || exit 1
/bin/sleep 0.05
/opt/homebrew/bin/yabai -m window --move "abs:${frame_x}:${frame_y}"
