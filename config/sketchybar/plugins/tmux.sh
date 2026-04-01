#!/usr/bin/env bash

set -euo pipefail

PLUGIN_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins"
ITEM_NAME="${NAME:-tmux}"
ACTION="${1:-update}"
SESSION_ARG="${2:-}"

list_sessions() {
  tmux list-sessions -F '#{session_name}:#{session_windows}:#{?session_attached,attached,detached}' 2>/dev/null || true
}

clear_popup() {
  sketchybar --remove '/tmux\.session\..*/' >/dev/null 2>&1 || true
}

update_item() {
  local sessions count

  sessions="$(list_sessions)"
  if [[ -z "$sessions" ]]; then
    clear_popup
    sketchybar --set "$ITEM_NAME" drawing=off popup.drawing=off
    exit 0
  fi

  count=$(printf '%s\n' "$sessions" | wc -l | tr -d ' ')
  sketchybar --set "$ITEM_NAME" drawing=on label="$count"
}

show_popup() {
  local sessions index line session_name session_windows session_status session_label quoted_session

  sessions="$(list_sessions)"
  if [[ -z "$sessions" ]]; then
    sketchybar --set "$ITEM_NAME" popup.drawing=off
    exit 0
  fi

  clear_popup
  index=0

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    index=$((index + 1))
    session_name=${line%%:*}
    line=${line#*:}
    session_windows=${line%%:*}
    session_status=${line##*:}

    session_label="$session_name (${session_windows}w)"
    if [[ "$session_status" == "attached" ]]; then
      session_label="$session_label *"
    fi

    printf -v quoted_session '%q' "$session_name"
    sketchybar --add item "tmux.session.$index" popup."$ITEM_NAME" \
               --set "tmux.session.$index" \
                  icon.drawing=off \
                  icon.width=0 \
                  icon.padding_left=0 \
                  icon.padding_right=0 \
                  label="$session_label" \
                  label.font="JetBrainsMono Nerd Font:Regular:12.0" \
                  label.align=left \
                  label.padding_left=12 \
                  label.padding_right=12 \
                  width=240

    sketchybar --add item "tmux.session.$index.open" popup."$ITEM_NAME" \
               --set "tmux.session.$index.open" \
                  icon.drawing=off \
                  icon.width=0 \
                  icon.padding_left=0 \
                  icon.padding_right=0 \
                  label="  open" \
                  label.font="JetBrainsMono Nerd Font:Regular:12.0" \
                  label.align=left \
                  label.padding_left=24 \
                  label.padding_right=12 \
                  click_script="$PLUGIN_DIR/tmux.sh attach $quoted_session" \
                  width=240

    sketchybar --add item "tmux.session.$index.kill" popup."$ITEM_NAME" \
               --set "tmux.session.$index.kill" \
                  icon.drawing=off \
                  icon.width=0 \
                  icon.padding_left=0 \
                  icon.padding_right=0 \
                  label="  kill" \
                  label.font="JetBrainsMono Nerd Font:Regular:12.0" \
                  label.align=left \
                  label.padding_left=24 \
                  label.padding_right=12 \
                  click_script="$PLUGIN_DIR/tmux.sh kill $quoted_session" \
                  width=240
  done <<< "$sessions"

  sketchybar --set "$ITEM_NAME" popup.drawing=toggle
}

attach_session() {
  local quoted_session

  [[ -n "$SESSION_ARG" ]] || exit 0
  printf -v quoted_session '%q' "$SESSION_ARG"
  "$HOME/.bin/ghostty-new-window" "tmux attach-session -t $quoted_session"
}

kill_session() {
  local quoted_session

  [[ -n "$SESSION_ARG" ]] || exit 0
  printf -v quoted_session '%q' "$SESSION_ARG"
  tmux kill-session -t "$SESSION_ARG" 2>/dev/null || true
  sketchybar --set "$ITEM_NAME" popup.drawing=off
  "$PLUGIN_DIR/tmux.sh" update
}

case "$ACTION" in
  update)
    update_item
    ;;
  popup)
    show_popup
    ;;
  attach)
    attach_session
    ;;
  kill)
    kill_session
    ;;
esac
