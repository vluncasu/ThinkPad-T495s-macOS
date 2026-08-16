#!/bin/zsh
set -euo pipefail

APP="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [[ ! -x "$APP" ]]; then
  echo "Google Chrome was not found in /Applications."
  exit 1
fi

osascript -e 'tell application "Google Chrome" to quit' >/dev/null 2>&1 || true
sleep 2

exec "$APP" \
  --disable-gpu \
  --disable-gpu-compositing \
  --disable-accelerated-video-decode
