#!/bin/zsh
set -euo pipefail

APP_DIR="$HOME/Library/Application Support/T495s"
BIN="$APP_DIR/T495sBrightnessOverlay"
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness-overlay.plist"
OLD_AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness.plist"

launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
launchctl bootout "gui/$UID" "$OLD_AGENT" 2>/dev/null || true
pkill -x T495sBrightnessOverlay 2>/dev/null || true
pkill -x T495sBrightnessBridge 2>/dev/null || true

if [[ -x "$BIN" ]]; then
  "$BIN" --restore-only || true
fi

rm -f "$AGENT" "$OLD_AGENT" "$BIN" "$APP_DIR/T495sBrightnessBridge"
echo "Brightness overlay removed and ColorSync settings restored."
