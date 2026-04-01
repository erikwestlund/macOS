#!/usr/bin/env bash

set -euo pipefail

if ! command -v tailscale >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

status_json=$(tailscale status --json 2>/dev/null || true)
if [[ -z "$status_json" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

backend_state=$(printf '%s' "$status_json" | jq -r '.BackendState // empty')
ip_count=$(printf '%s' "$status_json" | jq -r '(.TailscaleIPs // []) | length')

if [[ "$backend_state" != "Running" || "$ip_count" -eq 0 ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon='󰖂' \
  icon.color='0xffabc5da' \
  label.drawing=off
