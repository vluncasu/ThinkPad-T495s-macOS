#!/bin/bash
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s.touchscreen.plist"
launchctl bootout "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true
rm -f "$AGENT"
rm -rf "$HOME/Library/Application Support/T495sTouchscreen"
echo "TouchscreenBridge removed."
