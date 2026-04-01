#!/usr/bin/env bash

set -euo pipefail

truncate_text() {
  local text="$1"
  local limit=36

  if [[ ${#text} -le $limit ]]; then
    printf '%s' "$text"
  else
    printf '%s...' "${text:0:$((limit - 3))}"
  fi
}

json_field() {
  local key="$1"
  local json="$2"

  printf '%s' "$json" | grep -o '"'"$key"'":"[^"]*"' | cut -d'"' -f4
}

json_bool() {
  local key="$1"
  local json="$2"

  printf '%s' "$json" | grep -o '"'"$key"'":\(true\|false\)' | cut -d: -f2
}

show_item() {
  local icon="$1"
  local label="$2"
  local color="$3"

  sketchybar --set "$NAME" \
    drawing=on \
    icon="$icon" \
    icon.color="$color" \
    label="$(truncate_text "$label")"
}

if command -v media-control >/dev/null 2>&1; then
  media_json=$(media-control get 2>/dev/null || true)

  if [[ -n "$media_json" && "$media_json" != "null" ]]; then
    playing=$(json_bool playing "$media_json")

    if [[ "$playing" == "true" ]]; then
      title=$(json_field title "$media_json")
      artist=$(json_field artist "$media_json")
      bundle_id=$(json_field bundleIdentifier "$media_json")

      if [[ -n "$title" ]]; then
        if [[ -n "$artist" ]]; then
          display_text="$artist - $title"
        else
          display_text="$title"
        fi

        case "$bundle_id" in
          *Spotify*)
            icon="󰓇"
            color="0xff1db954"
            ;;
          *Music*)
            icon="󰎆"
            color="0xfffa586a"
            ;;
          *YouTube*|*agimnkijcaahngcdmfeangaknmldooml*)
            icon="󰗃"
            color="0xffff0000"
            ;;
          *Chrome*)
            icon="󰊯"
            color="0xffff0000"
            ;;
          *)
            icon="󰎆"
            color="0xffeef2f6"
            ;;
        esac

        show_item "$icon" "$display_text" "$color"
        exit 0
      fi
    fi
  fi
fi

spotify_state=$(osascript -e 'if application "Spotify" is running then tell application "Spotify" to player state as text' 2>/dev/null || true)
if [[ "$spotify_state" == "playing" ]]; then
  spotify_track=$(osascript -e 'tell application "Spotify" to artist of current track & " - " & name of current track' 2>/dev/null || true)
  if [[ -n "$spotify_track" ]]; then
    show_item "󰓇" "$spotify_track" "0xff1db954"
    exit 0
  fi
fi

music_state=$(osascript -e 'if application "Music" is running then tell application "Music" to player state as text' 2>/dev/null || true)
if [[ "$music_state" == "playing" ]]; then
  music_track=$(osascript -e 'tell application "Music" to artist of current track & " - " & name of current track' 2>/dev/null || true)
  if [[ -n "$music_track" ]]; then
    show_item "󰎆" "$music_track" "0xfffa586a"
    exit 0
  fi
fi

sketchybar --set "$NAME" drawing=off
