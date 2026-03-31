#!/usr/bin/env sh

set -eu

source_dir="$HOME/Downloads"
remote_host="syncthing.lan"
remote_root="/srv/Files/Erik/Downloads"

[ -d "$source_dir" ] || exit 0

find "$source_dir" -mindepth 1 -maxdepth 1 -mtime +7 -print0 | while IFS= read -r -d '' item; do
  [ -e "$item" ] || continue

  month_dir=$(/usr/bin/stat -f "%Sm" -t "%Y-%m" "$item")
  remote_dir="$remote_root/$month_dir"
  ssh "$remote_host" "mkdir -p '$remote_dir'" >/dev/null 2>&1 || exit 0

  base_name=$(/usr/bin/basename "$item")
  target_name="$base_name"
  index=1
  while ssh "$remote_host" "test -e '$remote_dir/$target_name'" >/dev/null 2>&1; do
    target_name="${base_name}-${index}"
    index=$((index + 1))
  done

  rsync -a "$item" "$remote_host:$remote_dir/$target_name" && rm -rf "$item"
done
