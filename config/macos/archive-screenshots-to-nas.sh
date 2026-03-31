#!/usr/bin/env sh

set -eu

source_dir="$HOME/Screenshots"
remote_host="syncthing.lan"
remote_root="/srv/Files/Erik/Screenshots"

[ -d "$source_dir" ] || exit 0

find "$source_dir" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
  [ -f "$file" ] || continue

  ext="${file##*.}"
  if [ "$ext" = "${file##*/}" ]; then
    ext=""
  else
    ext=".${ext}"
  fi

  timestamp=$(/usr/bin/stat -f "%Sm" -t "%Y%m%d-%H%M%S" "$file")
  month_dir=$(/usr/bin/stat -f "%Sm" -t "%Y-%m" "$file")
  day_dir=$(/usr/bin/stat -f "%Sm" -t "%d" "$file")

  remote_dir="$remote_root/$month_dir/$day_dir"
  ssh "$remote_host" "mkdir -p '$remote_dir'" >/dev/null 2>&1 || exit 0

  target_name="${timestamp}${ext}"
  index=1
  while ssh "$remote_host" "test -e '$remote_dir/$target_name'" >/dev/null 2>&1; do
    target_name="${timestamp}-${index}${ext}"
    index=$((index + 1))
  done

  scp -q "$file" "$remote_host:$remote_dir/$target_name" && rm -f "$file"
done
