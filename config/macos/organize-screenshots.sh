#!/usr/bin/env sh

set -eu

source_dir="$HOME/Screenshots"

[ -d "$source_dir" ] || exit 0

find "$source_dir" -type f ! -name '.organize.*' -print0 | while IFS= read -r -d '' file; do
  [ -f "$file" ] || continue

  timestamp=$(/usr/bin/stat -f "%B" "$file" 2>/dev/null || printf '0')
  if [ "$timestamp" -le 0 ] 2>/dev/null; then
    timestamp=$(/usr/bin/stat -f "%m" "$file")
  fi

  month_dir=$(/bin/date -r "$timestamp" "+%m")
  day_dir=$(/bin/date -r "$timestamp" "+%d")
  target_dir="$source_dir/$month_dir/$day_dir"
  /bin/mkdir -p "$target_dir"

  base_name=$(/usr/bin/basename "$file")
  name_root="${base_name%.*}"
  if [ "$name_root" = "$base_name" ]; then
    extension=""
  else
    extension=".${base_name##*.}"
  fi

  normalized_name=$(/bin/date -r "$timestamp" "+%Y-%m-%d_%H.%M.%S")
  target_path="$target_dir/${normalized_name}${extension}"

  if [ "$file" = "$target_path" ]; then
    continue
  fi

  index=1
  while [ -e "$target_path" ]; do
    target_path="$target_dir/${normalized_name}-${index}${extension}"
    index=$((index + 1))
  done

  /bin/mv "$file" "$target_path"
done
