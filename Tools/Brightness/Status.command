#!/bin/zsh
set -u

LABEL="com.terabitlab.t495s-brightness-overlay"
BIN="$HOME/Library/Application Support/T495s/T495sBrightnessOverlay"
AGENT="$HOME/Library/LaunchAgents/$LABEL.plist"
OLD_AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness.plist"

echo "Binary:"
ls -l "$BIN" 2>&1 || true

echo "\nLaunchAgent:"
plutil -lint "$AGENT" 2>&1 || true
launchctl print "gui/$UID/$LABEL" 2>&1 | sed -n '1,120p' || true

echo "\nProcesses:"
pgrep -fl 'T495sBrightness(Overlay|Bridge)' || true

echo "\nObsolete gamma bridge:"
[[ -e "$OLD_AGENT" ]] && echo "present" || echo "absent"

echo "\nNative display brightness:"
ioreg -r -c AppleBacklightDisplay -l 2>/dev/null | grep -i -E 'brightness|linear|value|max|min' | head -80 || true

echo "\nLog:"
tail -80 "$HOME/Library/Logs/T495sBrightnessOverlay.log" 2>/dev/null || true
