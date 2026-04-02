#!/usr/bin/env bash

set -euo pipefail

/usr/bin/open -a TablePlus

for _ in {1..40}; do
  if /usr/bin/osascript -e 'tell application "System Events" to tell process "TablePlus" to keystroke "n" using command down' >/dev/null 2>&1; then
    exit 0
  fi

  /bin/sleep 0.1
done

exit 1
