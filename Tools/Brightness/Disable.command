#!/bin/zsh
set -euo pipefail

BIN="$HOME/Library/Application Support/T495s/T495sBrightnessOverlay"
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness-overlay.plist"
OLD_AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness.plist"

launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
launchctl bootout "gui/$UID" "$OLD_AGENT" 2>/dev/null || true
pkill -x T495sBrightnessOverlay 2>/dev/null || true
pkill -x T495sBrightnessBridge 2>/dev/null || true
[[ -x "$BIN" ]] && "$BIN" --restore-only || true

echo "Brightness overlay disabled. Native brightness remains active."
