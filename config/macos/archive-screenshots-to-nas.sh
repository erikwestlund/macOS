#!/usr/bin/env sh

set -eu

source_dir="$HOME/Screenshots"
remote_host="syncthing.lan"
remote_root="/srv/Files/Erik/Screenshots"

[ -d "$source_dir" ] || exit 0

"$HOME/.config/macos/organize-screenshots.sh"

ssh "$remote_host" "mkdir -p '$remote_root'" >/dev/null 2>&1 || exit 0

rsync -a --ignore-existing --remove-source-files "$source_dir/" "$remote_host:$remote_root/" || exit 0

find "$source_dir" -depth -type d -empty ! -path "$source_dir" -delete
