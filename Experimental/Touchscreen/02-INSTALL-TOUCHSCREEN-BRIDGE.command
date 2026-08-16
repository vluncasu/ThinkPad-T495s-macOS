#!/bin/bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
APPDIR="$HOME/Library/Application Support/T495sTouchscreen"
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s.touchscreen.plist"
mkdir -p "$APPDIR" "$HOME/Library/LaunchAgents"

echo "Building TouchscreenBridge..."
clang -fobjc-arc -fblocks "$HERE/TouchscreenBridge.m" -framework Foundation -framework ApplicationServices -framework IOKit -o "$APPDIR/TouchscreenBridge"
cp "$HERE/settings.plist" "$APPDIR/settings.plist"
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>com.terabitlab.t495s.touchscreen</string>
<key>ProgramArguments</key><array><string>$APPDIR/TouchscreenBridge</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><true/>
<key>ProcessType</key><string>Interactive</string>
<key>StandardOutPath</key><string>$APPDIR/touchscreen.log</string>
<key>StandardErrorPath</key><string>$APPDIR/touchscreen.log</string>
</dict></plist>
PLIST
chmod 755 "$APPDIR/TouchscreenBridge"
launchctl bootout "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$AGENT"
launchctl kickstart -k "gui/$(id -u)/com.terabitlab.t495s.touchscreen"

echo
echo "The bridge is installed. Grant Accessibility and Input Monitoring to:"
echo "$APPDIR/TouchscreenBridge"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" || true
sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent" || true
open -R "$APPDIR/TouchscreenBridge"
echo
echo "After granting permissions, log out and log in once, or run this installer again."
