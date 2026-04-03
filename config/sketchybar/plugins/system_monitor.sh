#!/usr/bin/env bash

set -euo pipefail

ITEM_NAME="${NAME:-btop}"
ACTION="${1:-popup}"

clear_popup() {
  sketchybar --remove '/system\.monitor\..*/' >/dev/null 2>&1 || true
}

add_row() {
  local item_key="$1"
  local label="$2"
  local click_script="${3:-}"

  sketchybar --add item "$item_key" popup."$ITEM_NAME" \
             --set "$item_key" \
               icon.drawing=off \
               icon.width=0 \
               label="$label" \
               label.font="JetBrainsMono Nerd Font:Regular:12.0" \
               label.align=left \
               label.padding_left=14 \
               label.padding_right=14 \
               width=248 \
               ${click_script:+click_script="$click_script"}
}

format_metric() {
  local name="$1"
  local value="$2"
  printf '%-10s %s' "$name" "$value"
}

show_popup() {
  local load_avg top_output cpu_line cpu_used memsize_bytes page_size page_counts_line free_pages speculative_pages inactive_pages file_backed_pages battery_info battery_pct
  local physmem_line physmem_used_raw physmem_unused_raw pressure_line free_pct pressure_pct disk_line disk_total disk_used disk_free disk_pct swap_line swap_used
  local cached_bytes cached_gib

  clear_popup

  load_avg=$(sysctl -n vm.loadavg | tr -d '{}')

  top_output=$(top -l 1 -n 0)
  cpu_line=$(printf '%s\n' "$top_output" | /opt/homebrew/bin/rg 'CPU usage' || true)
  cpu_used=$(printf '%s' "$cpu_line" | awk -F',' '{gsub(/.*: /, "", $1); gsub(/% user/, "", $1); gsub(/% sys/, "", $2); printf "%.1f", $1 + $2}')
  physmem_line=$(printf '%s\n' "$top_output" | /opt/homebrew/bin/rg 'PhysMem' || true)

  memsize_bytes=$(sysctl -n hw.memsize)
  page_size=$(vm_stat | awk '/page size of/ {gsub(/[^0-9]/, "", $8); print $8; exit}')
  page_counts_line=$(vm_stat)
  free_pages=$(printf '%s\n' "$page_counts_line" | awk '/Pages free/ {gsub(/\./, "", $3); print $3; exit}')
  speculative_pages=$(printf '%s\n' "$page_counts_line" | awk '/Pages speculative/ {gsub(/\./, "", $3); print $3; exit}')
  inactive_pages=$(printf '%s\n' "$page_counts_line" | awk '/Pages inactive/ {gsub(/\./, "", $3); print $3; exit}')
  file_backed_pages=$(printf '%s\n' "$page_counts_line" | awk '/File-backed pages/ {gsub(/\./, "", $3); print $3; exit}')

  physmem_used_raw=$(printf '%s' "$physmem_line" | awk -F'[,(]' '{gsub(/.*: /, "", $1); gsub(/ used/, "", $1); print $1; exit}')
  physmem_unused_raw=$(printf '%s' "$physmem_line" | awk -F'[,(]' '{gsub(/^ /, "", $NF); gsub(/ unused\.?/, "", $NF); print $NF; exit}')
  cached_bytes=$(( file_backed_pages * page_size ))

  cached_gib=$(awk -v bytes="$cached_bytes" 'BEGIN {printf "%.1f", bytes / 1073741824}')

  pressure_line=$(memory_pressure | /opt/homebrew/bin/rg 'System-wide memory free percentage' || true)
  free_pct=$(printf '%s' "$pressure_line" | awk -F': ' '{gsub(/%/, "", $2); print $2}')
  pressure_pct=$(( 100 - free_pct ))

  battery_info=$(pmset -g batt)
  battery_pct=$(printf '%s\n' "$battery_info" | grep -Eo '[0-9]+%' | head -n 1 || true)

  swap_line=$(/usr/sbin/sysctl vm.swapusage 2>/dev/null || true)
  swap_used=$(printf '%s\n' "$swap_line" | awk '{for (i = 1; i <= NF; i++) if ($i == "used") {print $(i + 2); exit}}')

  disk_line=$(df -k "$HOME" | awk 'NR==2 {print $2, $3, $4, $5}')
  disk_total=$(printf '%s' "$disk_line" | awk '{printf "%.1f", $1 / 1000000}')
  disk_used=$(printf '%s' "$disk_line" | awk '{printf "%.1f", $2 / 1000000}')
  disk_free=$(printf '%s' "$disk_line" | awk '{printf "%.1f", $3 / 1000000}')
  disk_pct=$(printf '%s' "$disk_line" | awk '{gsub(/%/, "", $4); print $4}')

  add_row "system.monitor.load" "Load avg. ${load_avg}"
  add_row "system.monitor.cpu" "$(format_metric 'CPU' "${cpu_used}%")"
  add_row "system.monitor.mem" "$(format_metric 'Memory' "${physmem_used_raw:-n/a} used")"
  add_row "system.monitor.cached" "$(format_metric 'Cached' "${cached_gib} GiB")"
  add_row "system.monitor.free" "$(format_metric 'Free' "${physmem_unused_raw:-n/a} unused")"
  add_row "system.monitor.swap" "$(format_metric 'Swap' "${swap_used:-n/a}")"
  add_row "system.monitor.pressure" "$(format_metric 'Pressure' "${pressure_pct}%")"
  add_row "system.monitor.disk_used" "$(format_metric 'Disk used' "${disk_used}/${disk_total} GB (${disk_pct}%)")"
  add_row "system.monitor.disk_free" "$(format_metric 'Disk free' "${disk_free} GB")"
  add_row "system.monitor.battery" "$(format_metric 'Battery' "${battery_pct:-n/a}")"
  sketchybar --add item "system.monitor.divider" popup."$ITEM_NAME" \
             --set "system.monitor.divider" \
               icon.drawing=off \
               label.drawing=off \
               background.drawing=on \
               background.color=0x66b5cde1 \
                background.height=2 \
                width=248
  add_row "system.monitor.btop" "Open btop" "$HOME/.bin/ghostty-btop"
  add_row "system.monitor.activity" "Open Activity Monitor" "open -a \"Activity Monitor\""

  sketchybar --set "$ITEM_NAME" popup.drawing=toggle
}

case "$ACTION" in
  popup)
    show_popup
    ;;
esac
