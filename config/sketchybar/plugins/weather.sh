#!/usr/bin/env bash

set -euo pipefail

cache_dir="$HOME/.cache/sketchybar"
cache_file="$cache_dir/weather.txt"

mkdir -p "$cache_dir"

response=$(curl -fsS --max-time 5 "https://wttr.in/?format=j1" 2>/dev/null || true)
temperature_f=$(printf '%s' "$response" | /usr/bin/jq -r '.current_condition[0].temp_F // empty' 2>/dev/null || true)

if [[ "$temperature_f" =~ ^-?[0-9]+$ ]]; then
  printf '%s\n' "$temperature_f" > "$cache_file"
elif [[ -f "$cache_file" ]]; then
  temperature_f=$(/bin/cat "$cache_file")
else
  sketchybar --set "$NAME" drawing=off label=""
  exit 0
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon.drawing=off \
  label="${temperature_f}°F"
