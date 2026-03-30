#!/usr/bin/env sh

set -eu

app_name="$1"
icon_source="$2"

[ -n "$app_name" ] || exit 1
[ -n "$icon_source" ] || exit 1

app_path="$HOME/Applications/Chrome Apps.localized/${app_name}.app"
resources_dir="$app_path/Contents/Resources"
iconset_dir="$resources_dir/app.iconset"
icon_target="$resources_dir/app.icns"

[ -d "$app_path" ] || exit 0
[ -f "$icon_source" ] || exit 0

/bin/rm -rf "$iconset_dir"
/bin/mkdir -p "$iconset_dir"

/usr/bin/sips -z 16 16 "$icon_source" --out "$iconset_dir/icon_16x16.png" >/dev/null
/usr/bin/sips -z 32 32 "$icon_source" --out "$iconset_dir/icon_16x16@2x.png" >/dev/null
/usr/bin/sips -z 32 32 "$icon_source" --out "$iconset_dir/icon_32x32.png" >/dev/null
/usr/bin/sips -z 64 64 "$icon_source" --out "$iconset_dir/icon_32x32@2x.png" >/dev/null
/usr/bin/sips -z 128 128 "$icon_source" --out "$iconset_dir/icon_128x128.png" >/dev/null
/usr/bin/sips -z 256 256 "$icon_source" --out "$iconset_dir/icon_128x128@2x.png" >/dev/null
/usr/bin/sips -z 256 256 "$icon_source" --out "$iconset_dir/icon_256x256.png" >/dev/null
/usr/bin/sips -z 512 512 "$icon_source" --out "$iconset_dir/icon_256x256@2x.png" >/dev/null
/usr/bin/sips -z 512 512 "$icon_source" --out "$iconset_dir/icon_512x512.png" >/dev/null
/bin/cp "$icon_source" "$iconset_dir/icon_512x512@2x.png"

/usr/bin/iconutil -c icns "$iconset_dir" -o "$icon_target"
/usr/bin/touch "$app_path"
/usr/bin/killall Dock >/dev/null 2>&1 || true

/bin/rm -rf "$iconset_dir"
